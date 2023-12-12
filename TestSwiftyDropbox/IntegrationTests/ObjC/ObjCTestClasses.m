///
/// Copyright (c) 2022 Dropbox, Inc. All rights reserved.
///

#import "ObjCTestClasses.h"
#if TARGET_OS_IPHONE
#import <TestSwiftyDropbox_iOS-Swift.h>
#elif TARGET_OS_MAC
#import <TestSwiftyDropbox_macOS-Swift.h>
#endif

void MyLog(NSString *format, ...) {
    va_list args;
    va_start(args, format);
    NSString *formattedString = [[NSString alloc] initWithFormat:format arguments:args];
    va_end(args);
    [[NSFileHandle fileHandleWithStandardOutput] writeData:[formattedString dataUsingEncoding:NSNEXTSTEPStringEncoding]];
}

@implementation DropboxTester
+ (NSArray<NSString *>*)scopesForTests {
    return [@"account_info.read files.content.read files.content.write files.metadata.read files.metadata.write sharing.write sharing.read" componentsSeparatedByString:@" "];
}

- (instancetype)init {
    self = [super init];
    if (self) {
        self.auth = DBXDropboxClientsManager.authorizedClient.auth;
        self.users = DBXDropboxClientsManager.authorizedClient.users;
        self.files = DBXDropboxClientsManager.authorizedClient.files;
        self.sharing = DBXDropboxClientsManager.authorizedClient.sharing;
    }
    return self;
}

// Test user app with 'Full Dropbox' permission
- (void)testAllUserAPIEndpoints:(void (^)(void))nextTest asMember:(BOOL)asMember {
    void (^end)(void) = ^{
        if (nextTest) {
            nextTest();
        } else {
            [TestFormat printAllTestsEnd];
        }
    };
    void (^testUsersEndpoints)(void) = ^{
        [self testUsersEndpoints:end];
    };
    void (^testSharingEndpoints)(void) = ^{
        [self testSharingEndpoints:testUsersEndpoints];
    };
    void (^testFilesEndpoints)(void) = ^{
        [self testFilesEndpoints:testSharingEndpoints asMember:asMember];
    };
    void (^start)(void) = ^{
        testFilesEndpoints();
    };
    
    start();
}

- (void)testFilesEndpoints:(void (^)(void))nextTest asMember:(BOOL)asMember {
    FilesTests *filesTests = [[FilesTests alloc] init: self];
    
    void (^end)(void) = ^{
        [TestFormat printTestEnd];
        nextTest();
    };
    void (^listFolderLongpollAndTrigger)(void) = ^{
        [filesTests listFolderLongpollAndTrigger:end asMember:asMember];
    };
    void (^uploadFile)(void) = ^{
        [filesTests uploadFile:listFolderLongpollAndTrigger];
    };
    void (^downloadToMemory)(void) = ^{
        [filesTests downloadToMemory:uploadFile];
    };
    void (^downloadToFileAgain)(void) = ^{
        [filesTests downloadToFileAgain:downloadToMemory];
    };
    void (^downloadToFile)(void) = ^{
        [filesTests downloadToFile:downloadToFileAgain];
    };
// Async nature of this call can interfere with subsequent test runs by finishing after cleanup
//    void (^saveUrl)(void) = ^{
//        [filesTests saveUrl:downloadToFile asMember:asMember];
//    };
    void (^move)(void) = ^{
        [filesTests moveV2:downloadToFile];
    };
    void (^listRevisions)(void) = ^{
        [filesTests listRevisions:move];
    };
    void (^getTemporaryLink)(void) = ^{
        [filesTests getTemporaryLink:listRevisions];
    };
    void (^getMetadataError)(void) = ^{
        [filesTests getMetadataError:getTemporaryLink];
    };
    void (^getMetadata)(void) = ^{
        [filesTests getMetadata:getMetadataError];
    };
    void (^dCopyReferenceGet)(void) = ^{
        [filesTests dCopyReferenceGet:getMetadata];
    };
    void (^dCopy)(void) = ^{
        [filesTests dCopyV2:dCopyReferenceGet];
    };
    void (^uploadDataSession)(void) = ^{
        [filesTests uploadDataSession:dCopy];
    };
    void (^uploadData)(void) = ^{
        [filesTests uploadData:uploadDataSession];
    };
    void (^listFolder)(void) = ^{
        [filesTests listFolder:uploadData];
    };
    void (^listFolderError)(void) = ^{
        [filesTests listFolderError:listFolder];
    };
    void (^createFolder)(void) = ^{
        [filesTests createFolderV2:listFolderError];
    };
    void (^delete_)(void) = ^{
        [filesTests deleteV2:createFolder];
    };
    void (^start)(void) = ^{
        delete_();
    };
    
    [TestFormat printTestBegin:NSStringFromSelector(_cmd)];
    start();
}

- (void)testSharingEndpoints:(void (^)(void))nextTest {
    SharingTests *sharingTests = [[SharingTests alloc] init:self];
    
    void (^end)(void) = ^{
        [TestFormat printTestEnd];
        nextTest();
    };
    void (^unshareFolder)(void) = ^{
        [sharingTests updateFolderPolicy:end];
    };
    void (^updateFolderPolicy)(void) = ^{
        [sharingTests updateFolderPolicy:unshareFolder];
    };
    void (^mountFolder)(void) = ^{
        [sharingTests mountFolder:updateFolderPolicy];
    };
    void (^unmountFolder)(void) = ^{
        [sharingTests unmountFolder:mountFolder];
    };
    void (^revokeSharedLink)(void) = ^{
        [sharingTests revokeSharedLink:unmountFolder];
    };
    void (^removeFolderMember)(void) = ^{
        [sharingTests removeFolderMember:revokeSharedLink];
    };
    void (^listSharedLinks)(void) = ^{
        [sharingTests listSharedLinks:removeFolderMember];
    };
    void (^listFolders)(void) = ^{
        [sharingTests listFolders:listSharedLinks];
    };
    void (^listFolderMembers)(void) = ^{
        [sharingTests listFolderMembers:listFolders];
    };
    void (^addFolderMember)(void) = ^{
        [sharingTests addFolderMember:listFolderMembers];
    };
    void (^getFolderMetadata)(void) = ^{
        [sharingTests getFolderMetadata:addFolderMember];
    };
    void (^createSharedLinkWithSettings)(void) = ^{
        [sharingTests createSharedLinkWithSettings:getFolderMetadata];
    };
    void (^shareFolder)(void) = ^{
        [sharingTests shareFolder:createSharedLinkWithSettings];
    };
    void (^start)(void) = ^{
        shareFolder();
    };
    
    [TestFormat printTestBegin:NSStringFromSelector(_cmd)];
    start();
}

- (void)testUsersEndpoints:(void (^)(void))nextTest {
    UsersTests *usersTests = [[UsersTests alloc] init:self];
    
    void (^end)(void) = ^{
        [TestFormat printTestEnd];
        nextTest();
    };
    void (^getSpaceUsage)(void) = ^{
        [usersTests getSpaceUsage:end];
    };
    void (^getCurrentAccount)(void) = ^{
        [usersTests getCurrentAccount:getSpaceUsage];
    };
    void (^getAccountBatch)(void) = ^{
        [usersTests getAccountBatch:getCurrentAccount];
    };
    void (^getAccount)(void) = ^{
        [usersTests getAccount:getAccountBatch];
    };
    void (^start)(void) = ^{
        getAccount();
    };
    
    [TestFormat printTestBegin:NSStringFromSelector(_cmd)];
    start();
}

@end

@implementation DropboxTeamTester
+ (NSArray<NSString *>*)scopesForTests {
    NSString *scopesForTeamRoutesTests = @"groups.read groups.write members.delete members.read members.write sessions.list team_data.member team_info.read";
    NSString *scopesForMemberFileAccessUserTests = @"files.content.write files.content.read sharing.write account_info.read";
    return [[NSString stringWithFormat:@"%@ %@",
             scopesForTeamRoutesTests,
             scopesForMemberFileAccessUserTests] componentsSeparatedByString:@" "];
}

- (instancetype)init {
    self = [super init];
    if (self) {
        self.team = DBXDropboxClientsManager.authorizedTeamClient.team;
        self.files = DBXDropboxClientsManager.authorizedClient.files;
    }
    return self;
}

- (void)setupDBXTestDataForTeamTests:(NSString *)teamMemberEmail emailToAddAsTeamMember:(NSString *)emailToAddAsTeamMember accountId:(NSString *)accountId accountId2:(NSString *)accountId2 accountId3:(NSString *)accountId3 {
    DBXTestData.teamMemberEmail = teamMemberEmail;
    DBXTestData.newMemberEmail = emailToAddAsTeamMember;
    DBXTestData.accountId3Email = emailToAddAsTeamMember;

    DBXTestData.accountId = accountId;
    DBXTestData.accountId2 = accountId2;
    DBXTestData.accountId3 = accountId3;
}

// Test business app with 'Team member file access' permission
- (void)testAllTeamMemberFileAcessActions:(void (^)(void))nextTest {
    void (^end)(void) = ^{
        if (nextTest) {
            nextTest();
        } else {
            [TestFormat printAllTestsEnd];
        }
    };
    void (^testPerformActionAsMember)(TeamTests *) = ^(TeamTests *teamTests) {
        [teamTests initMembersGetInfoAndMemberId:^(NSString * memberId){
            DropboxTester *tester = [[DropboxTester alloc] init];
            [tester testAllUserAPIEndpoints:end asMember:YES];
        }];
    };
    void (^testTeamMemberFileAcessActions)(void) = ^{
        [self testTeamMemberFileAcessActions:testPerformActionAsMember];
    };
    void (^start)(void) = ^{
        testTeamMemberFileAcessActions();
    };

    start();
}

// Test business app with 'Team member management' permission
- (void)testAllTeamMemberManagementActions:(void (^)(void))nextTest {
    void (^end)(void) = ^{
        if (nextTest) {
            nextTest();
        } else {
            [TestFormat printAllTestsEnd];
        }
    };
    void (^testTeamMemberManagementActions)(void) = ^{
        [self testTeamMemberManagementActions:end];
    };
    void (^start)(void) = ^{
        testTeamMemberManagementActions();
    };

    start();
}

- (void)testTeamMemberFileAcessActions:(void (^)(TeamTests *))nextTest {
    TeamTests *teamTests = [[TeamTests alloc] init:self];
    
    void (^end)(void) = ^{
        [TestFormat printTestEnd];
        nextTest(teamTests);
    };
    void (^getInfo)(void) = ^{
        [teamTests getInfo:end];
    };
    void (^linkedAppsListMembersLinkedApps)(void) = ^{
        [teamTests linkedAppsListMembersLinkedApps:getInfo];
    };
    void (^linkedAppsListMemberLinkedApps)(void) = ^{
        [teamTests linkedAppsListMemberLinkedApps:linkedAppsListMembersLinkedApps];
    };
    void (^listMembersDevices)(void) = ^{
        [teamTests listMembersDevices:linkedAppsListMemberLinkedApps];
    };
    void (^listMemberDevices)(void) = ^{
        [teamTests listMemberDevices:listMembersDevices];
    };
    void (^initMembersGetInfo)(void) = ^{
        [teamTests initMembersGetInfo:listMemberDevices];
    };
    void (^start)(void) = ^{
        initMembersGetInfo();
    };
    
    [TestFormat printTestBegin:NSStringFromSelector(_cmd)];
    start();
}

- (void)testTeamMemberManagementActions:(void (^)(void))nextTest {
    TeamTests *teamTests = [[TeamTests alloc] init:self];
    
    void (^end)(void) = ^{
        [TestFormat printTestEnd];
        nextTest();
    };
// Comment this out until we understand the email_address_too_long_to_be_disabled error
//    void (^membersRemove)(void) = ^{
//        [teamTests membersRemove:end];
//    };
    void (^membersSetProfile)(void) = ^{
        [teamTests membersSetProfile:end];
    };
    void (^membersSetAdminPermissions)(void) = ^{
        [teamTests membersSetAdminPermissions:membersSetProfile];
    };
    void (^membersSendWelcomeEmail)(void) = ^{
        [teamTests membersSendWelcomeEmail:membersSetAdminPermissions];
    };
    void (^membersList)(void) = ^{
        [teamTests membersList:membersSendWelcomeEmail];
    };
    void (^membersGetInfo)(void) = ^{
        [teamTests membersGetInfo:membersList];
    };
    void (^membersAdd)(void) = ^{
        [teamTests membersAdd:membersGetInfo];
    };
    void (^groupsDelete)(void) = ^{
        [teamTests groupsDelete:membersAdd];
    };
    void (^groupsUpdate)(void) = ^{
        [teamTests groupsUpdate:groupsDelete];
    };
    void (^groupsMembersList)(void) = ^{
        [teamTests groupsMembersList:groupsUpdate];
    };
    void (^groupsMembersAdd)(void) = ^{
        [teamTests groupsMembersAdd:groupsMembersList];
    };
    void (^groupsList)(void) = ^{
        [teamTests groupsList:groupsMembersAdd];
    };
    void (^groupsGetInfo)(void) = ^{
        [teamTests groupsGetInfo:groupsList];
    };
    void (^groupsCreate)(void) = ^{
        [teamTests groupsCreate:groupsGetInfo];
    };
    void (^initMembersGetInfo)(void) = ^{
        [teamTests initMembersGetInfo:groupsCreate];
    };
    void (^start)(void) = ^{
        initMembersGetInfo();
    };
    
    [TestFormat printTestBegin:NSStringFromSelector(_cmd)];
    start();
}

@end

/**
 Dropbox User API Endpoint Tests
 */

@implementation AuthTests

- (instancetype)init:(DropboxTester *)tester {
    self = [super init];
    if (self) {
        _tester = tester;
    }
    return self;
}

- (void)tokenRevoke:(void (^)(void))nextTest {
    [TestFormat printSubTestBegin:NSStringFromSelector(_cmd)];
    [[_tester.auth tokenRevoke] responseWithCompletionHandler:^(DBXCallError * _Nullable error) {
        if (error) {
            [TestFormat abort:nil error:error];
        } else {
            [TestFormat printOffset:@"Token successfully revoked"];
            [TestFormat printSubTestEnd:NSStringFromSelector(_cmd)];
            nextTest();
        }
    }];
}

@end

@implementation FilesTests

- (nonnull instancetype)init:(DropboxTester * _Nonnull)tester {
    self = [super init];
    if (self) {
        _tester = tester;
    }
    return self;
}

- (void)deleteV2:(void (^)(void))nextTest {
    [TestFormat printSubTestBegin:NSStringFromSelector(_cmd)];
    [[_tester.files deleteV2WithPath:DBXTestData.baseFolder] responseWithCompletionHandler:^(DBXFilesDeleteResult * _Nullable result, DBXFilesDeleteError * _Nullable routeError, DBXCallError * _Nullable error) {
        if (result) {
            MyLog(@"%@\n", result);
        } else {
            DBXRateLimitError *rateLimitError = error.asRateLimitError;
            if (rateLimitError) {
                sleep(rateLimitError.error.retryAfter.unsignedIntValue);
                [self deleteV2:nextTest];
            } else {
                [TestFormat printErrors:routeError error:error];
            }
        }
        [TestFormat printSubTestEnd:NSStringFromSelector(_cmd)];
        nextTest();
    }];
}

- (void)createFolderV2:(void (^)(void))nextTest {
    [self createFolderV2:nextTest retryCount:2];
}

- (void)createFolderV2:(void (^)(void))nextTest retryCount:(int)retryCount {
    [TestFormat printSubTestBegin:NSStringFromSelector(_cmd)];
    [[_tester.files createFolderV2WithPath:DBXTestData.testFolderPath] responseWithCompletionHandler:^(DBXFilesCreateFolderResult * _Nullable result, DBXFilesCreateFolderError * _Nullable routeError, DBXCallError * _Nullable error) {
        if (result) {
            MyLog(@"%@\n", result);
            [TestFormat printSubTestEnd:NSStringFromSelector(_cmd)];
            nextTest();
        } else {
            DBXRateLimitError *rateLimitError = error.asRateLimitError;
            if (rateLimitError && retryCount > 0) {
                sleep(rateLimitError.error.retryAfter.unsignedIntValue);
                [self createFolderV2:nextTest retryCount:retryCount - 1];
            } else {
                [TestFormat abort:routeError error:error];
            }
        }
    }];
}


- (void)listFolderError:(void (^)(void))nextTest {
    [TestFormat printSubTestBegin:NSStringFromSelector(_cmd)];
    [[_tester.files listFolderWithPath:@"/does/not/exist/folder"] responseWithCompletionHandler:^(DBXFilesListFolderResult * _Nullable result, DBXFilesListFolderError * _Nullable routeError, DBXCallError * _Nullable error) {
        if (result) {
            MyLog(@"Something went wrong... This should have errored.\n");
            [TestFormat abort:routeError error:error];
        } else {
            [TestFormat printOffset:@"Intentionally errored.\n"];
            [TestFormat printErrors:routeError error:error];
            [TestFormat printSubTestEnd:NSStringFromSelector(_cmd)];
            nextTest();
        }
    }];
}

- (void)listFolder:(void (^)(void))nextTest {
    [TestFormat printSubTestBegin:NSStringFromSelector(_cmd)];
    [[_tester.files listFolderWithPath:DBXTestData.testFolderPath] responseWithCompletionHandler:^(DBXFilesListFolderResult * _Nullable result, DBXFilesListFolderError * _Nullable routeError, DBXCallError * _Nullable error) {
        if (result) {
            MyLog(@"%@\n", result);
            [TestFormat printSubTestEnd:NSStringFromSelector(_cmd)];
            nextTest();
        } else {
            [TestFormat abort:routeError error:error];
        }
    }];
}

- (void)uploadData:(void (^)(void))nextTest {
    [TestFormat printSubTestBegin:NSStringFromSelector(_cmd)];
    [[_tester.files uploadDataWithPath:DBXTestData.testFilePath input:DBXTestData.fileData] responseWithCompletionHandler:^(DBXFilesFileMetadata * _Nullable result, DBXFilesUploadError * _Nullable routeError, DBXCallError * _Nullable error) {
        if (result) {
            MyLog(@"%@\n", result);
            [TestFormat printSubTestEnd:NSStringFromSelector(_cmd)];
            nextTest();
        } else {
            [TestFormat abort:routeError error:error];
        }
    }];
}

- (void)uploadDataSession:(void (^)(void))nextTest {
    [TestFormat printSubTestBegin:NSStringFromSelector(_cmd)];
    [[_tester.files uploadSessionStartDataWithInput:DBXTestData.fileData] responseWithCompletionHandler:^(DBXFilesUploadSessionStartResult * _Nullable result, DBXFilesUploadSessionStartError * _Nullable routeError, DBXCallError * _Nullable error) {
        if (result) {
            NSNumber *offset = [NSNumber numberWithUnsignedInteger:DBXTestData.fileData.length];
            DBXFilesUploadSessionCursor *cursor = [[DBXFilesUploadSessionCursor alloc] initWithSessionId:result.sessionId offset:offset];
            [[self->_tester.files uploadSessionAppendV2DataWithCursor:cursor input:DBXTestData.fileData] responseWithQueue:dispatch_queue_create("uploadDataSession", NULL) completionHandler:^(DBXFilesUploadSessionAppendError * _Nullable routeError, DBXCallError * _Nullable error) {
                if (routeError || error) {
                    [TestFormat abort:routeError error:error];
                } else {
                    MyLog(@"%@\n", result);
                    [TestFormat printSubTestEnd:NSStringFromSelector(_cmd)];
                    nextTest();
                }
            }];
        } else {
            [TestFormat abort:routeError error:error];
        }
    }];
}

- (void)dCopyV2:(void (^)(void))nextTest {
    [TestFormat printSubTestBegin:NSStringFromSelector(_cmd)];
    NSString *copyOutputPath = [NSString
                                stringWithFormat:@"%@%@%@%@", DBXTestData.testFilePath, @"_duplicate", @"_", DBXTestData.testId];
    [[_tester.files copyV2FromPath:DBXTestData.testFilePath toPath:copyOutputPath] responseWithCompletionHandler:^(DBXFilesRelocationResult * _Nullable result, DBXFilesRelocationError * _Nullable routeError, DBXCallError * _Nullable error) {
        if (result) {
            MyLog(@"%@\n", result);
            [TestFormat printSubTestEnd:NSStringFromSelector(_cmd)];
            nextTest();
        } else {
            [TestFormat abort:routeError error:error];
        }
    }];
}

- (void)dCopyReferenceGet:(void (^)(void))nextTest {
    [TestFormat printSubTestBegin:NSStringFromSelector(_cmd)];
    [[_tester.files copyReferenceGetWithPath:DBXTestData.testFilePath] responseWithCompletionHandler:^(DBXFilesGetCopyReferenceResult * _Nullable result, DBXFilesGetCopyReferenceError * _Nullable routeError, DBXCallError * _Nullable error) {
        if (result) {
            MyLog(@"%@\n", result);
            [TestFormat printSubTestEnd:NSStringFromSelector(_cmd)];
            nextTest();
        } else {
            [TestFormat abort:routeError error:error];
        }
    }];
}

- (void)getMetadata:(void (^)(void))nextTest {
    [TestFormat printSubTestBegin:NSStringFromSelector(_cmd)];
    [[_tester.files getMetadataWithPath:DBXTestData.testFilePath] responseWithCompletionHandler:^(DBXFilesMetadata * _Nullable result, DBXFilesGetMetadataError * _Nullable routeError, DBXCallError * _Nullable error) {
        if (result) {
            MyLog(@"%@\n", result);
            [TestFormat printSubTestEnd:NSStringFromSelector(_cmd)];
            nextTest();
        } else {
            [TestFormat abort:routeError error:error];
        }
    }];
}

- (void)getMetadataError:(void (^)(void))nextTest {
    [TestFormat printSubTestBegin:NSStringFromSelector(_cmd)];
    [[_tester.files getMetadataWithPath:@"/this/path/does/not/exist"] responseWithCompletionHandler:^(DBXFilesMetadata * _Nullable result, DBXFilesGetMetadataError * _Nullable routeError, DBXCallError * _Nullable error) {
        if (result) {
            MyLog(@"Something went wrong... This should have errored.\n");
            [TestFormat abort:routeError error:error];
        } else {
            [TestFormat printOffset:@"Intentionally errored.\n"];
            [TestFormat printErrors:routeError error:error];
            [TestFormat printSubTestEnd:NSStringFromSelector(_cmd)];
            nextTest();
        }
    }];
}

- (void)getTemporaryLink:(void (^)(void))nextTest {
    [TestFormat printSubTestBegin:NSStringFromSelector(_cmd)];
    [[_tester.files getTemporaryLinkWithPath:DBXTestData.testFilePath] responseWithCompletionHandler:^(DBXFilesGetTemporaryLinkResult * _Nullable result, DBXFilesGetTemporaryLinkError * _Nullable routeError, DBXCallError * _Nullable error) {
        if (result) {
            MyLog(@"%@\n", result);
            [TestFormat printSubTestEnd:NSStringFromSelector(_cmd)];
            nextTest();
        } else {
            [TestFormat abort:routeError error:error];
        }
    }];
}

- (void)listRevisions:(void (^)(void))nextTest {
    [TestFormat printSubTestBegin:NSStringFromSelector(_cmd)];
    [[_tester.files listRevisionsWithPath:DBXTestData.testFilePath] responseWithCompletionHandler:^(DBXFilesListRevisionsResult * _Nullable result, DBXFilesListRevisionsError * _Nullable routeError, DBXCallError * _Nullable error) {
        if (result) {
            MyLog(@"%@\n", result);
            [TestFormat printSubTestEnd:NSStringFromSelector(_cmd)];
            nextTest();
        } else {
            [TestFormat abort:routeError error:error];
        }
    }];
}

- (void)moveV2:(void (^)(void))nextTest {
//    [TestFormat printSubTestBegin:NSStringFromSelector(_cmd)];
//    NSString *folderPath = [NSString stringWithFormat:@"%@%@%@", DBXTestData.testFolderPath, @"/", @"movedLocation"];
//    [[_tester.files createFolderV2WithPath:folderPath] responseWithQueue:dispatch_queue_create("moveV2", NULL) completionHandler:^(DBXFilesCreateFolderResult * _Nullable result, DBXFilesCreateFolderError * _Nullable routeError, DBXCallError * _Nullable error) {
//        if (result) {
//            MyLog(@"%@\n", result);
//            [TestFormat printOffset:@"Created destination folder"];
//
//            NSString *destPath =
//            [NSString stringWithFormat:@"%@%@%@", folderPath, @"/", DBXTestData.testFileName];
//
//            [[self->_tester.files moveV2FromPath:DBXTestData.testFolderPath toPath:destPath] responseWithQueue:dispatch_queue_create("moveV2", NULL) completionHandler:^(DBXFilesRelocationResult * _Nullable result, DBXFilesRelocationError * _Nullable routeError, DBXCallError * _Nullable error) {
//                if (result) {
//                    MyLog(@"%@\n", result);
//                    [TestFormat printSubTestEnd:NSStringFromSelector(_cmd)];
//                    nextTest();
//                } else {
//                    [TestFormat abort:routeError error:error];
//                }
//            }];
//        } else {
//            [TestFormat abort:routeError error:error];
//        }
//    }];
    nextTest();
}

- (void)saveUrl:(void (^)(void))nextTest asMember:(BOOL)asMember {
    if (asMember) {
        nextTest();
        return;
    }

    [TestFormat printSubTestBegin:NSStringFromSelector(_cmd)];
    NSString *folderPath = [NSString stringWithFormat:@"%@%@%@", DBXTestData.testFolderPath, @"/", @"dbx-test.html"];
    [[_tester.files saveUrlWithPath:folderPath url:@"https://www.google.com"] responseWithCompletionHandler:^(DBXFilesSaveUrlResult * _Nullable result, DBXFilesSaveUrlError * _Nullable routeError, DBXCallError * _Nullable error) {
        if (result) {
            MyLog(@"%@\n", result);
            [TestFormat printSubTestEnd:NSStringFromSelector(_cmd)];
            nextTest();
        } else {
            [TestFormat abort:routeError error:error];
        }
    }];
}

- (void)downloadToFile:(void (^)(void))nextTest {
    [TestFormat printSubTestBegin:NSStringFromSelector(_cmd)];
    [[_tester.files downloadURLWithPath:DBXTestData.testFilePath overwrite:YES destination:DBXTestData.destURL] responseWithCompletionHandler:^(DBXFilesFileMetadata * _Nullable result, NSURL * _Nullable destination, DBXFilesDownloadError * _Nullable routeError, DBXCallError * _Nullable error) {
        if (result) {
            MyLog(@"%@\n", result);
            NSData *data = [[NSFileManager defaultManager] contentsAtPath:[destination path]];
            NSString *dataStr = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            [TestFormat printOffset:@"File contents:"];
            MyLog(@"%@\n", dataStr);
            [TestFormat printSubTestEnd:NSStringFromSelector(_cmd)];
            nextTest();
        } else {
            [TestFormat abort:routeError error:error];
        }
    }];
}

- (void)downloadToFileAgain:(void (^)(void))nextTest {
    [TestFormat printSubTestBegin:NSStringFromSelector(_cmd)];
    [[_tester.files downloadURLWithPath:DBXTestData.testFilePath overwrite:YES destination:DBXTestData.destURL] responseWithCompletionHandler:^(DBXFilesFileMetadata * _Nullable result, NSURL * _Nullable destination, DBXFilesDownloadError * _Nullable routeError, DBXCallError * _Nullable error) {
        if (result) {
            MyLog(@"%@\n", result);
            NSData *data = [[NSFileManager defaultManager] contentsAtPath:[destination path]];
            NSString *dataStr = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            [TestFormat printOffset:@"File contents:"];
            MyLog(@"%@\n", dataStr);
            [TestFormat printSubTestEnd:NSStringFromSelector(_cmd)];
            nextTest();
        } else {
            [TestFormat abort:routeError error:error];
        }
    }];
}

- (void)downloadToFileError:(void (^)(void))nextTest {
    [TestFormat printSubTestBegin:NSStringFromSelector(_cmd)];
    NSString *filePath = [NSString stringWithFormat:@"%@%@", DBXTestData.testFilePath, @"_does_not_exist"];
    [[_tester.files downloadURLWithPath:filePath overwrite:YES destination:DBXTestData.destURL] responseWithCompletionHandler:^(DBXFilesFileMetadata * _Nullable result, NSURL * _Nullable destination, DBXFilesDownloadError * _Nullable routeError, DBXCallError * _Nullable error) {
        if (result) {
            MyLog(@"Something went wrong... This should have errored.\n");
            [TestFormat abort:routeError error:error];
        } else {
            [TestFormat printOffset:@"Intentionally errored.\n"];
            [TestFormat printErrors:routeError error:error];
            [TestFormat printSubTestEnd:NSStringFromSelector(_cmd)];
            nextTest();
        }
    }];
}

- (void)downloadToMemory:(void (^)(void))nextTest {
    [TestFormat printSubTestBegin:NSStringFromSelector(_cmd)];
    [[_tester.files downloadWithPath:DBXTestData.testFilePath] responseWithCompletionHandler:^(DBXFilesFileMetadata * _Nullable result, NSData * _Nullable data, DBXFilesDownloadError * _Nullable routeError, DBXCallError * _Nullable error) {
        if (result) {
            MyLog(@"%@\n", result);
            [TestFormat printSubTestEnd:NSStringFromSelector(_cmd)];
            nextTest();
        } else {
            [TestFormat abort:routeError error:error];
        }
    }];
}

- (void)uploadFile:(void (^)(void))nextTest {
    [TestFormat printSubTestBegin:NSStringFromSelector(_cmd)];
    NSString *outputPath = [NSString stringWithFormat:@"%@%@", DBXTestData.testFilePath, @"_from_file"];
    [[_tester.files uploadURLWithPath:outputPath input:DBXTestData.destURL] responseWithCompletionHandler:^(DBXFilesFileMetadata * _Nullable result, DBXFilesUploadError * _Nullable routeError, DBXCallError * _Nullable error) {
        if (result) {
            MyLog(@"%@\n", result);
            [TestFormat printSubTestEnd:NSStringFromSelector(_cmd)];
            nextTest();
        } else {
            [TestFormat abort:routeError error:error];
        }
    }];
}

- (void)longpollCopy {
    [TestFormat printOffset:@"Making change that longpoll will detect (copy file)"];
    NSString *copyOutputPath =
    [NSString stringWithFormat:@"%@%@%@", DBXTestData.testFilePath, @"_duplicate2_", DBXTestData.testId];

    __weak FilesTests *weakSelf = self;
    [[self->_tester.files copyV2FromPath:DBXTestData.testFilePath toPath:copyOutputPath] responseWithCompletionHandler:^(DBXFilesRelocationResult * _Nullable result, DBXFilesRelocationError * _Nullable routeError, DBXCallError * _Nullable error) {
        if (result) {
            MyLog(@"%@\n", result);
        } else if ([error asRateLimitError]) {
            sleep(error.asRateLimitError.error.retryAfter.unsignedIntValue);
            [weakSelf longpollCopy];
        } else {
            [TestFormat abort:routeError error:error];
        }
    }];
}

- (void)listFolderLongpollAndTrigger:(void (^)(void))nextTest asMember:(BOOL)asMember {
    if (asMember) {
        nextTest();
        return;
    }

    void (^listFolderContinue)(NSString *) = ^(NSString *cursor) {
        [[self->_tester.files listFolderContinueWithCursor:cursor] responseWithCompletionHandler:^(DBXFilesListFolderResult * _Nullable result, DBXFilesListFolderContinueError * _Nullable routeError, DBXCallError * _Nullable error) {
            if (result) {
                [TestFormat printOffset:@"Here are the changes:"];
                MyLog(@"%@\n", result);
                [TestFormat printSubTestEnd:NSStringFromSelector(_cmd)];
                nextTest();
            } else {
                [TestFormat abort:routeError error:error];
            }
        }];
    };

    __weak FilesTests *weakSelf = self;
    void (^listFolderLongpoll)(NSString *) = ^(NSString *cursor) {
        [TestFormat printOffset:@"Establishing longpoll"];
        [[self->_tester.files listFolderLongpollWithCursor:cursor] responseWithCompletionHandler:^(DBXFilesListFolderLongpollResult * _Nullable result, DBXFilesListFolderLongpollError * _Nullable routeError, DBXCallError * _Nullable error) {
            if (result) {
                MyLog(@"%@\n", result);
                if (result.changes) {
                    [TestFormat printOffset:@"Changes found"];
                    listFolderContinue(cursor);
                } else {
                    [TestFormat printOffset:@"Improperly set up changes trigger"];
                }
            } else {
                [TestFormat abort:routeError error:error];
            }
        }];

        [weakSelf longpollCopy];
    };

    [TestFormat printSubTestBegin:NSStringFromSelector(_cmd)];
    [TestFormat printOffset:@"Acquring cursor"];
    [[_tester.files listFolderGetLatestCursorWithPath:DBXTestData.testFolderPath] responseWithCompletionHandler:^(DBXFilesListFolderGetLatestCursorResult * _Nullable result, DBXFilesListFolderError * _Nullable routeError, DBXCallError * _Nullable error) {
        if (result) {
            [TestFormat printOffset:@"Cursor acquired"];
            MyLog(@"%@\n", result);
            listFolderLongpoll(result.cursor);
        } else {
            [TestFormat abort:routeError error:error];
        }
    }];
}

@end

@implementation SharingTests

- (instancetype)init:(DropboxTester *)tester {
    self = [super init];
    if (self) {
        _tester = tester;
        _sharedFolderId = @"placeholder";
        _sharedLink = @"placeholder";
    }
    return self;
}

- (void)shareFolder:(void (^)(void))nextTest {
    [TestFormat printSubTestBegin:NSStringFromSelector(_cmd)];
    [[_tester.sharing shareFolderWithPath:DBXTestData.testShareFolderPath] responseWithCompletionHandler:^(DBXSharingShareFolderLaunch * _Nullable result, DBXSharingShareFolderError * _Nullable routeError, DBXCallError * _Nullable error) {
        if (result) {
            if (result.asAsyncJobId) {
                [TestFormat
                 printOffset:[NSString stringWithFormat:@"Folder not yet shared! Job id: %@. Please adjust test order.",
                              result.asAsyncJobId]];
            } else if (result.asComplete) {
                MyLog(@"%@\n", result.asComplete);
                self->_sharedFolderId = result.asComplete.complete.sharedFolderId;
                [TestFormat printSubTestEnd:NSStringFromSelector(_cmd)];
                nextTest();
            } else {
                [TestFormat printOffset:[NSString stringWithFormat:@"Unknown result: %@", result]];
                [TestFormat abort:routeError error:error];
            }
        } else {
            DBXRateLimitError *rateLimitError = error.asRateLimitError;
            if (rateLimitError) {
                sleep(rateLimitError.error.retryAfter.unsignedIntValue);
                [self shareFolder:nextTest];
            } else {
                [TestFormat abort:routeError error:error];
            }
        }
    }];
}

- (void)createSharedLinkWithSettings:(void (^)(void))nextTest {
    [TestFormat printSubTestBegin:NSStringFromSelector(_cmd)];
    [[_tester.sharing createSharedLinkWithSettingsWithPath:DBXTestData.testShareFolderPath] responseWithCompletionHandler:^(DBXSharingSharedLinkMetadata * _Nullable result, DBXSharingCreateSharedLinkWithSettingsError * _Nullable routeError, DBXCallError * _Nullable error) {
        if (result) {
            MyLog(@"%@\n", result);
            self->_sharedLink = result.url;
            [TestFormat printSubTestEnd:NSStringFromSelector(_cmd)];
            nextTest();
        } else {
            [TestFormat abort:routeError error:error];
        }
    }];
}

- (void)getFolderMetadata:(void (^)(void))nextTest {
    [TestFormat printSubTestBegin:NSStringFromSelector(_cmd)];
    [[_tester.sharing getFolderMetadataWithSharedFolderId:_sharedFolderId] responseWithCompletionHandler:^(DBXSharingSharedFolderMetadata * _Nullable result, DBXSharingSharedFolderAccessError * _Nullable routeError, DBXCallError * _Nullable error) {
        if (result) {
            MyLog(@"%@\n", result);
            [TestFormat printSubTestEnd:NSStringFromSelector(_cmd)];
            nextTest();
        } else {
            [TestFormat abort:routeError error:error];
        }
    }];
}

- (void)addFolderMember:(void (^)(void))nextTest {
    [TestFormat printSubTestBegin:NSStringFromSelector(_cmd)];
    DBXSharingMemberSelectorEmail *memberSelector = [[DBXSharingMemberSelectorEmail alloc] init: DBXTestData.accountId3Email];
    DBXSharingAddMember *addFolderMemberArg = [[DBXSharingAddMember alloc] initWithMember:memberSelector accessLevel:[[DBXSharingAccessLevelViewer alloc] init]];
    [[_tester.sharing addFolderMemberWithSharedFolderId:_sharedFolderId members:@[addFolderMemberArg]] responseWithCompletionHandler:^(DBXSharingAddFolderMemberError * _Nullable routeError, DBXCallError * _Nullable error) {
        if (routeError || error) {
            [TestFormat abort:routeError error:error];
        } else {
            [TestFormat printOffset:@"Folder member added"];
            [TestFormat printSubTestEnd:NSStringFromSelector(_cmd)];
            nextTest();
        }
    }];
}

- (void)listFolderMembers:(void (^)(void))nextTest {
    [TestFormat printSubTestBegin:NSStringFromSelector(_cmd)];
    [[_tester.sharing listFolderMembersWithSharedFolderId:_sharedFolderId] responseWithCompletionHandler:^(DBXSharingSharedFolderMembers * _Nullable result, DBXSharingSharedFolderAccessError * _Nullable routeError, DBXCallError * _Nullable error) {
        if (result) {
            MyLog(@"%@\n", result);
            [TestFormat printSubTestEnd:NSStringFromSelector(_cmd)];
            nextTest();
        } else {
            [TestFormat abort:routeError error:error];
        }
    }];
}

- (void)listFolders:(void (^)(void))nextTest {
    [TestFormat printSubTestBegin:NSStringFromSelector(_cmd)];
    [[_tester.sharing listFoldersWithLimit:[NSNumber numberWithInteger:2] actions:nil] responseWithCompletionHandler:^(DBXSharingListFoldersResult * _Nullable result, DBXCallError * _Nullable error) {
        if (result) {
            MyLog(@"%@\n", result);
            [TestFormat printSubTestEnd:NSStringFromSelector(_cmd)];
            nextTest();
        } else {
            [TestFormat abort:nil error:error];
        }
    }];
}

- (void)listSharedLinks:(void (^)(void))nextTest {
    [TestFormat printSubTestBegin:NSStringFromSelector(_cmd)];
    [[_tester.sharing listSharedLinks] responseWithCompletionHandler:^(DBXSharingListSharedLinksResult * _Nullable result, DBXSharingListSharedLinksError * _Nullable routeError, DBXCallError * _Nullable error) {
        if (result) {
            MyLog(@"%@\n", result);
            [TestFormat printSubTestEnd:NSStringFromSelector(_cmd)];
            nextTest();
        } else {
            [TestFormat abort:routeError error:error];
        }
    }];
}

- (void)checkJobStatus:(NSString *)asyncJobId retryCount:(int)retryCount nextTest:(void (^)(void))nextTest{
    [[_tester.sharing checkJobStatusWithAsyncJobId:asyncJobId] responseWithCompletionHandler:^(DBXSharingJobStatus * _Nullable result, DBXAsyncPollError * _Nullable routeError, DBXCallError * _Nullable error) {
        if (result) {
            MyLog(@"%@\n", result);
            if ([result asInProgress]) {
                [TestFormat
                 printOffset:[NSString
                              stringWithFormat:@"Folder member not yet removed! Job id: %@. Please adjust test order.",
                              asyncJobId]];

                if (retryCount > 0) {
                    MyLog(@"Sleeping for 3 seconds, then trying again");
                    for (int i = 0; i < 3; i++) {
                        sleep(1);
                        MyLog(@".");
                    }
                    MyLog(@"\n");
                    [TestFormat printOffset:@"Retrying!"];
                    [self checkJobStatus:asyncJobId retryCount:retryCount - 1 nextTest:nextTest];
                }
            } else if ([result asComplete]) {
                [TestFormat printSubTestEnd:NSStringFromSelector(_cmd)];
                nextTest();
            } else if ([result asFailed]) {
                [TestFormat abort:routeError error:error];
            }
        } else {
            [TestFormat abort:routeError error:error];
        }
    }];
}

- (void)removeFolderMember:(void (^)(void))nextTest {
    [TestFormat printSubTestBegin:NSStringFromSelector(_cmd)];

    DBXSharingMemberSelectorEmail *memberSelector = [[DBXSharingMemberSelectorEmail alloc] init: DBXTestData.accountId3Email];

    void (^checkJobStatus)(NSString *) = ^(NSString *asyncJobId) {
        [self checkJobStatus:asyncJobId retryCount:5 nextTest:nextTest];
    };

    [[_tester.sharing removeFolderMemberWithSharedFolderId:_sharedFolderId member:memberSelector leaveACopy:[NSNumber numberWithBool:NO]] responseWithCompletionHandler:^(DBXAsyncLaunchResultBase * _Nullable result, DBXSharingRemoveFolderMemberError * _Nullable routeError, DBXCallError * _Nullable error) {
        if (result) {
            MyLog(@"%@\n", result);
            if ([result asAsyncJobId]) {
                [TestFormat printOffset:[NSString stringWithFormat:@"Folder member not yet removed! Job id: %@",
                                         result.asAsyncJobId.asyncJobId]];
                MyLog(@"Sleeping for 5 seconds, then trying again");
                for (int i = 0; i < 5; i++) {
                    sleep(1);
                    MyLog(@".");
                }
                MyLog(@"\n");
                [TestFormat printOffset:@"Retrying!"];
                checkJobStatus(result.asAsyncJobId.asyncJobId);
            } else {
                [TestFormat printOffset:[NSString stringWithFormat:@"removeFolderMember result not properly handled."]];
            }
        } else {
            [TestFormat abort:routeError error:error];
        }
    }];
}

- (void)revokeSharedLink:(void (^)(void))nextTest {
    [TestFormat printSubTestBegin:NSStringFromSelector(_cmd)];
    [[_tester.sharing revokeSharedLinkWithUrl:_sharedLink] responseWithCompletionHandler:^(DBXSharingRevokeSharedLinkError * _Nullable routeError, DBXCallError * _Nullable error) {
        if (routeError || error) {
            [TestFormat abort:routeError error:error];
        } else {
            [TestFormat printOffset:@"Shared link revoked"];
            [TestFormat printSubTestEnd:NSStringFromSelector(_cmd)];
            nextTest();
        }
    }];
}

- (void)unmountFolder:(void (^)(void))nextTest {
    [TestFormat printSubTestBegin:NSStringFromSelector(_cmd)];
    [[_tester.sharing unmountFolderWithSharedFolderId:_sharedFolderId] responseWithCompletionHandler:^(DBXSharingUnmountFolderError * _Nullable routeError, DBXCallError * _Nullable error) {
        if (routeError || error) {
            [TestFormat abort:routeError error:error];
        } else {
            [TestFormat printOffset:@"Folder unmounted"];
            [TestFormat printSubTestEnd:NSStringFromSelector(_cmd)];
            nextTest();
        }
    }];
}

- (void)mountFolder:(void (^)(void))nextTest {
    [TestFormat printSubTestBegin:NSStringFromSelector(_cmd)];
    [[_tester.sharing mountFolderWithSharedFolderId:_sharedFolderId] responseWithCompletionHandler:^(DBXSharingSharedFolderMetadata * _Nullable result, DBXSharingMountFolderError * _Nullable routeError, DBXCallError * _Nullable error) {
        if (result) {
            MyLog(@"%@\n", result);
            [TestFormat printOffset:@"Folder mounted"];
            [TestFormat printSubTestEnd:NSStringFromSelector(_cmd)];
            nextTest();
        } else {
            [TestFormat abort:routeError error:error];
        }
    }];
}

- (void)updateFolderPolicy:(void (^)(void))nextTest {
    [TestFormat printSubTestBegin:NSStringFromSelector(_cmd)];
    [[_tester.sharing updateFolderPolicyWithSharedFolderId:_sharedFolderId] responseWithCompletionHandler:^(DBXSharingSharedFolderMetadata * _Nullable result, DBXSharingUpdateFolderPolicyError * _Nullable routeError, DBXCallError * _Nullable error) {
        if (result) {
            MyLog(@"%@\n", result);
            [TestFormat printSubTestEnd:NSStringFromSelector(_cmd)];
            nextTest();
        } else {
            [TestFormat abort:routeError error:error];
        }
    }];
}

- (void)unshareFolder:(void (^)(void))nextTest {
    [TestFormat printSubTestBegin:NSStringFromSelector(_cmd)];
    [[_tester.sharing unshareFolderWithSharedFolderId:_sharedFolderId] responseWithCompletionHandler:^(DBXAsyncLaunchEmptyResult * _Nullable result, DBXSharingUnshareFolderError * _Nullable routeError, DBXCallError * _Nullable error) {
        if (result) {
            MyLog(@"%@\n", result);
            [TestFormat printSubTestEnd:NSStringFromSelector(_cmd)];
            nextTest();
        } else {
            [TestFormat abort:routeError error:error];
        }
    }];
}

@end

@implementation UsersTests

- (instancetype)init:(DropboxTester *)tester {
    self = [super init];
    if (self) {
        _tester = tester;
    }
    return self;
}

- (void)getAccount:(void (^)(void))nextTest {
    [TestFormat printSubTestBegin:NSStringFromSelector(_cmd)];
    [[_tester.users getAccountWithAccountId:DBXTestData.accountId] responseWithCompletionHandler:^(DBXUsersBasicAccount * _Nullable result, DBXUsersGetAccountError * _Nullable routeError, DBXCallError * _Nullable error) {
        if (result) {
            MyLog(@"%@\n", result);
            [TestFormat printSubTestEnd:NSStringFromSelector(_cmd)];
            nextTest();
        } else {
            [TestFormat abort:routeError error:error];
        }
    }];
}

- (void)getAccountBatch:(void (^)(void))nextTest {
    [TestFormat printSubTestBegin:NSStringFromSelector(_cmd)];
    NSArray<NSString *> *accountIds = @[DBXTestData.accountId, DBXTestData.accountId2];
    [[_tester.users getAccountBatchWithAccountIds:accountIds] responseWithCompletionHandler:^(NSArray<DBXUsersBasicAccount *> * _Nullable result, DBXUsersGetAccountBatchError * _Nullable routeError, DBXCallError * _Nullable error) {
        if (result) {
            MyLog(@"%@\n", result);
            [TestFormat printSubTestEnd:NSStringFromSelector(_cmd)];
            nextTest();
        } else {
            [TestFormat abort:routeError error:error];
        }
    }];
}

- (void)getCurrentAccount:(void (^)(void))nextTest {
    [TestFormat printSubTestBegin:NSStringFromSelector(_cmd)];
    [[_tester.users getCurrentAccount] responseWithCompletionHandler:^(DBXUsersFullAccount * _Nullable result, DBXCallError * _Nullable error) {
        if (result) {
            MyLog(@"%@\n", result);
            [TestFormat printSubTestEnd:NSStringFromSelector(_cmd)];
            nextTest();
        } else {
            [TestFormat abort:nil error:error];
        }
    }];
}

- (void)getSpaceUsage:(void (^)(void))nextTest {
    [TestFormat printSubTestBegin:NSStringFromSelector(_cmd)];
    [[_tester.users getSpaceUsage] responseWithCompletionHandler:^(DBXUsersSpaceUsage * _Nullable result, DBXCallError * _Nullable error) {
        if (result) {
            MyLog(@"%@\n", result);
            [TestFormat printSubTestEnd:NSStringFromSelector(_cmd)];
            nextTest();
        } else {
            [TestFormat abort:nil error:error];
        }
    }];
}

@end

/**
 Dropbox TEAM API Endpoint Tests
 */

@implementation TeamTests

- (instancetype)init:(DropboxTeamTester *)tester {
    self = [super init];
    if (self) {
        _tester = tester;
    }
    return self;
}

/**
 Permission: TEAM member file access
 */
- (void)initMembersGetInfo:(void (^)(void))nextTest {
    [self initMembersGetInfoAndMemberId:^(NSString * _Nullable memberId) {
        nextTest();
    }];
}

- (void)initMembersGetInfoAndMemberId:(void (^)(NSString * _Nullable))nextTest {
    [TestFormat printSubTestBegin:NSStringFromSelector(_cmd)];
    DBXTeamUserSelectorArgEmail *userSelectArg = [[DBXTeamUserSelectorArgEmail alloc] init:DBXTestData.teamMemberEmail];
    [[_tester.team membersGetInfoWithMembers:@[userSelectArg]] responseWithCompletionHandler:^(NSArray<DBXTeamMembersGetInfoItem *> * _Nullable result, DBXTeamMembersGetInfoError * _Nullable routeError, DBXCallError * _Nullable error) {
        if (result) {
            MyLog(@"%@\n", result);
            DBXTeamMembersGetInfoItem *getInfo = result[0];
            if ([getInfo asIdNotFound]) {
                [TestFormat abort:routeError error:error];
            } else if ([getInfo asMemberInfo]) {
                self->_teamMemberId = getInfo.asMemberInfo.memberInfo.profile.teamMemberId;
                DBXDropboxClientsManager.authorizedClient = [DBXDropboxClientsManager.authorizedTeamClient asMember:self->_teamMemberId];
            }
            [TestFormat printSubTestEnd:NSStringFromSelector(_cmd)];
            nextTest(self->_teamMemberId);
        } else {
            [TestFormat abort:routeError error:error];
        }
    }];
}

- (void)listMemberDevices:(void (^)(void))nextTest {
    [TestFormat printSubTestBegin:NSStringFromSelector(_cmd)];
    [[_tester.team devicesListMemberDevicesWithTeamMemberId:_teamMemberId] responseWithCompletionHandler:^(DBXTeamListMemberDevicesResult * _Nullable result, DBXTeamListMemberDevicesError * _Nullable routeError, DBXCallError * _Nullable error) {
        if (result) {
            MyLog(@"%@\n", result);
            [TestFormat printSubTestEnd:NSStringFromSelector(_cmd)];
            nextTest();
        } else {
            [TestFormat abort:routeError error:error];
        }
    }];
}

- (void)listMembersDevices:(void (^)(void))nextTest {
    [TestFormat printSubTestBegin:NSStringFromSelector(_cmd)];
    [[_tester.team devicesListMembersDevices] responseWithCompletionHandler:^(DBXTeamListMembersDevicesResult * _Nullable result, DBXTeamListMembersDevicesError * _Nullable routeError, DBXCallError * _Nullable error) {
        if (result) {
            MyLog(@"%@\n", result);
            [TestFormat printSubTestEnd:NSStringFromSelector(_cmd)];
            nextTest();
        } else {
            [TestFormat abort:routeError error:error];
        }
    }];
}

- (void)linkedAppsListMemberLinkedApps:(void (^)(void))nextTest {
    [TestFormat printSubTestBegin:NSStringFromSelector(_cmd)];
    [[_tester.team linkedAppsListMemberLinkedAppsWithTeamMemberId:_teamMemberId] responseWithCompletionHandler:^(DBXTeamListMemberAppsResult * _Nullable result, DBXTeamListMemberAppsError * _Nullable routeError, DBXCallError * _Nullable error) {
        if (result) {
            MyLog(@"%@\n", result);
            [TestFormat printSubTestEnd:NSStringFromSelector(_cmd)];
            nextTest();
        } else {
            [TestFormat abort:routeError error:error];
        }
    }];
}

- (void)linkedAppsListMembersLinkedApps:(void (^)(void))nextTest {
    [TestFormat printSubTestBegin:NSStringFromSelector(_cmd)];
    [[_tester.team linkedAppsListMembersLinkedApps] responseWithCompletionHandler:^(DBXTeamListMembersAppsResult * _Nullable result, DBXTeamListMembersAppsError * _Nullable routeError, DBXCallError * _Nullable error) {
        if (result) {
            MyLog(@"%@\n", result);
            [TestFormat printSubTestEnd:NSStringFromSelector(_cmd)];
            nextTest();
        } else {
            [TestFormat abort:routeError error:error];
        }
    }];
}

- (void)getInfo:(void (^)(void))nextTest {
    [TestFormat printSubTestBegin:NSStringFromSelector(_cmd)];
    [[_tester.team getInfo] responseWithCompletionHandler:^(DBXTeamTeamGetInfoResult * _Nullable result, DBXCallError * _Nullable error) {
        if (result) {
            MyLog(@"%@\n", result);
            [TestFormat printSubTestEnd:NSStringFromSelector(_cmd)];
            nextTest();
        } else {
            [TestFormat abort:nil error:error];
        }
    }];
}

/**
 Permission: TEAM member management
 */

- (void)groupsCreate:(void (^)(void))nextTest {
    [TestFormat printSubTestBegin:NSStringFromSelector(_cmd)];
    NSString *groupName = [[NSString alloc] initWithFormat: @"objc-compatibility-%@", DBXTestData.groupName];
    [[_tester.team groupsCreateWithGroupName:groupName addCreatorAsOwner:[NSNumber numberWithBool:NO] groupExternalId:DBXTestData.groupExternalIdDashObjc groupManagementType:nil] responseWithCompletionHandler:^(DBXTeamGroupFullInfo * _Nullable result, DBXTeamGroupCreateError * _Nullable routeError, DBXCallError * _Nullable error) {
        if (result) {
            MyLog(@"%@\n", result);
            [TestFormat printSubTestEnd:NSStringFromSelector(_cmd)];
            nextTest();
        } else {
            [TestFormat abort:routeError error:error];
        }
    }];
}

- (void)groupsGetInfo:(void (^)(void))nextTest {
    [TestFormat printSubTestBegin:NSStringFromSelector(_cmd)];
    DBXTeamGroupsSelector * groupsSelector = [[DBXTeamGroupsSelectorGroupExternalIds alloc] init:@[DBXTestData.groupExternalIdDashObjc]];
    [[_tester.team groupsGetInfoWithGroupsSelector:groupsSelector] responseWithCompletionHandler:^(NSArray<DBXTeamGroupsGetInfoItem *> * _Nullable result, DBXTeamGroupsGetInfoError * _Nullable routeError, DBXCallError * _Nullable error) {
        if (result) {
            MyLog(@"%@\n", result);
            [TestFormat printSubTestEnd:NSStringFromSelector(_cmd)];
            nextTest();
        } else {
            [TestFormat abort:routeError error:error];
        }
    }];
}

- (void)groupsList:(void (^)(void))nextTest {
    [TestFormat printSubTestBegin:NSStringFromSelector(_cmd)];
    [[_tester.team groupsList] responseWithCompletionHandler:^(DBXTeamGroupsListResult * _Nullable result, DBXCallError * _Nullable error) {
        if (result) {
            MyLog(@"%@\n", result);
            [TestFormat printSubTestEnd:NSStringFromSelector(_cmd)];
            nextTest();
        } else {
            [TestFormat abort:nil error:error];
        }
    }];
}

- (void)groupsMembersAdd:(void (^)(void))nextTest {
    [TestFormat printSubTestBegin:NSStringFromSelector(_cmd)];
    DBXTeamGroupSelectorGroupExternalId *groupSelector = [[DBXTeamGroupSelectorGroupExternalId alloc] init:DBXTestData.groupExternalIdDashObjc];
    DBXTeamUserSelectorArg *userSelectorArg = [[DBXTeamUserSelectorArgTeamMemberId alloc] init:_teamMemberId];
    DBXTeamGroupAccessTypeMember *accessType = [[DBXTeamGroupAccessTypeMember alloc] init];
    DBXTeamMemberAccess *memberAccess = [[DBXTeamMemberAccess alloc] initWithUser:userSelectorArg accessType:accessType];

    [[_tester.team groupsMembersAddWithGroup:groupSelector members:@[memberAccess]] responseWithCompletionHandler:^(DBXTeamGroupMembersChangeResult * _Nullable result, DBXTeamGroupMembersAddError * _Nullable routeError, DBXCallError * _Nullable error) {
        if (result) {
            MyLog(@"%@\n", result);
            [TestFormat printSubTestEnd:NSStringFromSelector(_cmd)];
            nextTest();
        } else {
            [TestFormat abort:routeError error:error];
        }
    }];
}

- (void)groupsMembersList:(void (^)(void))nextTest {
    [TestFormat printSubTestBegin:NSStringFromSelector(_cmd)];
    DBXTeamGroupSelectorGroupExternalId *groupSelector = [[DBXTeamGroupSelectorGroupExternalId alloc] init:DBXTestData.groupExternalIdDashObjc];

    [[_tester.team groupsMembersListWithGroup:groupSelector] responseWithCompletionHandler:^(DBXTeamGroupsMembersListResult * _Nullable result, DBXTeamGroupSelectorError * _Nullable routeError, DBXCallError * _Nullable error) {
        if (result) {
            MyLog(@"%@\n", result);
            [TestFormat printSubTestEnd:NSStringFromSelector(_cmd)];
            nextTest();
        } else {
            [TestFormat abort:routeError error:error];
        }
    }];
}

- (void)groupsUpdate:(void (^)(void))nextTest {
//    [TestFormat printSubTestBegin:NSStringFromSelector(_cmd)];
//    DBXTeamGroupSelectorGroupExternalId *groupSelector = [[DBXTeamGroupSelectorGroupExternalId alloc] init:DBXTestData.groupExternalIdDashObjc];
//
//    [[_tester.team groupsUpdateWithGroup:groupSelector returnMembers:[NSNumber numberWithBool:YES] newGroupName:@"New Group Name ObjC" newGroupExternalId:nil newGroupManagementType:nil] responseWithCompletionHandler:^(DBXTeamGroupFullInfo * _Nullable result, DBXTeamGroupUpdateError * _Nullable routeError, DBXCallError * _Nullable error) {
//        if (result) {
//            MyLog(@"%@\n", result);
//            [TestFormat printSubTestEnd:NSStringFromSelector(_cmd)];
//            nextTest();
//        } else {
//            [TestFormat abort:routeError error:error];
//        }
//    }];
    nextTest();
}

- (void)checkGroupDeleteStatus:(NSString *)jobId nextTest:(void (^)(void))nextTest retryCount:(int)retryCount {
    [[_tester.team groupsJobStatusGetWithAsyncJobId:jobId] responseWithCompletionHandler:^(DBXAsyncPollEmptyResult * _Nullable result, DBXTeamGroupsPollError * _Nullable routeError, DBXCallError * _Nullable error) {
        if (result) {
            if (result.asInProgress) {
                if (retryCount == 0) {
                    [TestFormat abort:routeError error:error];
                }
                [TestFormat printOffset:@"Waiting for deletion..."];
                sleep(1);
                [self checkGroupDeleteStatus:jobId nextTest:nextTest retryCount:retryCount - 1];
            } else {
                [TestFormat printOffset:@"Deleted"];
                [TestFormat printSubTestEnd:NSStringFromSelector(_cmd)];
                nextTest();
            }
        } else {
            [TestFormat abort:routeError error:error];
        }
    }];
}

- (void)groupsDelete:(void (^)(void))nextTest {
    [TestFormat printSubTestBegin:NSStringFromSelector(_cmd)];

    void (^jobStatus)(NSString *) = ^(NSString *jobId) {
        [self checkGroupDeleteStatus:jobId nextTest:nextTest retryCount:3];
    };

    DBXTeamGroupSelectorGroupExternalId *groupSelector = [[DBXTeamGroupSelectorGroupExternalId alloc] init:DBXTestData.groupExternalIdDashObjc];

    [[_tester.team groupsDeleteWithGroupSelector:groupSelector] responseWithCompletionHandler:^(DBXAsyncLaunchEmptyResult * _Nullable result, DBXTeamGroupDeleteError * _Nullable routeError, DBXCallError * _Nullable error) {
        if (result) {
            if ([result asAsyncJobId]) {
                [TestFormat printOffset:@"Waiting for deletion..."];
                sleep(1);
                jobStatus(result.asAsyncJobId.asyncJobId);
            } else if ([result asComplete]) {
                [TestFormat printOffset:@"Deleted"];
                [TestFormat printSubTestEnd:NSStringFromSelector(_cmd)];
                nextTest();
            }
        } else {
            [TestFormat abort:routeError error:error];
        }
    }];
}

- (void)membersAdd:(void (^)(void))nextTest {
    [TestFormat printSubTestBegin:NSStringFromSelector(_cmd)];
    void (^jobStatus)(NSString *) = ^(NSString *jobId) {
        [[self->_tester.team membersAddJobStatusGetWithAsyncJobId:jobId] responseWithCompletionHandler:^(DBXTeamMembersAddJobStatus * _Nullable result, DBXAsyncPollError * _Nullable routeError, DBXCallError * _Nullable error) {
            if (result) {
                MyLog(@"%@\n", result);
                if ([result asInProgress]) {
                    [TestFormat printOffset:@"Took too long to add"];
                    [TestFormat abort:routeError error:error];
                } else if ([result asComplete]) {
                    DBXTeamMemberAddResult *addResult = result.asComplete.complete[0];
                    if ([addResult asSuccess]) {
                        self->_teamMemberId2 = addResult.asSuccess.success.profile.teamMemberId;
                    } else {
                        [TestFormat abort:routeError error:error];
                    }
                    [TestFormat printOffset:@"Member added"];
                    [TestFormat printSubTestEnd:NSStringFromSelector(_cmd)];
                    nextTest();
                }
            } else {
                [TestFormat abort:routeError error:error];
            }
        }];
    };

    DBXTeamMemberAddArg *memberAddArg = [[DBXTeamMemberAddArg alloc] initWithMemberEmail:DBXTestData.newMemberEmail memberGivenName:@"FirstName" memberSurname:@"LastName" memberExternalId:nil memberPersistentId:nil sendWelcomeEmail:[NSNumber numberWithBool:YES] isDirectoryRestricted:nil role:[[DBXTeamAdminTierMemberOnly alloc] init]];
    [[_tester.team membersAddWithNewMembers:@[memberAddArg]] responseWithCompletionHandler:^(DBXTeamMembersAddLaunch * _Nullable result, DBXCallError * _Nullable error) {
        if (result) {
            if ([result asAsyncJobId]) {
                [TestFormat printOffset:@"Result incomplete..."];
                jobStatus(result.asAsyncJobId.asyncJobId);
            } else if ([result asComplete]) {
                DBXTeamMemberAddResult *addResult = result.asComplete.complete[0];
                if ([addResult asSuccess]) {
                    self->_teamMemberId2 = addResult.asSuccess.success.profile.teamMemberId;
                } else if ([addResult asUserAlreadyOnTeam]) {
                    [TestFormat printOffset:@"User already on team"];
                } else {
                    [TestFormat abort:nil error:error];
                }
                [TestFormat printOffset:@"Member added"];
                [TestFormat printSubTestEnd:NSStringFromSelector(_cmd)];
                nextTest();
            }
        } else {
            [TestFormat abort:nil error:error];
        }
    }];
}

- (void)membersGetInfo:(void (^)(void))nextTest {
    [TestFormat printSubTestBegin:NSStringFromSelector(_cmd)];
    DBXTeamUserSelectorArgTeamMemberId *userSelectArg = [[DBXTeamUserSelectorArgTeamMemberId alloc] init:_teamMemberId];
    [[_tester.team membersGetInfoWithMembers:@[userSelectArg]] responseWithCompletionHandler:^(NSArray<DBXTeamMembersGetInfoItem *> * _Nullable result, DBXTeamMembersGetInfoError * _Nullable routeError, DBXCallError * _Nullable error) {
        if (result) {
            MyLog(@"%@\n", result);
            [TestFormat printSubTestEnd:NSStringFromSelector(_cmd)];
            nextTest();
        } else {
            [TestFormat abort:routeError error:error];
        }
    }];
}

- (void)membersList:(void (^)(void))nextTest {
    [TestFormat printSubTestBegin:NSStringFromSelector(_cmd)];
    [[_tester.team membersListWithLimit:[NSNumber numberWithInt:2] includeRemoved:[NSNumber numberWithBool:NO]] responseWithCompletionHandler:^(DBXTeamMembersListResult * _Nullable result, DBXTeamMembersListError * _Nullable routeError, DBXCallError * _Nullable error) {
        if (result) {
            MyLog(@"%@\n", result);
            [TestFormat printSubTestEnd:NSStringFromSelector(_cmd)];
            nextTest();
        } else {
            [TestFormat abort:routeError error:error];
        }
    }];
}

- (void)membersSendWelcomeEmail:(void (^)(void))nextTest {
    [TestFormat printSubTestBegin:NSStringFromSelector(_cmd)];
    DBXTeamUserSelectorArgTeamMemberId *userSelectArg = [[DBXTeamUserSelectorArgTeamMemberId alloc] init:_teamMemberId];
    [[_tester.team membersSendWelcomeEmailWithUserSelectorArg:userSelectArg] responseWithCompletionHandler:^(DBXTeamMembersSendWelcomeError * _Nullable routeError, DBXCallError * _Nullable error) {
        if (!routeError && !error) {
            [TestFormat printOffset:@"Welcome email sent!"];
            [TestFormat printSubTestEnd:NSStringFromSelector(_cmd)];
            nextTest();
        } else {
            [TestFormat abort:routeError error:error];
        }
    }];
}

- (void)membersSetAdminPermissions:(void (^)(void))nextTest {
    [TestFormat printSubTestBegin:NSStringFromSelector(_cmd)];
    DBXTeamUserSelectorArgEmail *userSelectArg = [[DBXTeamUserSelectorArgEmail alloc] init:DBXTestData.newMemberEmail];
    DBXTeamAdminTierTeamAdmin *role = [[DBXTeamAdminTierTeamAdmin alloc] init];
    [[_tester.team membersSetAdminPermissionsWithUser:userSelectArg newRole:role] responseWithCompletionHandler:^(DBXTeamMembersSetPermissionsResult * _Nullable result, DBXTeamMembersSetPermissionsError * _Nullable routeError, DBXCallError * _Nullable error) {
        if (result) {
            MyLog(@"%@\n", result);
            [TestFormat printSubTestEnd:NSStringFromSelector(_cmd)];
            nextTest();
        } else {
            [TestFormat abort:routeError error:error];
        }
    }];
}

- (void)membersSetProfile:(void (^)(void))nextTest {
    [TestFormat printSubTestBegin:NSStringFromSelector(_cmd)];
    DBXTeamUserSelectorArgEmail *userSelectArg = [[DBXTeamUserSelectorArgEmail alloc] init:DBXTestData.newMemberEmail];
    [[_tester.team membersSetProfileWithUser:userSelectArg newEmail:nil newExternalId:nil newGivenName:@"NewFirstName" newSurname:nil newPersistentId:nil newIsDirectoryRestricted:nil] responseWithCompletionHandler:^(DBXTeamTeamMemberInfo * _Nullable result, DBXTeamMembersSetProfileError * _Nullable routeError, DBXCallError * _Nullable error) {
        if (result) {
            MyLog(@"%@\n", result);
            [TestFormat printSubTestEnd:NSStringFromSelector(_cmd)];
            nextTest();
        } else {
            [TestFormat abort:routeError error:error];
        }
    }];
}

- (void)membersRemove:(void (^)(void))nextTest {
    [TestFormat printSubTestBegin:NSStringFromSelector(_cmd)];
    void (^jobStatus)(NSString *) = ^(NSString *jobId) {
        [[self->_tester.team membersRemoveJobStatusGetWithAsyncJobId:jobId] responseWithCompletionHandler:^(DBXAsyncPollEmptyResult * _Nullable result, DBXAsyncPollError * _Nullable routeError, DBXCallError * _Nullable error) {
            if (result) {
                MyLog(@"%@\n", result);
                if ([result asInProgress]) {
                    [TestFormat abort:routeError error:error];
                } else if ([result asComplete]) {
                    [TestFormat printOffset:@"Member removed"];
                    [TestFormat printSubTestEnd:NSStringFromSelector(_cmd)];
                    nextTest();
                }
            } else {
                [TestFormat abort:routeError error:error];
            }
        }];
    };

    DBXTeamUserSelectorArgEmail *userSelectArg = [[DBXTeamUserSelectorArgEmail alloc] init:DBXTestData.newMemberEmail];
    [[_tester.team membersRemoveWithUser:userSelectArg] responseWithCompletionHandler:^(DBXAsyncLaunchEmptyResult * _Nullable result, DBXTeamMembersRemoveError * _Nullable routeError, DBXCallError * _Nullable error) {
        if (result) {
            if ([result asAsyncJobId]) {
                [TestFormat printOffset:@"Result incomplete. Waiting to query status..."];
                sleep(2);
                jobStatus(result.asAsyncJobId.asyncJobId);
            } else if ([result asComplete]) {
                [TestFormat printOffset:@"Member removed"];
                [TestFormat printSubTestEnd:NSStringFromSelector(_cmd)];
                nextTest();
            }
        } else {
            [TestFormat abort:routeError error:error];
        }
    }];
}

@end

static int smallDividerSize = 150;

@implementation TestFormat

+ (void)abort:(NSObject * _Nullable)routeError error:(DBXCallError * _Nullable)error {
    [self printErrors:routeError error:error];
    MyLog(@"Terminating....\n");
    NSException* myException = [NSException
            exceptionWithName:@"TestFailure"
            reason:[NSString stringWithFormat:@"RouteError: %@\nError: %@", routeError, error]
            userInfo:nil];
    @throw myException;
}

+ (void)printErrors:(NSObject * _Nullable)routeError error:(DBXCallError * _Nullable)error {
    [self printRouteError: routeError];
    [self printError: error];
}

+ (void)printRouteError:(NSObject * _Nullable)routeError {
    MyLog(@"ROUTE ERROR: %@\n", routeError);
}

+ (void)printError:(DBXCallError *)error {
    MyLog(@"ERROR: %@\n", error);
}

+ (void)printSentProgress:(int64_t)bytesSent
           totalBytesSent:(int64_t)totalBytesSent
 totalBytesExpectedToSend:(int64_t)totalBytesExpectedToSend {
    MyLog(@"PROGRESS: bytesSent:%lld  totalBytesSent:%lld  totalBytesExpectedToSend:%lld\n\n", bytesSent, totalBytesSent,
          totalBytesExpectedToSend);
}

+ (void)printTestBegin:(NSString *)title {
    [self printLargeDivider];
    [self printTitle:title];
    [self printLargeDivider];
    [self printOffset:@"Beginning....."];
}

+ (void)printTestEnd {
    [self printOffset:@"Test Group Completed"];
    [self printLargeDivider];
}

+ (void)printAllTestsEnd {
    [self printLargeDivider];
    [self printOffset:@"ALL TESTS COMPLETED"];
    [self printLargeDivider];
}

+ (void)printSubTestBegin:(NSString *)title {
    [self printSmallDivider];
    [self printTitle:title];
    MyLog(@"\n");
}

+ (void)printSubTestEnd:(NSString *)result {
    MyLog(@"\n");
    [self printTitle:result];
}

+ (void)printTitle:(NSString *)title {
    MyLog(@"     %@\n", title);
}

+ (void)printOffset:(NSString *)str {
    MyLog(@"\n");
    MyLog(@"     *  %@  *\n", str);
    MyLog(@"\n");
}

+ (void)printSmallDivider {
    NSMutableString *result = [@"" mutableCopy];
    for (int i = 0; i < smallDividerSize; i++) {
        [result appendString:@"-"];
    }
    MyLog(@"%@\n", result);
}

+ (void)printLargeDivider {
    NSMutableString *result = [@"" mutableCopy];
    for (int i = 0; i < smallDividerSize; i++) {
        [result appendString:@"-"];
    }
    MyLog(@"%@\n", result);
}

@end
