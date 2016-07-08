# SwiftyDropbox

A Swift SDK for integrating with the Dropbox API v2.

## Setup

To get started with SwiftyDropbox, we recommend you add it to your project using CocoaPods.

1. Install CocoaPods:
    ```
    sudo gem install cocoapods
    ```

1. If you've never used CocoaPods before, run:
    ```
    pod setup
    ```

1. In your project directory, create a new file and call it "Podfile". Add the following text to the file:

    ```ruby
      platform :ios, '8.0'
      use_frameworks!

      target '<YOUR_PROJECT_NAME>' do
        pod 'SwiftyDropbox'
      end
    ```

1. From the project directory, install the SwiftyDropbox SDK with:

    ```
    pod install
    ```

## Creating an application

You need to create an Dropbox Application to make API requests.

- Go to https://dropbox.com/developers/apps.

## Obtaining an access token

All requests need to be made with an OAuth 2 access token. To get started, once
you've created an app, you can go to the app's console and generate an access
token for your own Dropbox account.

## Examples

* [PhotoWatch](https://github.com/dropbox/PhotoWatch) - View photos from your Dropbox on your Apple Watch.

## Read more

Read more about SwiftyDropbox on our [developer site](https://www.dropbox.com/developers/documentation/swift).

## Modifications

If you're interested in modifying the SwiftyDropbox codebase, clone this repository to your local filesystem
and run `git submodule init` and then `gitsubmodule update`, then navigate to ./TestSwifty and run `pod install`.
Once this is complete, open the TestSwifty.xcworkspace file with Xcode and proceed to implement your changes to the
SwiftyDropbox source code.

To ensure your changes have not broken any existing functionality, you may run a series of comprehensive unit tests by
following the instructions listed in the ./TestSwifty/TestSwifty/ViewController.swift file.
