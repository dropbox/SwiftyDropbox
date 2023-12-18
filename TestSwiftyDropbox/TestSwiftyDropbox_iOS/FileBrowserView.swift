//
//  Copyright © 2023 Dropbox. All rights reserved.
//

import SwiftUI

@available(iOS 16.0, *)
func MakeFileBrowserView(localURL: URL?) -> FileBrowserView {
    FileBrowserView(viewModel: FileBrowserViewModel(localURL: localURL))
}

@available(iOS 16.0, *)
class FileBrowserViewModel: ObservableObject {
    let localURL: URL?
    @Published var files: [URL] = []
    @Published var showAlert = false
    @Published var selectedFileContent: String = ""

    init(localURL: URL?) {
        self.localURL = localURL

        let fileManager = FileManager.default

        guard let localURL = localURL else {
            return
        }

        do {
            let fileURLs = try fileManager.contentsOfDirectory(at: localURL, includingPropertiesForKeys: nil)
            self.files = fileURLs.sorted(by: { $0.lastPathComponent < $1.lastPathComponent })
        } catch {
            print("Error loading files: \(error)")
        }
    }

    func showFile(fileURL: URL) -> () -> Void {
        {
            do {
                self.selectedFileContent = String(try String(contentsOf: fileURL).prefix(10_000))
                self.showAlert = true
            } catch {
                print("Error reading file: \(error)")
            }
        }
    }
}

@available(iOS 16.0, *)
struct FileBrowserView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var viewModel: FileBrowserViewModel

    var body: some View {
        NavigationView {
            VStack {
                Text("Files Count: \(viewModel.files.count)")
                if viewModel.files.isEmpty {
                    Text("Folder doesn't exist or is empty")
                        .foregroundColor(.red)
                } else {
                    List(viewModel.files, id: \.self) { fileURL in
                        Button(action: viewModel.showFile(fileURL: fileURL)) {
                            Text(fileURL.lastPathComponent)
                        }
                    }
                }
            }
            .alert(isPresented: $viewModel.showAlert) {
                Alert(title: Text("File Content"), message: Text(viewModel.selectedFileContent), dismissButton: .default(Text("Close")))
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Close") {
                        dismiss()
                    }
                }
            }
        }
    }
}

@available(iOS 16.0, *)
struct FileBrowserView_Previews: PreviewProvider {
    static var previews: some View {
        FileBrowserView(viewModel: FileBrowserViewModel(localURL: nil))
    }
}
