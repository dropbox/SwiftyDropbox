//
//  Copyright © 2023 Dropbox. All rights reserved.
//

import SwiftUI

@available(iOS 16.0, *)
struct FileTextView: View {
    @Environment(\.presentationMode) var presentationMode
    @State private var fileContent: String = ""
    let fileURL: URL
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    var body: some View {
        NavigationView {
            VStack {
                Button("Flush Logs", action: flushLogs)
                    .foregroundColor(.blue)
                    .padding()

                ScrollViewReader { scrollProxy in
                    ScrollView {
                        VStack(alignment: .leading) {
                            Text(fileContent)
                                .font(.system(size: 9, design: .monospaced))
                            Text("").id("bottom")
                        }
                        .onReceive(timer) { _ in
                            updateFileContent()
                        }
                        .onAppear {
                            updateFileContent()
                        }
                        .onChange(of: fileContent) { _ in
                            scrollProxy.scrollTo("bottom", anchor: .bottom)
                        }
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
                }
            }.toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Close") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            }
        }
    }

    private func updateFileContent() {
        DispatchQueue.global(qos: .userInitiated).async {
            do {
                let contents = try String(contentsOf: fileURL).suffix(10_000)
                DispatchQueue.main.async {
                    self.fileContent = String(contents)
                }
            } catch {
                DispatchQueue.main.async {
                    self.fileContent = "Error: Unable to read file contents."
                }
            }
        }
    }

    private func flushLogs() {
        DispatchQueue.global(qos: .userInitiated).async {
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
struct FileTextView_Previews: PreviewProvider {
    static var previews: some View {
        FileTextView(fileURL: Bundle.main.url(forResource: "log-example", withExtension: "txt")!)
    }
}
