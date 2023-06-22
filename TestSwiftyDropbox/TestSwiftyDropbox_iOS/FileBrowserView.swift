//
//  Copyright © 2023 Dropbox. All rights reserved.
//

import SwiftUI

@available(iOS 16.0, *)
struct FileBrowserView: View {
    @Environment(\.presentationMode) var presentationMode
    let localURL: URL
    @State private var files: [URL] = []
    @State private var showAlert = false
    @State private var selectedFileContent: String = ""

    var body: some View {
        NavigationView {
            VStack {
                Text("Files Count: \(files.count)")
                if files.isEmpty {
                    Text("Folder doesn't exist or is empty")
                        .foregroundColor(.red)
                } else {
                    List(files, id: \.self) { fileURL in
                        Button(action: {
                            do {
                                selectedFileContent = String(try String(contentsOf: fileURL).prefix(10_000))
                                showAlert = true
                            } catch {
                                print("Error reading file: \(error)")
                            }
                        }) {
                            Text(fileURL.lastPathComponent)
                        }
                    }
                }
            }
            .onAppear(perform: loadFiles)
            .alert(isPresented: $showAlert) {
                Alert(title: Text("File Content"), message: Text(selectedFileContent), dismissButton: .default(Text("Close")))
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Close") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            }
        }
    }

    func loadFiles() {
        let fileManager = FileManager.default

        do {
            let fileURLs = try fileManager.contentsOfDirectory(at: localURL, includingPropertiesForKeys: nil)

            files = fileURLs.sorted(by: { $0.lastPathComponent < $1.lastPathComponent })
        } catch {
            print("Error loading files: \(error)")
        }
    }
}

@available(iOS 16.0, *)
struct FileBrowserView_Previews: PreviewProvider {
    static var previews: some View {
        FileBrowserView(localURL: URL(string: NSTemporaryDirectory())!)
    }
}
