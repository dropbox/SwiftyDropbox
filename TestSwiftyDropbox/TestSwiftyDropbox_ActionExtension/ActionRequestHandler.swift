///
/// Copyright (c) 2023 Dropbox, Inc. All rights reserved.
///

import MobileCoreServices
import SwiftyDropbox
import UIKit
import UniformTypeIdentifiers

class ActionRequestHandler: NSObject, NSExtensionRequestHandling {
    /*
     In order to use a background session in an App Extension you need to create an App Group
     and add that App Group to the entitlements for both the host app (TestSwiftyDropbox_iOS)
     and the extension (TestSwiftDropbox_ActionExtension).

     Additionally, you will need to test on a real device as background session behavior is buggy
     and/or broken on simulators. This means you will need to also generate a provisioning profile
     for the host app and extension that contains the App Group entitlement.

     Lastly, you will need to pass your Background Session ID and App Group into the SwiftyDropbox
     session configuration Below you will see a placeholders for this in TestData.swift
     of "<BACKGROUND_SESSION_ID>" and "<APP_GROUP_ID>". The Background Session ID is of your
     choosing and may or may not be the same as the one used in the host app depending on
     your use case.

     You can read more about all of this in the following resources:
     https://developer.apple.com/library/archive/documentation/General/Conceptual/ExtensibilityPG/ExtensionScenarios.html#//apple_ref/doc/uid/TP40014214-CH21-SW1
     https://developer.apple.com/documentation/foundation/nsurlsessionconfiguration/1409450-sharedcontaineridentifier
     */
    static let useBackgroundSession = false
    static let exitAfterUploadStart = false

    var extensionContext: NSExtensionContext?

    func runSwiftyDropboxTests(completion: @escaping () -> Void) {
        DropboxClientsManager.loggingClosure = { _, message in
            BackgroundTestLogger.log(message)
        }
        DropboxClientsManager.logBackgroundSession("Starting Dropbox actions in action extension")

        createClientIfNecessary()

        DropboxClientsManager.logBackgroundSession("Running test file actions in action extension")

        let runUpload = {
            self.performUpload(then: completion)
        }

        let runCreateTestFolder = {
            self.createTestFolder(then: runUpload)
        }

        let runDeleteTestFolder = {
            self.deleteTestFolder(then: runCreateTestFolder)
        }

        runDeleteTestFolder()
    }

    private func createClientIfNecessary() {
        let appKey = TestData.fullDropboxAppKey

        // Since `beginRequest(with:)` can be called multiple times, we need to check for existence before creating a client
        if ActionRequestHandler.useBackgroundSession && DropboxClientsManager.authorizedBackgroundClient == nil {
            DropboxClientsManager.setupWithAppKey(
                appKey,
                backgroundSessionIdentifier: TestData.extensionBackgroundSessionIdentifier,
                sharedContainerIdentifier: TestData.sharedContainerIdentifier,
                requestsToReconnect: { requestResults in
                    if #available(iOS 16.0, *) {
                        DebugBackgroundSessionViewModel.processReconnect(requestResults: requestResults)
                    }
                }
            )

            guard DropboxClientsManager.authorizedBackgroundClient != nil else {
                DropboxClientsManager.logBackgroundSession("Must log into TestSwiftyDropbox_iOS before using action extension.")
                return
            }
        } else if DropboxClientsManager.authorizedClient == nil {
            DropboxClientsManager.setupWithAppKey(appKey)

            guard DropboxClientsManager.authorizedClient != nil else {
                DropboxClientsManager.logBackgroundSession("Must log into TestSwiftyDropbox_iOS before using action extension.")
                return
            }
        }
    }

    private func createTestFolder(then next: @escaping () -> Void) {
        DropboxClientsManager.authorizedClient?.files.createFolderV2(path: TestConstants.dropboxTestFolder)
            .response { response, error in
                DropboxClientsManager.logBackgroundSession(DebugBackgroundSessionHelpers.summary(of: "createFolderV2", from: response, error: error))
                next()
            }
    }

    private func deleteTestFolder(then next: @escaping () -> Void) {
        DropboxClientsManager.authorizedClient?.files.deleteV2(path: TestConstants.dropboxTestFolder).response { response, error in
            DropboxClientsManager.logBackgroundSession(DebugBackgroundSessionHelpers.summary(of: "deleteV2", from: response, error: error))
            next()
        }
    }

    private func performUpload(then next: @escaping () -> Void) {
        var client: DropboxClient?
        if ActionRequestHandler.useBackgroundSession {
            client = DropboxClientsManager.authorizedBackgroundClient
        } else {
            client = DropboxClientsManager.authorizedClient
        }

        TestUtilities.createFileToUpload(sizeInKBs: 1_000)
        let fileName = "/test_action_extension.txt"
        let path = TestConstants.dropboxTestFolder + fileName
        let input = TestConstants.fileToUpload

        client?.files.upload(path: path, input: input).response { response, error in
            DropboxClientsManager.logBackgroundSession(DebugBackgroundSessionHelpers.summary(of: "upload", from: response, error: error))
            next()
        }

        if ActionRequestHandler.exitAfterUploadStart {
            exit(0)
        }
    }

    func beginRequest(with context: NSExtensionContext) {
        extensionContext = context

        runSwiftyDropboxTests { [weak self] in
            self?.completeAndCleanup()
        }
    }

    func completeAndCleanup() {
        extensionContext?.completeRequest(returningItems: nil, completionHandler: nil)
        extensionContext = nil
    }
}
