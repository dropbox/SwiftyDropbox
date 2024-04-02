# Dropbox for Swift

## Version 10.0.0 differs greatly from previous versions of the SDK. See [Changes in version 10.0.0](#changes-in-version-1000) and, if needed, [Migrating from dropbox-sdk-obj-c](#migrating-from-dropbox-sdk-obj-c).

The Official Dropbox Swift SDK for integrating with Dropbox [API v2](https://www.dropbox.com/developers/documentation/http/documentation) on iOS or macOS.

Full documentation [here](http://dropbox.github.io/SwiftyDropbox/api-docs/10.0.0/).

---

## Table of Contents

* [System requirements](#system-requirements)
* [Get started](#get-started)
  * [Register your application](#register-your-application)
  * [Obtain an OAuth 2.0 token](#obtain-an-oauth-20-token)
* [SDK distribution](#sdk-distribution)
  * [Swift Package Manager](#swift-package-manager)
  * [CocoaPods](#cocoapods)
* [Configure your project](#configure-your-project)
  * [Application `.plist` file](#application-plist-file)
  * [Handling the authorization flow](#handling-the-authorization-flow)
    * [Initialize a `DropboxClient` instance](#initialize-a-dropboxclient-instance)
    * [Begin the authorization flow](#begin-the-authorization-flow)
    * [Handle redirect back into SDK](#handle-redirect-back-into-sdk)
* [Try some API requests](#try-some-api-requests)
  * [Dropbox client instance](#dropbox-client-instance)
  * [Handle the API response](#handle-the-api-response)
  * [Request types](#request-types)
    * [RPC-style request](#rpc-style-request)
    * [Upload-style request](#upload-style-request)
    * [Download-style request](#download-style-request)
  * [Handling responses and errors](#handling-responses-and-errors)
    * [Route-specific errors](#route-specific-errors)
    * [Generic network request errors](#generic-network-request-errors)
    * [Response handling edge cases](#response-handling-edge-cases)
  * [Customizing network calls](#customizing-network-calls)
    * [Configure network client](#configure-network-client)
    * [Specify API call response queue](#specify-api-call-response-queue)
  * [`DropboxClientsManager` class](#dropboxclientsmanager-class)
    * [Single Dropbox user case](#single-dropbox-user-case)
    * [Multiple Dropbox user case](#multiple-dropbox-user-case)
* [Objective-C](#objective-c)
  * [Objective-C Compatibility Layer Distribution](#objective-c-compatibility-layer-distribution)
  * [Using the Objective-C Compatbility Layer](#using-the-objective-c-compatbility-layer)
  * [Migrating from dropbox-sdk-obj-c](#migrating-from-dropbox-sdk-obj-c)
* [Changes in version 10.0.0](#changes-in-version-1000)
* [Examples](#examples)
* [Documentation](#documentation)
* [Stone](#stone)
* [Modifications](#modifications)
* [App Store Connect Privacy Labels](#app-store-connect-privacy-labels)
* [Bugs](#bugs)

---

## System requirements

- iOS 12.0+
- macOS 10.13+
- Xcode 13.3+
- Swift 5.6+

## Get Started

### Register your application

Before using this SDK, you should register your application in the [Dropbox App Console](https://dropbox.com/developers/apps). This creates a record of your app with Dropbox that will be associated with the API calls you make.

### Obtain an OAuth 2.0 token

All requests need to be made with an OAuth 2.0 access token. An OAuth token represents an authenticated link between a Dropbox app and
a Dropbox user account or team.

Once you've created an app, you can go to the App Console and manually generate an access token to authorize your app to access your own Dropbox account.
Otherwise, you can obtain an OAuth token programmatically using the SDK's pre-defined auth flow. For more information, [see below](https://github.com/dropbox/SwiftyDropbox#handling-the-authorization-flow).

---

## SDK distribution

You can integrate the Dropbox Swift SDK into your project using one of several methods.

### Swift Package Manager

The Dropbox Swift SDK can be installed in your project using [Swift Package Manager](https://swift.org/package-manager/) by specifying the Dropbox Swift SDK repository URL:

```
https://github.com/dropbox/SwiftyDropbox.git
```

Refer to [Apple's "Adding Package Dependencies to Your App" documentation](https://developer.apple.com/documentation/xcode/adding_package_dependencies_to_your_app) for more information.


### CocoaPods

To use [CocoaPods](http://cocoapods.org), a dependency manager for Cocoa projects, you should first install it using the following command:

```bash
$ gem install cocoapods
```

Then navigate to the directory that contains your project and create a new file called `Podfile`. You can do this either with `pod init`, or open an existing Podfile, and then add `pod 'SwiftyDropbox'` to the main loop. Your Podfile should look something like this:

```ruby
use_frameworks!

target '<YOUR_PROJECT_NAME>' do
    pod 'SwiftyDropbox'
end
```
If your project contains Objective-C code that will need to have access to Dropbox SDK there is a separate pod called `SwiftyDropboxObjC` that contains an Objective-C compatibility layer for the SDK. Add this pod to your `Podfile` (in addition to `SwiftyDropbox` or on its own). For more information refer to the [Objective-C](#objective-c) section of this README.

Then, run the following command to install the dependency:

```bash
$ pod install
```

Once your project is integrated with the Dropbox Swift SDK, you can pull SDK updates using the following command:

```bash
$ pod update
```

---

## Configure your project

Once you have integrated the Dropbox Swift SDK into your project, there are a few additional steps to take before you can begin making API calls.

### Application `.plist` file

If you are compiling on iOS SDK 9.0, you will need to modify your application's `.plist` to handle Apple's [new security changes](https://developer.apple.com/videos/wwdc/2015/?id=703) to the `canOpenURL` function. You should
add the following code to your application's `.plist` file:

```
<key>LSApplicationQueriesSchemes</key>
    <array>
        <string>dbapi-8-emm</string>
        <string>dbapi-2</string>
    </array>
```
This allows the Swift SDK to determine if the official Dropbox iOS app is installed on the current device. If it is installed, then the official Dropbox iOS app can be used to programmatically obtain an OAuth 2.0 access token.

Additionally, your application needs to register to handle a unique Dropbox URL scheme for redirect following completion of the OAuth 2.0 authorization flow. This URL scheme should have the format `db-<APP_KEY>`, where `<APP_KEY>` is your
Dropbox app's app key, which can be found in the [App Console](https://dropbox.com/developers/apps).

You should add the following code to your `.plist` file (but be sure to replace `<APP_KEY>` with your app's app key):

```
<key>CFBundleURLTypes</key>
    <array>
        <dict>
            <key>CFBundleURLSchemes</key>
            <array>
                <string>db-<APP_KEY></string>
            </array>
            <key>CFBundleURLName</key>
            <string></string>
        </dict>
    </array>
```

After you've made the above changes, your application's `.plist` file should look something like this:

<p align="center">
  <img src="https://github.com/dropbox/SwiftyDropbox/blob/master/Images/InfoPlistExample.png?raw=true" alt="Info .plist Example"/>
</p>

---

### Handling the authorization flow

There are three methods to programmatically retrieve an OAuth 2.0 access token:

* **Direct auth** (iOS only): This launches the official Dropbox iOS app (if installed), authenticates via the official app, then redirects back into the SDK
* **Safari view controller auth** (iOS only): This launches a `SFSafariViewController` to facillitate the auth flow. This is desirable because it is safer for the end-user, and pre-existing session data can be used to avoid requiring the user to re-enter their Dropbox credentials.
* **Redirect to external browser** (macOS only): This launches the user's default browser to facillitate the auth flow. This is also desirable because it is safer for the end-user, and pre-existing session data can be used to avoid requiring the user to re-enter their Dropbox credentials.

To facilitate the above authorization flows, you should take the following steps:

---

#### Initialize a `DropboxClient` instance

From your application delegate:

_SwiftUI note: You may need to create an Application Delegate if your application doesn't have one._

##### iOS

```Swift
import SwiftyDropbox

func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
    DropboxClientsManager.setupWithAppKey("<APP_KEY>")
    return true
}
```

##### macOS

```Swift
import SwiftyDropbox

func applicationDidFinishLaunching(_ aNotification: Notification) {
    DropboxClientsManager.setupWithAppKeyDesktop("<APP_KEY>")
}
```

---

#### Begin the authorization flow

You can commence the auth flow by calling `authorizeFromControllerV2:controller:openURL` method in your application's
view controller. Note that the controller reference will be weakly held. For SwiftUI applications nil can be passed in for the controller argument and the app's root view controller will be used to present the flow.

From your view controller:

##### iOS

```Swift
import SwiftyDropbox

func myButtonInControllerPressed() {
    // OAuth 2 code flow with PKCE that grants a short-lived token with scopes, and performs refreshes of the token automatically.
    let scopeRequest = ScopeRequest(scopeType: .user, scopes: ["account_info.read"], includeGrantedScopes: false)
    DropboxClientsManager.authorizeFromControllerV2(
        UIApplication.shared,
        controller: self,
        loadingStatusDelegate: nil,
        openURL: { (url: URL) -> Void in UIApplication.shared.open(url, options: [:], completionHandler: nil) },
        scopeRequest: scopeRequest
    )
}

```

##### macOS

```Swift
import SwiftyDropbox

func myButtonInControllerPressed() {
    // OAuth 2 code flow with PKCE that grants a short-lived token with scopes, and performs refreshes of the token automatically.
    let scopeRequest = ScopeRequest(scopeType: .user, scopes: ["account_info.read"], includeGrantedScopes: false)
    DropboxClientsManager.authorizeFromControllerV2(
        sharedApplication: NSApplication.shared,
        controller: self,
        loadingStatusDelegate: nil,
        openURL: {(url: URL) -> Void in NSWorkspace.shared.open(url)},
        scopeRequest: scopeRequest
    )
}
```

Beginning the authentication flow via in-app webview will launch a window like this:


<p align="center">
  <img src="https://github.com/dropbox/SwiftyDropbox/blob/master/Images/OAuthFlowInit.png?raw=true" alt="Auth Flow Init Example"/>
</p>

---

#### Handle redirect back into SDK

To handle the redirection back into the Swift SDK once the authentication flow is complete, you should add the following code in your application's delegate:

_SwiftUI note: You may need to create an Application Delegate if your application doesn't have one._

##### iOS

```Swift
import SwiftyDropbox

func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
    let oauthCompletion: DropboxOAuthCompletion = {
      if let authResult = $0 {
          switch authResult {
          case .success:
              print("Success! User is logged into DropboxClientsManager.")
          case .cancel:
              print("Authorization flow was manually canceled by user!")
          case .error(_, let description):
              print("Error: \(String(describing: description))")
          }
      }
    }
    let canHandleUrl = DropboxClientsManager.handleRedirectURL(url, includeBackgroundClient: false, completion: oauthCompletion)
    return canHandleUrl
}

```
Or if your app is iOS13+, or your app also supports Scenes, add the following code into your application's main scene delegate:

Note: You may need to create a Scene Delegate if your application doesn't have one._
```Swift
import SwiftyDropbox

func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
     let oauthCompletion: DropboxOAuthCompletion = {
      if let authResult = $0 {
          switch authResult {
          case .success:
              print("Success! User is logged into DropboxClientsManager.")
          case .cancel:
              print("Authorization flow was manually canceled by user!")
          case .error(_, let description):
              print("Error: \(String(describing: description))")
          }
      }
    }

    for context in URLContexts {
        // stop iterating after the first handle-able url
        if DropboxClientsManager.handleRedirectURL(context.url, includeBackgroundClient: false, completion: oauthCompletion) { break }
    }
}
```

##### macOS

```Swift
import SwiftyDropbox

func applicationDidFinishLaunching(_ aNotification: Notification) {
    ...... // code outlined above goes here

    NSAppleEventManager.shared().setEventHandler(self,
                                                 andSelector: #selector(handleGetURLEvent),
                                                 forEventClass: AEEventClass(kInternetEventClass),
                                                 andEventID: AEEventID(kAEGetURL))
}

func handleGetURLEvent(_ event: NSAppleEventDescriptor?, replyEvent: NSAppleEventDescriptor?) {
    if let aeEventDescriptor = event?.paramDescriptor(forKeyword: AEKeyword(keyDirectObject)) {
        if let urlStr = aeEventDescriptor.stringValue {
            let url = URL(string: urlStr)!
            let oauthCompletion: DropboxOAuthCompletion = {
                if let authResult = $0 {
                    switch authResult {
                    case .success:
                        print("Success! User is logged into Dropbox.")
                    case .cancel:
                        print("Authorization flow was manually canceled by user!")
                    case .error(_, let description):
                        print("Error: \(String(describing: description))")
                    }
                }
            }
            DropboxClientsManager.handleRedirectURL(url, includeBackgroundClient: false, completion: oauthCompletion)
            // this brings your application back the foreground on redirect
            NSApp.activate(ignoringOtherApps: true)
        }
    }
}
```

After the end user signs in with their Dropbox login credentials via the in-app webview, they will see a window like this:


<p align="center">
  <img src="https://github.com/dropbox/SwiftyDropbox/blob/master/Images/OAuthFlowApproval.png?raw=true" alt="Auth Flow Approval Example"/>
</p>

If they press **Allow** or **Cancel**, the `db-<APP_KEY>` redirect URL will be launched from the webview, and will be handled in your application
delegate's `application:handleOpenURL` method, from which the result of the authorization can be parsed.

Now you're ready to begin making API requests!

---

## Try some API requests

Once you have obtained an OAuth 2.0 token, you can try some API v2 calls using the Swift SDK.

### Dropbox client instance

Start by creating a reference to the `DropboxClient` or `DropboxTeamClient` instance that you will use to make your API calls.

```Swift
import SwiftyDropbox

// Reference after programmatic auth flow
let client = DropboxClientsManager.authorizedClient
```

or

```Swift
import SwiftyDropbox

// Initialize with manually retrieved auth token
let client = DropboxClient(accessToken: "<MY_ACCESS_TOKEN>")
```

---

### Handle the API response

The Dropbox [User API](https://www.dropbox.com/developers/documentation/http/documentation) and [Business API](https://www.dropbox.com/developers/documentation/http/teams) have three types of requests: RPC, Upload and Download.

The response handlers for each request type are similar to one another. The arguments for the handler blocks are as follows:
* **route result type** (`Void` if the route does not have a return type)
* **network error** (either a route-specific error or generic network error)
* **output content** (`URL` / `Data` reference to downloaded output for Download-style endpoints only)

Note: Response handlers are required for all endpoints. Progress handlers, on the other hand, are optional for all endpoints.

#### Swift Concurrency

As of the 10.0.0 release, all of the request types also support Swift Concurrency (`async`/`await`) via the async `response()` function.

```swift
let response = try await client.files.createFolder(path: "/test/path/in/Dropbox/account").response()
```

---

### Request types

#### RPC-style request
```Swift
client.files.createFolder(path: "/test/path/in/Dropbox/account").response { response, error in
    if let response = response {
        print(response)
    } else if let error = error {
        print(error)
    }
}
```

---

#### Upload-style request
```Swift
let fileData = "testing data example".data(using: String.Encoding.utf8, allowLossyConversion: false)!

let request = client.files.upload(path: "/test/path/in/Dropbox/account", input: fileData)
    .response { response, error in
        if let response = response {
            print(response)
        } else if let error = error {
            print(error)
        }
    }
    .progress { progressData in
        print(progressData)
    }

// in case you want to cancel the request
if someConditionIsSatisfied {
    request.cancel()
}
```

---

#### Download-style request
```Swift
// Download to URL
let fileManager = FileManager.default
let directoryURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
let destination = directoryURL.appendingPathComponent("myTestFile")

client.files.download(path: "/test/path/in/Dropbox/account", overwrite: true, destination: destination)
    .response { response, error in
        if let response = response {
            print(response)
        } else if let error = error {
            print(error)
        }
    }
    .progress { progressData in
        print(progressData)
    }


// Download to Data
client.files.download(path: "/test/path/in/Dropbox/account")
    .response { response, error in
        if let response = response {
            let responseMetadata = response.0
            print(responseMetadata)
            let fileContents = response.1
            print(fileContents)
        } else if let error = error {
            print(error)
        }
    }
    .progress { progressData in
        print(progressData)
    }
```

---

### Handling responses and errors

Dropbox API v2 deals largely with two data types: **structs** and **unions**. Broadly speaking, most route **arguments** are struct types and most route **errors** are union types.

**NOTE:** In this context, "structs" and "unions" are terms specific to the Dropbox API, and not to any of the languages that are used to query the API, so you should avoid thinking of them in terms of their Swift definitions.

**Struct types** are "traditional" object types, that is, composite types made up of a collection of one or more instance fields. All public instance fields are accessible at runtime, regardless of runtime state.

**Union types**, on the other hand, represent a single value that can take on multiple value types, depending on state. We capture all of these different type scenarios under one "union object", but that object will exist only as one type at runtime. Each union state type, or **tag**, may have an associated value (if it doesn't, the union state type is said to be **void**). Associated value types can either be primitives, structs or unions. Although the Swift SDK represents union types as objects with multiple instance fields, at most one instance field is accessible at runtime, depending on the tag state of the union.

For example, the [/delete](https://www.dropbox.com/developers/documentation/http/documentation#files-delete) endpoint returns an error, `Files.DeleteError`, which is a union type. The `Files.DeleteError` union can take on two different tag states: `path_lookup`
(if there is a problem looking up the path) or `path_write` (if there is a problem writing -- or in this case deleting -- to the path). Here, both tag states have non-void associated values (of types `Files.LookupError` and `Files.WriteError`, respectively).

In this way, one union object is able to capture a multitude of scenarios, each of which has their own value type.

To properly handle union types, you should pass each union through a switch statement, and check each possible tag state associated with the union. Once you have determined the current tag state of the union, you can then access the value associated with that tag state (provided there exists an associated value type, i.e., it's not **void**).

---

#### Route-specific errors
```Swift
client.files.deleteV2(path: "/test/path/in/Dropbox/account").response { response, error in
    if let response = response {
        print(response)
    } else if let error = error {
        switch error as CallError {
        case .routeError(let boxed, let userMessage, let errorSummary, let requestId):
            print("RouteError[\(requestId)]:")

            switch boxed.unboxed as Files.DeleteError {
            case .pathLookup(let lookupError):
                switch lookupError {
                case .notFound:
                    print("There is nothing at the given path.")
                case .notFile:
                    print("We were expecting a file, but the given path refers to something that isn't a file.")
                case .notFolder:
                    print("We were expecting a folder, but the given path refers to something that isn't a folder.")
                case .restrictedContent:
                    print("The file cannot be transferred because the content is restricted...")
                case .malformedPath(let malformedPath):
                    print("Malformed path: \(malformedPath)")
                case .other:
                    print("Unknown")
                }
            case .pathWrite(let writeError):
                print("WriteError: \(writeError)")
                // you can handle each `WriteError` case like the `DeleteError` cases above
            case .tooManyWriteOperations:
                print("Another write operation occurring at the same time prevented this from succeeding.")
            case .tooManyFiles:
                print("There are too many files to delete.")
            case .other:
                print("Unknown")
            }
        case .internalServerError(let code, let message, let requestId):
            ....
            ....
            // a not route-specific error occurred
        ....
        ....
        ....
        }
    }
}
```

---

#### Generic network request errors

In the case of a network error, errors are either specific to the endpoint (as shown above) or more generic errors.

To determine if an error is route-specific or not, the error object should be cast as a `CallError`, and depending on the type of error, handled in the appropriate switch statement.

```Swift
client.files.deleteV2(path: "/test/path/in/Dropbox/account").response { response, error in
    if let response = response {
        print(response)
    } else if let error = error {
        switch error as CallError {
        case .routeError(let boxed, let userMessage, let errorSummary, let requestId):
            // a route-specific error occurred
            // see handling above
            ....
            ....
            ....
        case .internalServerError(let code, let message, let requestId):
            print("InternalServerError[\(requestId)]: \(code): \(message)")
        case .badInputError(let message, let requestId):
            print("BadInputError[\(requestId)]: \(message)")
        case .authError(let authError, let userMessage, let errorSummary, let requestId):
            print("AuthError[\(requestId)]: \(userMessage) \(errorSummary) \(authError)")
        case .accessError(let accessError, let userMessage, let errorSummary, let requestId):
            print("AccessError[\(requestId)]: \(userMessage) \(errorSummary) \(accessError)")
        case .rateLimitError(let rateLimitError, let userMessage, let errorSummary, let requestId):
            print("RateLimitError[\(requestId)]: \(userMessage) \(errorSummary) \(rateLimitError)")
        case .httpError(let code, let message, let requestId):
            print("HTTPError[\(requestId)]: \(code): \(message)")
        case .clientError(let error):
            print("ClientError: \(error)")
        }
    }
}
```

---

#### Response handling edge cases

Some routes return union types as result types, so you should be prepared to handle these results in the same way that you handle union route errors. Please consult the [documentation](https://www.dropbox.com/developers/documentation/http/documentation)
for each endpoint that you use to ensure you are properly handling the route's response type.

A few routes return result types that are **datatypes with subtypes**, that is, structs that can take on multiple state types like unions.

For example, the [/delete](https://www.dropbox.com/developers/documentation/http/documentation#files-delete) endpoint returns a generic `Metadata` type, which can exist either as a `FileMetadata` struct, a `FolderMetadata` struct, or a `DeletedMetadata` struct.
To determine at runtime which subtype the `Metadata` type exists as, pass the object through a switch statement, and check for each possible class, with the result casted accordingly. See below:

```Swift
client.files.deleteV2(path: "/test/path/in/Dropbox/account").response { response, error in
    if let response = response {
        switch response {
        case let fileMetadata as Files.FileMetadata:
            print("File metadata: \(fileMetadata)")
        case let folderMetadata as Files.FolderMetadata:
            print("Folder metadata: \(folderMetadata)")
        case let deletedMetadata as Files.DeletedMetadata:
            print("Deleted entity's metadata: \(deletedMetadata)")
        }
    } else if let error = error {
        switch error as CallError {
        case .routeError(let boxed, let userMessage, let errorSummary, let requestId):
            // a route-specific error occurred
            // see handling above
        case .internalServerError(let code, let message, let requestId):
            ....
            ....
            // a not route-specific error occurred
            // see handling above
        ....
        ....
        ....
        }
    }
}
```

This `Metadata` object is known as a **datatype with subtypes** in our API v2 documentation.

Datatypes with subtypes are a way combining structs and unions. Datatypes with subtypes are struct objects that contain a tag, which specifies which subtype the object exists as at runtime. The reason we have this construct, as with unions, is so we can capture a multitude of scenarios with one object.

In the above example, the `Metadata` type can exists as `FileMetadata`, `FolderMetadata` or `DeleteMetadata`. Each of these types have common instances fields like "name" (the name for the file, folder or deleted type), but also instance fields that are specific to the particular subtype. In order to leverage inheritance, we set a common supertype called `Metadata` which captures all of the common instance fields, but also has a tag instance field, which specifies which subtype the object currently exists as.

In this way, datatypes with subtypes are a hybrid of structs and unions. Only a few routes return result types like this.

---

### Customizing network calls

#### Configure network client

It is possible to configure the networking client used by the SDK to make API requests. You can supply custom fields like a custom user agent or custom session configurations, or a custom auth challenge handler. See below:

##### iOS
```Swift
import SwiftyDropbox

let transportClient = DropboxTransportClientImpl(accessToken: "<MY_ACCESS_TOKEN>",
                                             baseHosts: nil,
                                             userAgent: "CustomUserAgent",
                                             selectUser: nil,
                                             sessionConfiguration: mySessionConfiguration,
                                             longpollSessionConfiguration: myLongpollSessionConfiguration,
                                             authChallengeHandler: nil)

DropboxClientsManager.setupWithAppKey("<APP_KEY>", transportClient: transportClient)
```

##### macOS
```Swift
import SwiftyDropbox

let transportClient = DropboxTransportClientImpl(accessToken: "<MY_ACCESS_TOKEN>",
                                             baseHosts: nil,
                                             userAgent: "CustomUserAgent",
                                             selectUser: nil,
                                             sessionConfiguration: mySessionConfiguration,
                                             longpollSessionConfiguration: myLongpollSessionConfiguration,
                                             authChallengeHandler: nil)

DropboxClientsManager.setupWithAppKeyDesktop("<APP_KEY>", transportClient: transportClient)
```

#### Specify API call response queue

By default, response/progress handler code runs on the main thread. You can set a custom response queue for each API call that you make via the `response` method, in the event want your response/progress handler code to run on a different thread:

```Swift
let client = DropboxClientsManager.authorizedClient!

client.files.listFolder(path: "").response(queue: DispatchQueue(label: "MyCustomSerialQueue")) { response, error in
    if let result = response {
        print(Thread.current)  // Output: <NSThread: 0x61000007bec0>{number = 4, name = (null)}
        print(Thread.main)     // Output: <NSThread: 0x608000070100>{number = 1, name = (null)}
        print(result)
    }
}
```

#### Mock API responses in tests

When testing code that depends upon the SDK, it can be useful to mock arbitrary API responses from JSON fixtures. We recommend using dependency injection rather than accessing the client via the convenience singletons. Note that the mocks are not public, they are only available in tests when SwiftyDropbox is imported using the `@testable` attribute.

```Swift
@testable import SwiftyDropbox

let transportClient = MockDropboxTransportClient()
let dropboxClient = DropboxClient(transportClient: transportClient)

// your feature under test
let commentClient = CommentClient(apiClient: dropboxClient)

let expectation = expectation(description: "added comment")

// function of your feature that relies upon Dropbox api response
commentClient.addComment(
    forIdentifier: identifier,
    commentId: "pendingCommentId",
    threadId: nil,
    message: "hello world",
    mentions: [],
    annotation: nil
) { result in
    XCTAssertEqual(result.commentId, "thread-1")
    XCTAssertNil(result.error)
    addCommentExpectation.fulfill()
}

let mockInput: MockInput = .success(
    json: ["id": "thread-1", "status": 1]
)

let request = try XCTUnwrap(transportClient.getLastRequest())
try request.handleMockInput(mockInput)

wait(for: [expectation], timeout: 1.0)
```

---

### Supporting background networking

Versions 10.0 and higher support iOS background networking from applications and their extensions.

#### Initialization

To create a background client, provide a background session identifier. To use a shared container, specify that as well.

```Swift
import SwiftyDropbox

DropboxClientsManager.setupWithAppKey(
    "<APP_KEY>",
    backgroundSessionIdentifier: "<BACKGROUND_SESSION_IDENTIFIER>"
)
```

If you're setting up a background client from an app extension, you'll need to specify a shared container identifier and configure and app group or keychain sharing appropriately.
```Swift
DropboxClientsManager.setupWithAppKey(
    "<APP_KEY>",
    backgroundSessionIdentifier: "<BACKGROUND_SESSION_IDENTIFIER>"
    sharedContainerIdentifier: "<SHARED_CONTAINER_IDENTIFIER>"
)
```
 Apps in an app group automatically have keychain sharing. App groups are required for using a shared container, which is necessary if your applications will be downloading files using background sessions in extensions. See:
- https://developer.apple.com/documentation/xcode/configuring-app-groups
- https://developer.apple.com/documentation/xcode/configuring-keychain-sharing

#### Making requests
Make requests like you would with a foreground client.

```Swift
let client = DropboxClientsManager.authorizedBackgroundClient!

client.files.download(path: path, overwrite: true, destination: destinationUrl) {
    if let result = response {
        print(result)
    }
}
```

#### Customizing requests
Set background session related properties on requests for fine-grained control.

```Swift
client.files.download(path: path, overwrite: true, destination: destinationUrl)
    .persistingString(string: "<DATA_AVAILABLE_ACROSS_APP_SESSIONS>")
    .settingEarliestBeginDate(date: .addingTimeInterval(fiveSeconds))
    .response { response, error in
{
    if let result = response {
        print(result)
    }
})
```

#### Reconnecting to requests across app sessions
As background requests potentially span app sessions, the app will recieve `AppDelegate.application(_:handleEventsForBackgroundURLSession:completionHandler:)` when woken to handle events. SwiftyDropbox can reconnect completion handlers to requests. The application must set up the `authorizedBackgroundClient` prior to attempting reconnection.

In the reconnection block you're recieving a heterogenous collection of the routes requested on the background session. Handling the response will likely require context that must be persisted across sessions. You can use `.persistingString(string:)` and `.clientPersistedString` on request to store this context. Depending on your use case you may need to persist additional context in your application.

```Swift
    func application(_ application: UIApplication, handleEventsForBackgroundURLSession identifier: String, completionHandler: @escaping () -> Void) {
        DropboxClientsManager.handleEventsForBackgroundURLSession(
            with: identifier,
            creationInfos: [],
            completionHandler: completionHandler,
            requestsToReconnect: { requestResults in
                processReconnect(requestResults: RequestResults)
            }
        )
    }

    static func processReconnect(requestResults: ([Result<DropboxBaseRequestBox, ReconnectionError>])) {
        let successfulReturnedRequests = requestResults.compactMap { result -> DropboxBaseRequestBox? in
            switch result {
            case .success(let requestBox):
                return requestBox
            case .failure(let error):
                // handle error
                return nil
            }
        }

        for request in successfulReturnedRequests {
            switch request {
            case .download(let downloadRequest):
                downloadRequest.response { response, error in
                    // handle response
                }
            case .upload(let uploadRequest):
                uploadRequest.response { response, error in
                    // handle response
                }
            // or .downloadZip, .paperCreate, .getSharedLinkFile etc.
            }
        }
    }
```

In the event that the requests originated from an App Extension, SwiftyDropbox must recreate the extension background client in order to reconnect the requests.

```Swift
    func application(_ application: UIApplication, handleEventsForBackgroundURLSession identifier: String, completionHandler: @escaping () -> Void) {
        let extensionCreationInfo: BackgroundExtensionSessionCreationInfo = .init(defaultInfo: .init(
            backgroundSessionIdentifier: "<EXTENSION_BACKGROUND_SESSION_IDENTIFIER>",
            sharedContainerIdentifier: "<EXTENSION_SHARED_CONTAINER_IDENTIFIER>"
        ))

        DropboxClientsManager.handleEventsForBackgroundURLSession(
            with: identifier,
            creationInfos: [extensionCreationInfo],
            completionHandler: completionHandler,
            requestsToReconnect: { requestResults in
                processReconnect(requestResults: RequestResults)
            }
        )
    }
```

#### Debugging
Background sessions are difficult to debug. Both simulators and the Xcode debugger will cause the application to behave in meaningfully different ways–verification of correct reconnection behavior should always take place on a physical device without the debugger connected. Logs to console can be viewed via Xcode -> Window -> Devices and Simulators and are a good bet for gaining insights here. Force quitting the application will disqualify it from continuing to do work in the background.

For a good discussion of this, see https://developer.apple.com/forums/thread/14855.

#### Persistence
SwiftyDropbox tracks state and orchestrates reconnection by writing a JSON string to `URLSessionTask.taskDescription` a property that `URLSession` itself persists across app sessions.

Above, in Customizing Requests, is an example of the ability of a client of SwiftyDropbox to persist its own arbitrary strings alongside SwiftyDropbox's private use of this field. This could be useful for storing the information needed to reconstruct a completion handler for a task after reconnection.

Depending on the needs of the application, this lightweight solution may be insufficient persistent bookkeeping, and the application may build independate private persistence mapping state to an id stored on the request. This could be useful in the event that a failure occurs where URLSession itself has lost track of the transfer and it must be recreated.

See https://developer.apple.com/forums/thread/11554 for further discussion.

---


### `DropboxClientsManager` class

The Swift SDK includes a convenience class, `DropboxClientsManager`, for integrating the different functions of the SDK into one class.

#### Single Dropbox user case

For most apps, it is reasonable to assume that only one Dropbox account (and access token) needs to be managed at a time. In this case, the `DropboxClientsManager` flow looks like this:

* call `setupWithAppKey`/`setupWithAppKeyDesktop` (or `setupWithTeamAppKey`/`setupWithTeamAppKeyDesktop`) in integrating app's app delegate
* client manager determines whether any access tokens are stored -- if any exist, one token is arbitrarily chosen to use
* if no token is found, call `authorizeFromControllerV2` to initiate the OAuth flow
* if auth flow is initiated, call `handleRedirectURL` (or `handleRedirectURLTeam`) in integrating app's app delegate to handle auth redirect back into the app and store the retrieved access token (using a `DropboxOAuthManager` instance)
* client manager instantiates a `DropboxTransportClient` (if not supplied by the user)
* client manager instantiates a `DropboxClient` (or `DropboxTeamClient`) with the transport client as a field

The `DropboxClient` (or `DropboxTeamClient`) is then used to make all of the desired API calls.

* On `DropboxClientsManager`, call `unlinkClients` to logout Dropbox user and clear all access tokens

#### Multiple Dropbox user case

For some apps, it is necessary to manage more than one Dropbox account (and access token) at a time. In this case, the `DropboxClientsManager` flow looks like this:

* access token uids are managed by the app that is integrating with the SDK for later lookup
* call `setupWithAppKeyMultiUser`/`setupWithAppKeyMultiUserDesktop` (or `setupWithTeamAppKeyMultiUser`/`setupWithTeamAppKeyMultiUserDesktop`) in integrating app's app delegate
    * _SwiftUI note: You may need to create an Application Delegate if your application doesn't have one._
* client manager determines whether an access token is stored with the`tokenUid` as a key -- if one exists, this token is chosen to use
* if no token is found, call `authorizeFromControllerV2` to initiate the OAuth flow
* if auth flow is initiated, call `handleRedirectURL` (or `handleRedirectURLTeam`) in integrating app's app delegate to handle auth redirect back into the app and store the retrieved access token (using a `DropboxOAuthManager` instance)
    * _SwiftUI note: You may need to create an Application Delegate if your application doesn't have one._
* at this point, the app that is integrating with the SDK should persistently save the `tokenUid` from the `DropboxAccessToken` field of the `DropboxOAuthResult` object returned from the `handleRedirectURL` (or `handleRedirectURLTeam`) method
* `tokenUid` can be reused either to authorize a new user mid-way through an app's lifecycle via `reauthorizeClient` (or `reauthorizeTeamClient`) or when the app initially launches via `setupWithAppKeyMultiUser`/`setupWithAppKeyMultiUserDesktop` (or `setupWithTeamAppKeyMultiUser`/`setupWithTeamAppKeyMultiUserDesktop`)
* client manager instantiates a `DropboxTransportClient` (if not supplied by the user)
* client manager instantiates a `DropboxClient` (or `DropboxTeamClient`) with the transport client as a field

The `DropboxClient` (or `DropboxTeamClient`) is then used to make all of the desired API calls.

* On `DropboxClientsManager` call `resetClients` to logout Dropbox user but not clear any access tokens
* if specific access tokens need to be removed, use the `clearStoredAccessToken` method in `DropboxOAuthManager`

---
## Objective-C

If you need to interact with the Dropbox SDK in Objective-C code there is an Objective-C compatibility layer for the SDK that can be used.

### Objective-C Compatibility Layer Distribution

#### Swift Package Manager

The Objective-C compatibility layer is in the same package outlined in [SDK distribution](#sdk-distribution). After adding the package you will see a target named `SwiftyDropboxObjC` that can be added in the same way as the Swift SDK and used in its place.

#### Cocoapods

For cocoapods, in your Podfile, simply specify `SwiftyDropboxObjC` instead of (or in addition to) `SwiftyDropbox`.

```ruby
use_frameworks!

target '<YOUR_PROJECT_NAME>' do
    pod 'SwiftyDropboxObjC', '~> 10.0.7'
end
```

### Using the Objective-C Compatbility Layer

The Objective-C interface was built to mimic the Swift interface as closely as possible while still maintaining good Objective-C patterns and practices (for example full verbose names instead of the namespacing relied on in Swift). Other than the naming and some other small tweaks to accomodate Objective-C the usage of the SDK should be extremely similar in both languages, thus the instructions above should apply even when in Objective-C.

An example of the differences between Swift and Objective-C:

Swift:
```Swift
import SwiftyDropbox

let userSelectArg = Team.UserSelectorArg.email("some@email.com")
DropboxClientsManager.team.membersGetInfo(members: [userSelectArg]).response { response, error in
    if let result = response {
        // Handle result
    } else {
        // Handle error
    }
}
```

Objective-C:
```objc
@import SwiftyDropboxObjC;

DBXTeamUserSelectorArgEmail *selector = [[DBXTeamUserSelectorArgEmail alloc] init:@"some@email.com"]
[[DBXDropboxClientsManager.authorizedTeamClient.team membersGetInfoWithMembers:@[selector]] responseWithCompletionHandler:^(NSArray<DBXTeamMembersGetInfoItem *> * _Nullable result, DBXTeamMembersGetInfoError * _Nullable routeError, DBXCallError * _Nullable error) {
    if (result) {
        // Handle result
    } else {
        // Handle error
    }
}];
```

### Migrating from dropbox-sdk-obj-c

If you previously integrated with [dropbox-sdk-obj-c](https://github.com/dropbox/dropbox-sdk-obj-c) migrating to the Swift SDK + Objective-C layer will require code changes but they should be relatively straight forward in most cases.

In order to maintain as consistent of an interface between Swift and Objective-C as possible in this SDK the interface did have to differ slightly from [dropbox-sdk-obj-c](https://github.com/dropbox/dropbox-sdk-obj-c). The primary differences are as follows:

1.) Type names are derived from SwiftyDropbox types prefixed with DBX. There are generally some differences in naming from dropbox-sdk-obj-c, and with Swift's more granular access control some previously accessbile types are now internal to the SDK only. See [Common type migration reference](#common-type-migration-reference).

2.) Some function names have changed slightly to be more verbose about arguments and/or to better match the Swift interface. In the following example note `createFolderV2` vs `createFolderV2WithPath` and `responseWithCompletionHandler` vs `setResponseBlock`:

dropbox-sdk-obj-c:
```objc
[[[DBClientsManager authorizedClient].filesRoutes createFolderV2:@"/some/folder/path"]
  setResponseBlock:^(DBFILESCreateFolderResult * _Nullable result, DBFILESCreateFolderError * _Nullable routeError, DBRequestError * _Nullable networkError) {
    // Handle response
}];
```
SwiftyDropboxObjC:

```objc
[[DBXDropboxClientsManager.authorizedClient.files createFolderV2WithPath:@"some/folder/path"] responseWithCompletionHandler:^(DBXFilesCreateFolderResult * _Nullable result, DBXFilesCreateFolderError * _Nullable routeError, DBXCallError * _Nullable error) {
    // Handle response
}];
```

3.) Capitalization has changed on many classes.

dropbox-sdk-obj-c:
`DBUSERSBasicAccount`

SwiftyDropboxObjC:
`DBXUsersBasicAccount`

4.) Representation of enums that are passed to or returned from the server are now explicitly typed in the class name:

dropbox-sdk-obj-c:

```objc
DBTEAMUserSelectorArg *userSelectArg = [[DBTEAMUserSelectorArg alloc] initWithEmail:@"some@email.com"];
```
SwiftyDropboxObjC:

```objc
DBXTeamUserSelectorArgEmail *userSelectArg = [[DBXTeamUserSelectorArgEmail alloc] init:@"some@email.com"];
```

5.) When working with tasks you no longer need to manually `start` the tasks. They are automatically started on creation.

6.) SwiftyDropbox relies on generics for typed completion handlers on Requests. This is not bridgeable to Objective-C. Instead, for each route there is an additional Request type with the correctly typed completion handler. E.g., `DownloadRequestFile<Files.FileMetadataSerializer, Files.DownloadErrorSerializer>` is represented in Objective-C as `DBXFilesDownloadDownloadRequestFile`.

### Common type migration reference
| dropbox-sdk-objc-c                             | SwiftyDropbox                 | SwiftyDropboxObjC                                              |
|------------------------------------------------|-------------------------------|------------------------------------------------------------|
| DBAppClient                                    | DropboxAppClient              | DBXDropboxAppBase                                          |
| DBClientsManager                               | DropboxClientsManager         | DBXDropboxClientsManager                                   |
| DBTeamClient                                   | DropboxTeamClient             | DBXDropboxTeamClient                                       |
| DBUserClient                                   | DropboxClient                 | DBXDropboxClient                                           |
| DBRequestErrors                                | CallError                     | DBXCallError                                               |
| DBRpcTask                                      | RpcRequest                    | DBX<route-name>RpcRequest                                  |
| DBUploadTask                                   | UploadRequest                 | DBX<route-name>UploadRequest                               |
| DBDownloadUrlTask                              | DownloadRequestFile           | DBX<route-name>DownloadRequestFile                         |
| DBDownloadDataTask                             | DownloadRequestMemory         | DBX<route-name>DownloadRequestMemory                       |
| DBTransportBaseClient/DBTransportDefaultClient | DropboxTransportClientImpl    | DBXDropboxTransportClient                                  |
| DBTransportBaseHostnameConfig                  | BaseHosts                     | DBXBaseHosts                                               |
| DBAccessTokenProvider                          | AccessTokenProvider           | DBXAccessTokenProvider                                     |
| DBLongLivedAccessTokenProvider                 | LongLivedAccessTokenProvider  | DBXLongLivedAccessTokenProvider                            |
| DBShortLivedAccessTokenProvider                | ShortLivedAccessTokenProvider | DBXShortLivedAccessTokenProvider                           |
| DBLoadingStatusDelegate                        | LoadingStatusDelegate         | DBXLoadingStatusDelegate                                   |
| DBOAuthManager                                 | DropboxOAuthManager           | DBXDropboxOAuthManager                                     |
| DBAccessToken                                  | DropboxAccessToken            | DBXDropboxAccessToken                                      |
| DBAccessTokenRefreshing                        | AccessTokenRefreshing         | DBXAccessTokenRefreshing                                   |
| DBOAuthResult                                  | DropboxOAuthResult            | DBXDropboxOAuthResult                                      |
| DBOAuthResultCompletion                        | DropboxOAuthCompletion        | (DBXDropboxOAuthResult?) -> Void                           |
| DBScopeRequest                                 | ScopeRequest                  | DBXScopeRequest                                            |
| DBSDKKeychain                                  | SecureStorageAccess           | DBXSecureStorageAccess / DBXSecureStorageAccessDefaultImpl |
| DBDelegate                                     | n/a                           | n/a                                                        |
| DBGlobalErrorResponseHandler                   | n/a                           | n/a                                                        |
| DBSDKReachability                              | n/a                           | n/a                                                        |
| DBSessionData                                  | n/a                           | n/a                                                        |
| DBTransportDefaultConfig                       | n/a                           | n/a                                                        |
| DBURLSessionTaskResponseBlockWrapper           | n/a                           | n/a                                                        |
| DBURLSessionTaskWithTokenRefresh               | n/a                           | n/a                                                        |
| DBOAuthPKCESession                             | n/a                           | n/a                                                        |
| DBOAuthTokenRequest                            | n/a                           | n/a                                                        |

---

## Changes in version 10.0.0

Version 10.0.0 of SwiftyDropbox differs significantly from version 9.2.0. It aims to support Objective-C, remove AlamoFire as a dependency, support background networking, replace fatal errors during serialization, add unit tests, and better support testing.

These additional features are the greatest differences, but even simple upgrades that don't utilize these new features should consider the other notable changes.

- The destination to which a file is downloaded must now be specified at the time of the call. It's no longer possible to provide a closure that is evaluated after the request is complete.

- The older API for SSL certificate pinning, provided through AlamoFire, is no longer available. This version exposes the URLSession authentication challenge API. Additionally, the optional SessionDelegate from the previous version of the SDK has been removed without a direct replacement.  If your workflows relied on these specific features in ways that are no longer implementable, please [inform us](https://github.com/dropbox/SwiftyDropbox/issues) so that we can better understand and address any potential issues.

- Serialization inconsistencies that used to cause fatal errors now are represented as errors piped through to the requests' completion handlers. It is up to the calling app to decide how to handle them.

- Carthage is no longer supported, please use Swift Package Manager or Cocoapods.

- SDK classes can no longer be subclassed. If this disrupts your usage, please [let us know](https://github.com/dropbox/SwiftyDropbox/issues).

- Due to the extensive nature of the rewrite and the introduction of new features in the new version of the SDK, when transitioning to the new version of the SDK it is important to perform thorough testing of your codebase. The significant changes and enhancements in the new version of the SDK may introduce subtle behavioral changes or edge cases that were not present in the previous version of the SDK.

### New Features

For notes on Objective-C support see [Migrating from dropbox-sdk-obj-c](#migrating-from-dropbox-sdk-obj-c)

The SDK's background networking support simplifies the reconnection of completion handlers to URLSession tasks. See [`TestSwiftyDropbox/DebugBackgroundSessionViewModel`](https://github.com/dropbox/SwiftyDropbox/tree/master/TestSwiftyDropbox/TestSwiftyDropbox_SwiftUI/iOS) for code that exercises various background networking scenarios. See [`TestSwiftDropbox/ActionRequestHandler`](https://github.com/dropbox/SwiftyDropbox/blob/master/TestSwiftyDropbox/TestSwiftyDropbox_ActionExtension/ActionRequestHandler.swift) for usage from an app extension.

### Testing Support

Initialize a `DropboxClient` with a `MockDropboxTransportClient` to facillitate route response mocking in tests. Supply this client to your code under test, excercise the code, then pipe in responses as illustrated below and assert against your code's behavior.

```
let transportClient = MockDropboxTransportClient()

let client = DropboxClient(
    transportClient: transportClient
)

let feature = SystemUnderTest(client: client)

let json: [String: Any] = ["fileNames": ["first"]]

let request = transportClient.getLastRequest()

request.handleMockInput(.success(json: json))

XCTAssert(<state of feature>, <expected state>)

```

---

## Examples

* [PhotoWatch](https://github.com/dropbox/PhotoWatch) - View photos from your Dropbox. Supports Apple Watch.

---

## Documentation

* [Dropbox API v2 Swift SDK](http://dropbox.github.io/SwiftyDropbox/api-docs/latest/)
* [Dropbox API v2](https://www.dropbox.com/developers/documentation/http/documentation)

---

## Stone

All of our routes and data types are auto-generated using a framework called [Stone](https://github.com/dropbox/stone).

The `stone` repo contains all of the Swift specific generation logic, and the `spec` repo contains the language-neutral API endpoint specifications which serve
as input to the language-specific generators.

---

## Modifications

If you're interested in modifying the SDK codebase, you should take the following steps:

* clone this GitHub repository to your local filesystem
* run `git submodule init` and then `git submodule update`
* navigate to `TestSwifty_[iOS|macOS]`
* check the CocoaPods version installed (via `pod --version`) is same as "locked" in `TestSwifty_[iOS|macOS]/Podfile.lock`
* run `pod install`
* open `TestSwifty_[iOS|macOS]/TestSwifty_[iOS|macOS].xcworkspace` in Xcode
* implement your changes to the SDK source code.

To ensure your changes have not broken any existing functionality, you can run a series of integration tests:
* create a new app on https://www.dropbox.com/developers/apps/, with "Full Dropbox" access. Note the App key
* open Info.plist and configure the "URL types > Item 0 (Editor) > URL Schemes > Item 0" key to db-"App key"
* open AppDelegate.swift and replace "FULL_DROPBOX_APP_KEY" with the App key as well
* run the test app on your device and follow the on-screen instructions

To run and develop against the unit tests instead of the integration tests, open the root of the cloned repository in Xcode. Please run the integration tests after development.

---

## App Store Connect Privacy Labels

To assist developers using Dropbox SDKs in filling out Apple’s Privacy Practices Questionnaire, we’ve provided the below information on the data that may be collected and used by Dropbox.

As you complete the questionnaire you should note that the below information is general in nature. Dropbox SDKs are designed to be configured by the developer to incorporate Dropbox functionality as is best suited to their application. As a result of this customizable nature of the Dropbox SDKs, we are unable to provide information on the actual data collection and use for each application. We advise developers reference our Dropbox for HTTP Developers for specifics on how data is collected by each Dropbox API.

In addition, you should note that the information below only identifies Dropbox’s collection and use of data. You are responsible for identifying your own collection and use of data in your app, which may result in different questionnaire answers than identified below:

| Data                    | Collected by Dropbox                                                      | Data Use                                                                 | Data Linked to the User | Tracking |
| ----------------------- | ------------------------------------------------------------------------- | ------------------------------------------------------------------------ | ----------------------- | -------- |
| **Contact Info**        |                                                                           |                                                                          |                         |          |
| &emsp;• Name            | Not collected                                                             | N/A                                                                      | N/A                     | N/A      |
| &emsp;• Email Address   | May be collected<br>(if you enable authentication using an email address) | • Application functionality                                              | Y                       | N        |
| **Health & Fitness**    | Not collected                                                             | N/A                                                                      | N/A                     | N/A      |
| **Financial Info**      | Not collected                                                             | N/A                                                                      | N/A                     | N/A      |
| **Location**            | Not collected                                                             | N/A                                                                      | N/A                     | N/A      |
| **Sensitive Info**      | Not collected                                                             | N/A                                                                      | N/A                     | N/A      |
| **Contacts**            | Not collected                                                             | N/A                                                                      | N/A                     | N/A      |
| **User Content**        |                                                                           |                                                                          |                         |          |
| &emsp;• Audio Data      | May be collected                                                          | • Application functionality                                              | Y                       | N        |
| &emsp;• Photos or Videos | May be collected                                                          | • Application functionality                                              | Y                       | N        |
| &emsp;• Other User Content | May be collected                                                          | • Application functionality                                              | Y                       | N        |
| **Browsing History**    | Not collected                                                             | N/A                                                                      | N/A                     | N/A      |
| **Search History**      |                                                                           |                                                                          |                         |          |
| &emsp;• Search History  | May be collected<br>(if using search functionality)                       | • Application functionality<br>• Analytics                               | Y                       | N        |
| **Identifiers**         |                                                                           |                                                                          |                         |          |
| &emsp;• User ID         | Collected                                                                 | • Application functionality<br>• Analytics                               | Y                       | N        |
| **Purchases**           | Not collected                                                             | N/A                                                                      | N/A                     | N/A      |
| **Usage Data**          |                                                                           |                                                                          |                         |          |
| &emsp;• Product Interaction | Collected                                                                 | • Application functionality <br>• Analytics<br>• Product personalization | Y                       | N        |
| **Diagnostics**         |                                                                           |                                                                          |                         |          |
| &emsp;• Other Diagnostic Data | Collected<br>(API call logs)                                              | • Application functionality                                              | Y                       | N        |
| **Other Data**          | N/A                                                                       | N/A                                                                      | N/A                     | N/A      |

---

## Bugs

Please post any bugs to the [issue tracker](https://github.com/dropbox/SwiftyDropbox/issues) found on the project's GitHub page.

Please include the following with your issue:
 - a description of what is not working right
 - sample code to help replicate the issue

Thank you!

