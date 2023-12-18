//
//  Copyright © 2023 Dropbox. All rights reserved.
//

import SwiftUI

@available(iOS 16.0, *)
func MakeFileTextView(fileURL: URL?) -> FileTextView {
    FileTextView(viewModel: FileTextViewModel(fileURL: fileURL))
}

@available(iOS 16.0, *)
class FileTextViewModel: ObservableObject {
    @Published var fileContent: String = ""

    let fileURL: URL?
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    init(fileURL: URL?) {
        self.fileURL = fileURL
    }

    func updateFileContent() {
        DispatchQueue.global(qos: .userInitiated).async {
            if let fileURL = self.fileURL,
               let contents = try? String(contentsOf: fileURL).suffix(10_000) {
                DispatchQueue.main.async {
                    self.fileContent = String(contents)
                }
            } else {
                DispatchQueue.main.async {
                    self.fileContent = "Error: Unable to read file contents."
                }
            }
        }
    }

    func flushLogs() {
        DispatchQueue.global(qos: .userInitiated).async {
            guard let fileURL = self.fileURL else {
                return
            }

            do {
                try "".write(to: fileURL, atomically: true, encoding: .utf8)
                DispatchQueue.main.async {
                    self.fileContent = ""
                }
            } catch {
                DispatchQueue.main.async {
                    self.fileContent = "Error: Unable to flush logs."
                }
            }
        }
    }
}

@available(iOS 16.0, *)
struct FileTextView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var viewModel: FileTextViewModel

    var body: some View {
        NavigationView {
            VStack {
                Button("Flush Logs", action: viewModel.flushLogs)
                    .buttonStyle(BlueButton())
                    .fixedSize()
                    .padding()

                ScrollViewReader { scrollProxy in
                    ScrollView {
                        VStack(alignment: .leading) {
                            Text(viewModel.fileContent)
                                .font(.system(size: 9, design: .monospaced))
                            Text("").id("bottom")
                        }
                        .onReceive(viewModel.timer) { _ in
                            viewModel.updateFileContent()
                        }
                        .onAppear {
                            viewModel.updateFileContent()
                        }
                        .onChange(of: viewModel.fileContent) { _ in
                            scrollProxy.scrollTo("bottom", anchor: .bottom)
                        }
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
                }
            }.toolbar {
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
struct FileTextView_Previews: PreviewProvider {
    static var previews: some View {
        FileTextView(
            viewModel: FileTextViewModel(fileURL: URL(string: "/some/url")!)
        )
    }
}
