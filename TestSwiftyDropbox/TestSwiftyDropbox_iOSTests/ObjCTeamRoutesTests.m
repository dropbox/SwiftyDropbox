///
/// Copyright (c) 2022 Dropbox, Inc. All rights reserved.
///

#import "ObjCTeamRoutesTests.h"
#import "ObjCTestClasses.h"

#if TARGET_OS_IPHONE
#import "TestSwiftyDropbox_iOSTests-Swift.h"
#elif TARGET_OS_MAC
#import "TestSwiftyDropbox_macOSTests-Swift.h"
#endif

@implementation ObjCTeamRoutesTests {
    NSOperationQueue *_delegateQueue;
    DropboxTeamTester *_tester;
}

+ (void)setUp {
    [super setUp];

    [DBXDropboxOAuthManager __test_only_resetForTeamSetup];
    [ObjCTeamRoutesTests setupDropboxClientsManager];
}

- (void)setUp {
    self.continueAfterFailure = false;

    _tester = [[DropboxTeamTester alloc] init];

    [self setupTestData];
}

+ (void)setupDropboxClientsManager {
    NSDictionary<NSString *,NSString *> *processInfo = NSProcessInfo.processInfo.environment;

    NSString *apiAppKey = processInfo[@"FULL_DROPBOX_API_APP_KEY"];
    if (apiAppKey == nil) {
        XCTFail(@"FULL_DROPBOX_API_APP_KEY needs to be set in the test Scheme");
    }
    NSString *refreshToken = processInfo[@"FULL_DROPBOX_TESTER_TEAM_REFRESH_TOKEN"];
    if (refreshToken == nil) {
        XCTFail(@"FULL_DROPBOX_TESTER_USER_REFRESH_TOKEN needs to be set in the test Scheme");
    }

    DBXDropboxOAuthManager *manager = [[DBXDropboxOAuthManager alloc] initWithAppKey:apiAppKey secureStorageAccess:[[DBXSecureStorageAccessTestImpl alloc] init]];
    DBXDropboxAccessToken *defaultToken = [[DBXDropboxAccessToken alloc] initWithAccessToken:@"" uid:@"test" refreshToken:refreshToken tokenExpirationTimestamp:0];

    XCTestExpectation *flag = [[XCTestExpectation alloc] initWithDescription:@"setupDropboxClientsManager"];

    __block DBXDropboxAccessToken * _Nonnull returnAccessToken;

    [manager refreshAccessToken:defaultToken scopes:[DropboxTeamTester scopesForTests] queue:dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0) completion:^(DBXDropboxOAuthResult * _Nullable result) {
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
    DBXDropboxTransportClient *transportClient = [[DBXDropboxTransportClient alloc] initWithAccessTokenProvider:tokenProvider selectUser:nil sessionConfiguration:nil pathRoot:nil];

#if TARGET_OS_IPHONE
    DBXSecureStorageAccessTestImpl *secureStorageAccess = [[DBXSecureStorageAccessTestImpl alloc] init];
    [DBXDropboxClientsManager setupWithTeamAppKeyMultiUser:apiAppKey transportClient:transportClient secureStorageAccess:secureStorageAccess tokenUid:@"test"];

#elif TARGET_OS_MAC
    DBXSecureStorageAccessTestImpl *secureStorageAccess = [[DBXSecureStorageAccessTestImpl alloc] init];
    [DBXDropboxClientsManager setupWithTeamAppKeyMultiUserDesktop:apiAppKey transportClient:transportClient secureStorageAccess:secureStorageAccess tokenUid:@"test"];
#endif
}

- (void)setupTestData {
    NSDictionary<NSString *,NSString *> *processInfo = NSProcessInfo.processInfo.environment;

    NSString *teamMemberEmail = processInfo[@"TEAM_MEMBER_EMAIL"];
    if (teamMemberEmail == nil) {
        XCTFail(@"TEAM_MEMBER_EMAIL needs to be set in the test Scheme");
    }
    NSString *emailToAddAsTeamMember = processInfo[@"EMAIL_TO_ADD_AS_TEAM_MEMBER"];
    if (emailToAddAsTeamMember == nil) {
        XCTFail(@"EMAIL_TO_ADD_AS_TEAM_MEMBER needs to be set in the test Scheme");
    }
    NSString *accountId = processInfo[@"ACCOUNT_ID"];
    if (accountId == nil) {
        XCTFail(@"ACCOUNT_ID needs to be set in the test Scheme");
    }
    NSString *accountId2 = processInfo[@"ACCOUNT_ID_2"];
    if (accountId2 == nil) {
        XCTFail(@"ACCOUNT_ID_2 needs to be set in the test Scheme");
    }
    NSString *accountId3 = processInfo[@"ACCOUNT_ID_3"];
    if (accountId3 == nil) {
        XCTFail(@"ACCOUNT_ID_3 needs to be set in the test Scheme");
    }

    [_tester setupDBXTestDataForTeamTests:teamMemberEmail emailToAddAsTeamMember:emailToAddAsTeamMember accountId:accountId accountId2:accountId2 accountId3:accountId3];
}

- (void)testObjcTeamMemberManagement {
    NSLog(@"ObjCTests testObjcTeamMemberManagement");
    XCTestExpectation *flag = [[XCTestExpectation alloc] initWithDescription:@"testObjcTeamMemberManagement Expectation"];

    [_tester testTeamMemberManagementActions:^{
        [flag fulfill];
    }];

    XCTWaiterResult result = [XCTWaiter waitForExpectations:@[flag] timeout:60*5];
    XCTAssertEqual(result, XCTWaiterResultCompleted);
}

- (void)testObjcTeamMemberFileAccess {
    NSLog(@"ObjCTests testObjcTeamRoutes");
    XCTestExpectation *flag = [[XCTestExpectation alloc] initWithDescription:@"testObjcTeamRoutes Expectation"];

    [_tester testAllTeamMemberFileAcessActions:^{
        [flag fulfill];
    }];

    XCTWaiterResult result = [XCTWaiter waitForExpectations:@[flag] timeout:60*5];
    XCTAssertEqual(result, XCTWaiterResultCompleted);
}

@end
