///
/// Copyright (c) 2022 Dropbox, Inc. All rights reserved.
///

#import "ObjCFilesRoutesTests.h"
#import "ObjCTestClasses.h"

#if TARGET_OS_IPHONE
#import "TestSwiftyDropbox_iOSTests-Swift.h"
#elif TARGET_OS_MAC
#import "TestSwiftyDropbox_macOSTests-Swift.h"
#endif


@implementation ObjCFilesRoutesTests {
    NSOperationQueue *_delegateQueue;
    DropboxTester *_tester;
}

- (void)setUp {
    self.continueAfterFailure = false;

    if (DBXDropboxClientsManager.authorizedClient == nil) {
        [self setupDropboxClientsManager];
    }

    _tester = [[DropboxTester alloc] init];
}

- (void)setupDropboxClientsManager {
    NSDictionary<NSString *,NSString *> *processInfo = NSProcessInfo.processInfo.environment;

    NSString *apiAppKey = processInfo[@"FULL_DROPBOX_API_APP_KEY"];
    if (apiAppKey == nil) {
        XCTFail(@"FULL_DROPBOX_API_APP_KEY needs to be set in the test Scheme");
    }
    NSString *refreshToken = processInfo[@"FULL_DROPBOX_TESTER_USER_REFRESH_TOKEN"];
    if (refreshToken == nil) {
        XCTFail(@"FULL_DROPBOX_TESTER_USER_REFRESH_TOKEN needs to be set in the test Scheme");
    }

    DBXDropboxOAuthManager *manager = [[DBXDropboxOAuthManager alloc] initWithAppKey:apiAppKey secureStorageAccess:[[DBXSecureStorageAccessTestImpl alloc] init]];
    DBXDropboxAccessToken *defaultToken = [[DBXDropboxAccessToken alloc] initWithAccessToken:@"" uid:@"test" refreshToken:refreshToken tokenExpirationTimestamp:0];

    XCTestExpectation *flag = [[XCTestExpectation alloc] initWithDescription:@"setupDropboxClientsManager"];

    __block DBXDropboxAccessToken * _Nonnull returnAccessToken;

    [manager refreshAccessToken:defaultToken scopes:[DropboxTester scopesForTests] queue:dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0) completion:^(DBXDropboxOAuthResult * _Nullable result) {
        if (result.token) {
            returnAccessToken = result.token;
        } else if (result.errorMessage) {
            XCTFail(@"Error: failed to refresh access token: %@", result.errorMessage);
        } else if (result.wasCancelled) {
            XCTFail(@"Error: failed to refresh access token (cancelled)");
        } else {
            XCTFail(@"Error: failed to refresh access token (no result)");
        }

        [flag fulfill];
    }];

    XCTWaiterResult result = [XCTWaiter waitForExpectations:@[flag] timeout:10];
    XCTAssertEqual(result, XCTWaiterResultCompleted);

    DBXAccessTokenProvider *tokenProvider = [manager accessTokenProviderForToken:returnAccessToken];
    DBXDropboxTransportClient *transportClient = [[DBXDropboxTransportClient alloc] initWithAccessTokenProvider:tokenProvider selectUser:nil sessionConfiguration: nil pathRoot:nil];

#if TARGET_OS_IPHONE
    DBXSecureStorageAccessTestImpl *secureStorageAccess = [[DBXSecureStorageAccessTestImpl alloc] init];
    [DBXDropboxClientsManager setupWithAppKey:apiAppKey transportClient:transportClient backgroundTransportClient:nil secureStorageAccess:secureStorageAccess includeBackgroundClient:NO requestsToReconnect: ^(NSArray<DBXReconnectionResult *> *reconnectionResults){}];
#elif TARGET_OS_MAC
    DBXSecureStorageAccessTestImpl *secureStorageAccess = [[DBXSecureStorageAccessTestImpl alloc] init];
    [DBXDropboxClientsManager setupWithAppKeyDesktop:apiAppKey transportClient:transportClient secureStorageAccess:secureStorageAccess];
#endif
}


- (void)tearDown {
    NSLog(@"ObjcTests tearDown: delete folder");
    XCTestExpectation *flag = [[XCTestExpectation alloc] initWithDescription:@"tearDown"];

    [[[FilesTests alloc] init:_tester] deleteV2:^{
        [flag fulfill];
    }];

    XCTWaiterResult result = [XCTWaiter waitForExpectations:@[flag] timeout:30];
    XCTAssertEqual(result, XCTWaiterResultCompleted);
}

- (void)testObjcUserRoutes {
    NSLog(@"ObjCTests testObjcUserRoutes");
    XCTestExpectation *flag = [[XCTestExpectation alloc] initWithDescription:@"testObjcUserRoutes Expectation"];

    [_tester testFilesEndpoints:^{
        [flag fulfill];
    } asMember:NO];

    XCTWaiterResult result = [XCTWaiter waitForExpectations:@[flag] timeout:60*5];
    XCTAssertEqual(result, XCTWaiterResultCompleted);
}

@end
