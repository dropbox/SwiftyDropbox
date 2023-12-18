//
//  Copyright © 2023 Dropbox. All rights reserved.
//

import SwiftUI
import SwiftyDropbox

@available(iOS 16.0, *)
struct DebugBackgroundSession: View {
    @StateObject var viewModel = DebugBackgroundSessionViewModel()

    let debugLogFileURL: URL?

    var body: some View {
        VStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    debugActionButtons
                    debugTextFields
                    Toggle(isOn: $viewModel.exitOnBackgrounding) {
                        Text("Exit on next didEnterBackground")
                    }
                    Button("View downloaded files", action: {
                        viewModel.showFileBrowser = true
                    }).buttonStyle(BlueButton())
                    Button("View logs", action: {
                        viewModel.showLogBrowser = true
                    }).buttonStyle(BlueButton())
                }
                .padding()
            }
        }
        .fullScreenCover(isPresented: $viewModel.showFileBrowser) {
            MakeFileBrowserView(localURL: TestConstants.localDownloadFolder)
        }
        .fullScreenCover(isPresented: $viewModel.showLogBrowser) {
            MakeFileTextView(fileURL: debugLogFileURL)
        }
        .onReceive(NotificationCenter.default.publisher(for: UIApplication.didEnterBackgroundNotification)) { _ in
            if viewModel.exitOnBackgrounding {
                DropboxClientsManager.logBackgroundSession("simulating a termination by the OS through `exit(0)`")
                exit(0)
            }
        }
    }

    var debugActionButtons: some View {
        VStack {
            HStack {
                Button("Start Downloads", action: viewModel.startDownloads)
                Button("Create Dropbox Folder", action: viewModel.createDropboxTestFolder)
            }
            HStack {
                Button("Start Uploads", action: viewModel.startUploads)
                Button("Delete Dropbox Folder", action: viewModel.deleteDropboxTestFolder)
            }
            HStack {
                Button("Create Local Folder", action: viewModel.createLocalDownloadsFolder)
                Button("Delete Local Downloads", action: viewModel.deleteLocalDownloads)
            }
        }
        .buttonStyle(BlueButton())
    }

    var debugTextFields: some View {
        VStack {
            HStack {
                Text("Number of Downloads:")
                    .frame(maxWidth: .infinity, alignment: .leading)
                TextField("Enter number of downloads", value: $viewModel.numberOfDownloads, formatter: NumberFormatter())
                    .textFieldStyle(BackgroundDebugTextField())
            }
            HStack {
                Text("Number of Uploads:")
                    .frame(maxWidth: .infinity, alignment: .leading)
                TextField("Enter number of uploads", value: $viewModel.numberOfUploads, formatter: NumberFormatter())
                    .textFieldStyle(BackgroundDebugTextField())
            }
            HStack {
                Text("KB Size of Upload:")
                    .frame(maxWidth: .infinity, alignment: .leading)
                TextField("Enter a size in KB", text: $viewModel.sizeOfUpload)
                    .textFieldStyle(BackgroundDebugTextField())
            }
        }
    }
}

@available(iOS 16.0, *)
struct BlueButton: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .frame(maxWidth: .infinity)
            .font(.caption)
            .fontWeight(.bold)
            .padding()
            .background(configuration.isPressed ? .indigo : .blue)
            .foregroundStyle(.white)
            .clipShape(Capsule())
    }
}

@available(iOS 16.0, *)
struct BackgroundDebugTextField: TextFieldStyle {
    func _body(configuration: TextField<Self._Label>) -> some View {
        configuration
            .keyboardType(.numbersAndPunctuation)
            .submitLabel(.done)
            .textFieldStyle(RoundedBorderTextFieldStyle())
            .frame(maxWidth: .infinity)
    }
}

@available(iOS 16.0, *)
struct DebugBackgroundSession_Previews: PreviewProvider {
    static var previews: some View {
        DebugBackgroundSession(debugLogFileURL: nil)
    }
}
