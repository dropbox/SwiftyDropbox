//
//  Copyright © 2023 Dropbox. All rights reserved.
//

import SwiftUI
import SwiftyDropbox

@available(iOS 16.0, *)
struct DebugBackgroundSession: View {
    @State var viewModel = DebugBackgroundSessionViewModel()
    @State var showFileBrowser = false
    @State var showLogBrowser = false

    let debugLogFileURL: URL

    var body: some View {
        VStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 3) {
                    HStack {
                        Button("Start Downloads", action: viewModel.startDownloads)
                        Button("Create Dropbox Folder", action: viewModel.createDropboxTestFolder)
                            .frame(maxWidth: .infinity, alignment: .trailing)
                    }
                    HStack {
                        Button("Start Uploads", action: viewModel.startUploads)
                        Button("Delete Dropbox Folder", action: viewModel.deleteDropboxTestFolder)
                            .frame(maxWidth: .infinity, alignment: .trailing)
                    }
                    HStack {
                        Button("Create Local Folder", action: viewModel.createLocalDownloadsFolder)
                        Button("Delete Local Downloads", action: viewModel.deleteLocalDownloads)
                            .frame(maxWidth: .infinity, alignment: .trailing)
                    }
                    HStack {
                        Text("Number of Downloads:")
                        Spacer(minLength: 100)
                        TextField("Enter number of downloads", value: $viewModel.numberOfDownloads, formatter: NumberFormatter())
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .keyboardType(.numbersAndPunctuation)
                            .submitLabel(.done)
                    }
                    HStack {
                        Text("Number of Uploads:")
                        Spacer(minLength: 100)
                        TextField("Enter number of uploads", value: $viewModel.numberOfUploads, formatter: NumberFormatter())
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .keyboardType(.numbersAndPunctuation)
                            .submitLabel(.done)
                    }
                    HStack {
                        Text("MB Size of Upload:")
                        Spacer(minLength: 100)
                        TextField("Enter a size in MB", text: viewModel.sizeOfUploadBinding)
                            .keyboardType(.numbersAndPunctuation)
                            .submitLabel(.done)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .padding()
                    }

                    Toggle(isOn: $viewModel.exitOnBackgrounding) {
                        Text("Exit on next didEnterBackground")
                    }
                    Button("View downloaded files", action: {
                        showFileBrowser = true
                    })
                    Button("View logs", action: {
                        showLogBrowser = true
                    })
                }
                .padding()
            }
        }
        .fullScreenCover(isPresented: $showFileBrowser) {
            FileBrowserView(localURL: TestConstants.localDownloadFolder)
        }
        .fullScreenCover(isPresented: $showLogBrowser) {
            FileTextView(fileURL: debugLogFileURL)
        }
        .onReceive(NotificationCenter.default.publisher(for: UIApplication.didEnterBackgroundNotification)) { _ in
            if viewModel.exitOnBackgrounding {
                DropboxClientsManager.logBackgroundSession("simulating a termination by the OS through `exit(0)`")
                exit(0)
            }
        }
    }
}

@available(iOS 16.0, *)
struct DebugBackgroundSession_Previews: PreviewProvider {
    static var previews: some View {
        DebugBackgroundSession(debugLogFileURL: URL(string: NSTemporaryDirectory())!)
    }
}
