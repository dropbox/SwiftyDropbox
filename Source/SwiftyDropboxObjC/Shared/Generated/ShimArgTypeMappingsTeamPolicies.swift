///
/// Copyright (c) 2024 Dropbox, Inc. All rights reserved.
///
/// Auto-generated by Stone, do not modify.
///

import Foundation
import stone_sdk_objc
import stone_sdk_swift
import stone_sdk_swift_objc

func mapDBTEAMPOLICIESCameraUploadsPolicyStateToDBXOptional(object: DBTEAMPOLICIESCameraUploadsPolicyState?) -> DBXTeamPoliciesCameraUploadsPolicyState? {
    guard let object = object else { return nil }
    return mapDBTEAMPOLICIESCameraUploadsPolicyStateToDBX(object: object)
}

func mapDBTEAMPOLICIESCameraUploadsPolicyStateToDBX(object: DBTEAMPOLICIESCameraUploadsPolicyState) -> DBXTeamPoliciesCameraUploadsPolicyState {
    if object.isDisabled() {
        return DBXTeamPoliciesCameraUploadsPolicyStateDisabled()
    }
    if object.isEnabled() {
        return DBXTeamPoliciesCameraUploadsPolicyStateEnabled()
    }
    if object.isOther() {
        return DBXTeamPoliciesCameraUploadsPolicyStateOther()
    }
    fatalError("codegen error")
}

func mapDBTEAMPOLICIESComputerBackupPolicyStateToDBXOptional(object: DBTEAMPOLICIESComputerBackupPolicyState?) -> DBXTeamPoliciesComputerBackupPolicyState? {
    guard let object = object else { return nil }
    return mapDBTEAMPOLICIESComputerBackupPolicyStateToDBX(object: object)
}

func mapDBTEAMPOLICIESComputerBackupPolicyStateToDBX(object: DBTEAMPOLICIESComputerBackupPolicyState) -> DBXTeamPoliciesComputerBackupPolicyState {
    if object.isDisabled() {
        return DBXTeamPoliciesComputerBackupPolicyStateDisabled()
    }
    if object.isEnabled() {
        return DBXTeamPoliciesComputerBackupPolicyStateEnabled()
    }
    if object.isDefault_() {
        return DBXTeamPoliciesComputerBackupPolicyStateDefault_()
    }
    if object.isOther() {
        return DBXTeamPoliciesComputerBackupPolicyStateOther()
    }
    fatalError("codegen error")
}

func mapDBTEAMPOLICIESEmmStateToDBXOptional(object: DBTEAMPOLICIESEmmState?) -> DBXTeamPoliciesEmmState? {
    guard let object = object else { return nil }
    return mapDBTEAMPOLICIESEmmStateToDBX(object: object)
}

func mapDBTEAMPOLICIESEmmStateToDBX(object: DBTEAMPOLICIESEmmState) -> DBXTeamPoliciesEmmState {
    if object.isDisabled() {
        return DBXTeamPoliciesEmmStateDisabled()
    }
    if object.isOptional() {
        return DBXTeamPoliciesEmmStateOptional()
    }
    if object.isRequired() {
        return DBXTeamPoliciesEmmStateRequired()
    }
    if object.isOther() {
        return DBXTeamPoliciesEmmStateOther()
    }
    fatalError("codegen error")
}

func mapDBTEAMPOLICIESExternalDriveBackupPolicyStateToDBXOptional(object: DBTEAMPOLICIESExternalDriveBackupPolicyState?)
    -> DBXTeamPoliciesExternalDriveBackupPolicyState? {
    guard let object = object else { return nil }
    return mapDBTEAMPOLICIESExternalDriveBackupPolicyStateToDBX(object: object)
}

func mapDBTEAMPOLICIESExternalDriveBackupPolicyStateToDBX(object: DBTEAMPOLICIESExternalDriveBackupPolicyState)
    -> DBXTeamPoliciesExternalDriveBackupPolicyState {
    if object.isDisabled() {
        return DBXTeamPoliciesExternalDriveBackupPolicyStateDisabled()
    }
    if object.isEnabled() {
        return DBXTeamPoliciesExternalDriveBackupPolicyStateEnabled()
    }
    if object.isDefault_() {
        return DBXTeamPoliciesExternalDriveBackupPolicyStateDefault_()
    }
    if object.isOther() {
        return DBXTeamPoliciesExternalDriveBackupPolicyStateOther()
    }
    fatalError("codegen error")
}

func mapDBTEAMPOLICIESFileLockingPolicyStateToDBXOptional(object: DBTEAMPOLICIESFileLockingPolicyState?) -> DBXTeamPoliciesFileLockingPolicyState? {
    guard let object = object else { return nil }
    return mapDBTEAMPOLICIESFileLockingPolicyStateToDBX(object: object)
}

func mapDBTEAMPOLICIESFileLockingPolicyStateToDBX(object: DBTEAMPOLICIESFileLockingPolicyState) -> DBXTeamPoliciesFileLockingPolicyState {
    if object.isDisabled() {
        return DBXTeamPoliciesFileLockingPolicyStateDisabled()
    }
    if object.isEnabled() {
        return DBXTeamPoliciesFileLockingPolicyStateEnabled()
    }
    if object.isOther() {
        return DBXTeamPoliciesFileLockingPolicyStateOther()
    }
    fatalError("codegen error")
}

func mapDBTEAMPOLICIESFileProviderMigrationPolicyStateToDBXOptional(object: DBTEAMPOLICIESFileProviderMigrationPolicyState?)
    -> DBXTeamPoliciesFileProviderMigrationPolicyState? {
    guard let object = object else { return nil }
    return mapDBTEAMPOLICIESFileProviderMigrationPolicyStateToDBX(object: object)
}

func mapDBTEAMPOLICIESFileProviderMigrationPolicyStateToDBX(object: DBTEAMPOLICIESFileProviderMigrationPolicyState)
    -> DBXTeamPoliciesFileProviderMigrationPolicyState {
    if object.isDisabled() {
        return DBXTeamPoliciesFileProviderMigrationPolicyStateDisabled()
    }
    if object.isEnabled() {
        return DBXTeamPoliciesFileProviderMigrationPolicyStateEnabled()
    }
    if object.isDefault_() {
        return DBXTeamPoliciesFileProviderMigrationPolicyStateDefault_()
    }
    if object.isOther() {
        return DBXTeamPoliciesFileProviderMigrationPolicyStateOther()
    }
    fatalError("codegen error")
}

func mapDBTEAMPOLICIESGroupCreationToDBXOptional(object: DBTEAMPOLICIESGroupCreation?) -> DBXTeamPoliciesGroupCreation? {
    guard let object = object else { return nil }
    return mapDBTEAMPOLICIESGroupCreationToDBX(object: object)
}

func mapDBTEAMPOLICIESGroupCreationToDBX(object: DBTEAMPOLICIESGroupCreation) -> DBXTeamPoliciesGroupCreation {
    if object.isAdminsAndMembers() {
        return DBXTeamPoliciesGroupCreationAdminsAndMembers()
    }
    if object.isAdminsOnly() {
        return DBXTeamPoliciesGroupCreationAdminsOnly()
    }
    fatalError("codegen error")
}

func mapDBTEAMPOLICIESOfficeAddInPolicyToDBXOptional(object: DBTEAMPOLICIESOfficeAddInPolicy?) -> DBXTeamPoliciesOfficeAddInPolicy? {
    guard let object = object else { return nil }
    return mapDBTEAMPOLICIESOfficeAddInPolicyToDBX(object: object)
}

func mapDBTEAMPOLICIESOfficeAddInPolicyToDBX(object: DBTEAMPOLICIESOfficeAddInPolicy) -> DBXTeamPoliciesOfficeAddInPolicy {
    if object.isDisabled() {
        return DBXTeamPoliciesOfficeAddInPolicyDisabled()
    }
    if object.isEnabled() {
        return DBXTeamPoliciesOfficeAddInPolicyEnabled()
    }
    if object.isOther() {
        return DBXTeamPoliciesOfficeAddInPolicyOther()
    }
    fatalError("codegen error")
}

func mapDBTEAMPOLICIESPaperDefaultFolderPolicyToDBXOptional(object: DBTEAMPOLICIESPaperDefaultFolderPolicy?) -> DBXTeamPoliciesPaperDefaultFolderPolicy? {
    guard let object = object else { return nil }
    return mapDBTEAMPOLICIESPaperDefaultFolderPolicyToDBX(object: object)
}

func mapDBTEAMPOLICIESPaperDefaultFolderPolicyToDBX(object: DBTEAMPOLICIESPaperDefaultFolderPolicy) -> DBXTeamPoliciesPaperDefaultFolderPolicy {
    if object.isEveryoneInTeam() {
        return DBXTeamPoliciesPaperDefaultFolderPolicyEveryoneInTeam()
    }
    if object.isInviteOnly() {
        return DBXTeamPoliciesPaperDefaultFolderPolicyInviteOnly()
    }
    if object.isOther() {
        return DBXTeamPoliciesPaperDefaultFolderPolicyOther()
    }
    fatalError("codegen error")
}

func mapDBTEAMPOLICIESPaperDeploymentPolicyToDBXOptional(object: DBTEAMPOLICIESPaperDeploymentPolicy?) -> DBXTeamPoliciesPaperDeploymentPolicy? {
    guard let object = object else { return nil }
    return mapDBTEAMPOLICIESPaperDeploymentPolicyToDBX(object: object)
}

func mapDBTEAMPOLICIESPaperDeploymentPolicyToDBX(object: DBTEAMPOLICIESPaperDeploymentPolicy) -> DBXTeamPoliciesPaperDeploymentPolicy {
    if object.isFull() {
        return DBXTeamPoliciesPaperDeploymentPolicyFull()
    }
    if object.isPartial() {
        return DBXTeamPoliciesPaperDeploymentPolicyPartial()
    }
    if object.isOther() {
        return DBXTeamPoliciesPaperDeploymentPolicyOther()
    }
    fatalError("codegen error")
}

func mapDBTEAMPOLICIESPaperDesktopPolicyToDBXOptional(object: DBTEAMPOLICIESPaperDesktopPolicy?) -> DBXTeamPoliciesPaperDesktopPolicy? {
    guard let object = object else { return nil }
    return mapDBTEAMPOLICIESPaperDesktopPolicyToDBX(object: object)
}

func mapDBTEAMPOLICIESPaperDesktopPolicyToDBX(object: DBTEAMPOLICIESPaperDesktopPolicy) -> DBXTeamPoliciesPaperDesktopPolicy {
    if object.isDisabled() {
        return DBXTeamPoliciesPaperDesktopPolicyDisabled()
    }
    if object.isEnabled() {
        return DBXTeamPoliciesPaperDesktopPolicyEnabled()
    }
    if object.isOther() {
        return DBXTeamPoliciesPaperDesktopPolicyOther()
    }
    fatalError("codegen error")
}

func mapDBTEAMPOLICIESPaperEnabledPolicyToDBXOptional(object: DBTEAMPOLICIESPaperEnabledPolicy?) -> DBXTeamPoliciesPaperEnabledPolicy? {
    guard let object = object else { return nil }
    return mapDBTEAMPOLICIESPaperEnabledPolicyToDBX(object: object)
}

func mapDBTEAMPOLICIESPaperEnabledPolicyToDBX(object: DBTEAMPOLICIESPaperEnabledPolicy) -> DBXTeamPoliciesPaperEnabledPolicy {
    if object.isDisabled() {
        return DBXTeamPoliciesPaperEnabledPolicyDisabled()
    }
    if object.isEnabled() {
        return DBXTeamPoliciesPaperEnabledPolicyEnabled()
    }
    if object.isUnspecified() {
        return DBXTeamPoliciesPaperEnabledPolicyUnspecified()
    }
    if object.isOther() {
        return DBXTeamPoliciesPaperEnabledPolicyOther()
    }
    fatalError("codegen error")
}

func mapDBTEAMPOLICIESPasswordControlModeToDBXOptional(object: DBTEAMPOLICIESPasswordControlMode?) -> DBXTeamPoliciesPasswordControlMode? {
    guard let object = object else { return nil }
    return mapDBTEAMPOLICIESPasswordControlModeToDBX(object: object)
}

func mapDBTEAMPOLICIESPasswordControlModeToDBX(object: DBTEAMPOLICIESPasswordControlMode) -> DBXTeamPoliciesPasswordControlMode {
    if object.isDisabled() {
        return DBXTeamPoliciesPasswordControlModeDisabled()
    }
    if object.isEnabled() {
        return DBXTeamPoliciesPasswordControlModeEnabled()
    }
    if object.isOther() {
        return DBXTeamPoliciesPasswordControlModeOther()
    }
    fatalError("codegen error")
}

func mapDBTEAMPOLICIESPasswordStrengthPolicyToDBXOptional(object: DBTEAMPOLICIESPasswordStrengthPolicy?) -> DBXTeamPoliciesPasswordStrengthPolicy? {
    guard let object = object else { return nil }
    return mapDBTEAMPOLICIESPasswordStrengthPolicyToDBX(object: object)
}

func mapDBTEAMPOLICIESPasswordStrengthPolicyToDBX(object: DBTEAMPOLICIESPasswordStrengthPolicy) -> DBXTeamPoliciesPasswordStrengthPolicy {
    if object.isMinimalRequirements() {
        return DBXTeamPoliciesPasswordStrengthPolicyMinimalRequirements()
    }
    if object.isModeratePassword() {
        return DBXTeamPoliciesPasswordStrengthPolicyModeratePassword()
    }
    if object.isStrongPassword() {
        return DBXTeamPoliciesPasswordStrengthPolicyStrongPassword()
    }
    if object.isOther() {
        return DBXTeamPoliciesPasswordStrengthPolicyOther()
    }
    fatalError("codegen error")
}

func mapDBTEAMPOLICIESRolloutMethodToDBXOptional(object: DBTEAMPOLICIESRolloutMethod?) -> DBXTeamPoliciesRolloutMethod? {
    guard let object = object else { return nil }
    return mapDBTEAMPOLICIESRolloutMethodToDBX(object: object)
}

func mapDBTEAMPOLICIESRolloutMethodToDBX(object: DBTEAMPOLICIESRolloutMethod) -> DBXTeamPoliciesRolloutMethod {
    if object.isUnlinkAll() {
        return DBXTeamPoliciesRolloutMethodUnlinkAll()
    }
    if object.isUnlinkMostInactive() {
        return DBXTeamPoliciesRolloutMethodUnlinkMostInactive()
    }
    if object.isAddMemberToExceptions() {
        return DBXTeamPoliciesRolloutMethodAddMemberToExceptions()
    }
    fatalError("codegen error")
}

func mapDBTEAMPOLICIESSharedFolderBlanketLinkRestrictionPolicyToDBXOptional(object: DBTEAMPOLICIESSharedFolderBlanketLinkRestrictionPolicy?)
    -> DBXTeamPoliciesSharedFolderBlanketLinkRestrictionPolicy? {
    guard let object = object else { return nil }
    return mapDBTEAMPOLICIESSharedFolderBlanketLinkRestrictionPolicyToDBX(object: object)
}

func mapDBTEAMPOLICIESSharedFolderBlanketLinkRestrictionPolicyToDBX(object: DBTEAMPOLICIESSharedFolderBlanketLinkRestrictionPolicy)
    -> DBXTeamPoliciesSharedFolderBlanketLinkRestrictionPolicy {
    if object.isMembers() {
        return DBXTeamPoliciesSharedFolderBlanketLinkRestrictionPolicyMembers()
    }
    if object.isAnyone() {
        return DBXTeamPoliciesSharedFolderBlanketLinkRestrictionPolicyAnyone()
    }
    if object.isOther() {
        return DBXTeamPoliciesSharedFolderBlanketLinkRestrictionPolicyOther()
    }
    fatalError("codegen error")
}

func mapDBTEAMPOLICIESSharedFolderJoinPolicyToDBXOptional(object: DBTEAMPOLICIESSharedFolderJoinPolicy?) -> DBXTeamPoliciesSharedFolderJoinPolicy? {
    guard let object = object else { return nil }
    return mapDBTEAMPOLICIESSharedFolderJoinPolicyToDBX(object: object)
}

func mapDBTEAMPOLICIESSharedFolderJoinPolicyToDBX(object: DBTEAMPOLICIESSharedFolderJoinPolicy) -> DBXTeamPoliciesSharedFolderJoinPolicy {
    if object.isFromTeamOnly() {
        return DBXTeamPoliciesSharedFolderJoinPolicyFromTeamOnly()
    }
    if object.isFromAnyone() {
        return DBXTeamPoliciesSharedFolderJoinPolicyFromAnyone()
    }
    if object.isOther() {
        return DBXTeamPoliciesSharedFolderJoinPolicyOther()
    }
    fatalError("codegen error")
}

func mapDBTEAMPOLICIESSharedFolderMemberPolicyToDBXOptional(object: DBTEAMPOLICIESSharedFolderMemberPolicy?) -> DBXTeamPoliciesSharedFolderMemberPolicy? {
    guard let object = object else { return nil }
    return mapDBTEAMPOLICIESSharedFolderMemberPolicyToDBX(object: object)
}

func mapDBTEAMPOLICIESSharedFolderMemberPolicyToDBX(object: DBTEAMPOLICIESSharedFolderMemberPolicy) -> DBXTeamPoliciesSharedFolderMemberPolicy {
    if object.isTeam() {
        return DBXTeamPoliciesSharedFolderMemberPolicyTeam()
    }
    if object.isAnyone() {
        return DBXTeamPoliciesSharedFolderMemberPolicyAnyone()
    }
    if object.isOther() {
        return DBXTeamPoliciesSharedFolderMemberPolicyOther()
    }
    fatalError("codegen error")
}

func mapDBTEAMPOLICIESSharedLinkCreatePolicyToDBXOptional(object: DBTEAMPOLICIESSharedLinkCreatePolicy?) -> DBXTeamPoliciesSharedLinkCreatePolicy? {
    guard let object = object else { return nil }
    return mapDBTEAMPOLICIESSharedLinkCreatePolicyToDBX(object: object)
}

func mapDBTEAMPOLICIESSharedLinkCreatePolicyToDBX(object: DBTEAMPOLICIESSharedLinkCreatePolicy) -> DBXTeamPoliciesSharedLinkCreatePolicy {
    if object.isDefaultPublic() {
        return DBXTeamPoliciesSharedLinkCreatePolicyDefaultPublic()
    }
    if object.isDefaultTeamOnly() {
        return DBXTeamPoliciesSharedLinkCreatePolicyDefaultTeamOnly()
    }
    if object.isTeamOnly() {
        return DBXTeamPoliciesSharedLinkCreatePolicyTeamOnly()
    }
    if object.isDefaultNoOne() {
        return DBXTeamPoliciesSharedLinkCreatePolicyDefaultNoOne()
    }
    if object.isOther() {
        return DBXTeamPoliciesSharedLinkCreatePolicyOther()
    }
    fatalError("codegen error")
}

func mapDBTEAMPOLICIESShowcaseDownloadPolicyToDBXOptional(object: DBTEAMPOLICIESShowcaseDownloadPolicy?) -> DBXTeamPoliciesShowcaseDownloadPolicy? {
    guard let object = object else { return nil }
    return mapDBTEAMPOLICIESShowcaseDownloadPolicyToDBX(object: object)
}

func mapDBTEAMPOLICIESShowcaseDownloadPolicyToDBX(object: DBTEAMPOLICIESShowcaseDownloadPolicy) -> DBXTeamPoliciesShowcaseDownloadPolicy {
    if object.isDisabled() {
        return DBXTeamPoliciesShowcaseDownloadPolicyDisabled()
    }
    if object.isEnabled() {
        return DBXTeamPoliciesShowcaseDownloadPolicyEnabled()
    }
    if object.isOther() {
        return DBXTeamPoliciesShowcaseDownloadPolicyOther()
    }
    fatalError("codegen error")
}

func mapDBTEAMPOLICIESShowcaseEnabledPolicyToDBXOptional(object: DBTEAMPOLICIESShowcaseEnabledPolicy?) -> DBXTeamPoliciesShowcaseEnabledPolicy? {
    guard let object = object else { return nil }
    return mapDBTEAMPOLICIESShowcaseEnabledPolicyToDBX(object: object)
}

func mapDBTEAMPOLICIESShowcaseEnabledPolicyToDBX(object: DBTEAMPOLICIESShowcaseEnabledPolicy) -> DBXTeamPoliciesShowcaseEnabledPolicy {
    if object.isDisabled() {
        return DBXTeamPoliciesShowcaseEnabledPolicyDisabled()
    }
    if object.isEnabled() {
        return DBXTeamPoliciesShowcaseEnabledPolicyEnabled()
    }
    if object.isOther() {
        return DBXTeamPoliciesShowcaseEnabledPolicyOther()
    }
    fatalError("codegen error")
}

func mapDBTEAMPOLICIESShowcaseExternalSharingPolicyToDBXOptional(object: DBTEAMPOLICIESShowcaseExternalSharingPolicy?)
    -> DBXTeamPoliciesShowcaseExternalSharingPolicy? {
    guard let object = object else { return nil }
    return mapDBTEAMPOLICIESShowcaseExternalSharingPolicyToDBX(object: object)
}

func mapDBTEAMPOLICIESShowcaseExternalSharingPolicyToDBX(object: DBTEAMPOLICIESShowcaseExternalSharingPolicy) -> DBXTeamPoliciesShowcaseExternalSharingPolicy {
    if object.isDisabled() {
        return DBXTeamPoliciesShowcaseExternalSharingPolicyDisabled()
    }
    if object.isEnabled() {
        return DBXTeamPoliciesShowcaseExternalSharingPolicyEnabled()
    }
    if object.isOther() {
        return DBXTeamPoliciesShowcaseExternalSharingPolicyOther()
    }
    fatalError("codegen error")
}

func mapDBTEAMPOLICIESSmartSyncPolicyToDBXOptional(object: DBTEAMPOLICIESSmartSyncPolicy?) -> DBXTeamPoliciesSmartSyncPolicy? {
    guard let object = object else { return nil }
    return mapDBTEAMPOLICIESSmartSyncPolicyToDBX(object: object)
}

func mapDBTEAMPOLICIESSmartSyncPolicyToDBX(object: DBTEAMPOLICIESSmartSyncPolicy) -> DBXTeamPoliciesSmartSyncPolicy {
    if object.isLocal() {
        return DBXTeamPoliciesSmartSyncPolicyLocal()
    }
    if object.isOnDemand() {
        return DBXTeamPoliciesSmartSyncPolicyOnDemand()
    }
    if object.isOther() {
        return DBXTeamPoliciesSmartSyncPolicyOther()
    }
    fatalError("codegen error")
}

func mapDBTEAMPOLICIESSmarterSmartSyncPolicyStateToDBXOptional(object: DBTEAMPOLICIESSmarterSmartSyncPolicyState?)
    -> DBXTeamPoliciesSmarterSmartSyncPolicyState? {
    guard let object = object else { return nil }
    return mapDBTEAMPOLICIESSmarterSmartSyncPolicyStateToDBX(object: object)
}

func mapDBTEAMPOLICIESSmarterSmartSyncPolicyStateToDBX(object: DBTEAMPOLICIESSmarterSmartSyncPolicyState) -> DBXTeamPoliciesSmarterSmartSyncPolicyState {
    if object.isDisabled() {
        return DBXTeamPoliciesSmarterSmartSyncPolicyStateDisabled()
    }
    if object.isEnabled() {
        return DBXTeamPoliciesSmarterSmartSyncPolicyStateEnabled()
    }
    if object.isOther() {
        return DBXTeamPoliciesSmarterSmartSyncPolicyStateOther()
    }
    fatalError("codegen error")
}

func mapDBTEAMPOLICIESSsoPolicyToDBXOptional(object: DBTEAMPOLICIESSsoPolicy?) -> DBXTeamPoliciesSsoPolicy? {
    guard let object = object else { return nil }
    return mapDBTEAMPOLICIESSsoPolicyToDBX(object: object)
}

func mapDBTEAMPOLICIESSsoPolicyToDBX(object: DBTEAMPOLICIESSsoPolicy) -> DBXTeamPoliciesSsoPolicy {
    if object.isDisabled() {
        return DBXTeamPoliciesSsoPolicyDisabled()
    }
    if object.isOptional() {
        return DBXTeamPoliciesSsoPolicyOptional()
    }
    if object.isRequired() {
        return DBXTeamPoliciesSsoPolicyRequired()
    }
    if object.isOther() {
        return DBXTeamPoliciesSsoPolicyOther()
    }
    fatalError("codegen error")
}

func mapDBTEAMPOLICIESSuggestMembersPolicyToDBXOptional(object: DBTEAMPOLICIESSuggestMembersPolicy?) -> DBXTeamPoliciesSuggestMembersPolicy? {
    guard let object = object else { return nil }
    return mapDBTEAMPOLICIESSuggestMembersPolicyToDBX(object: object)
}

func mapDBTEAMPOLICIESSuggestMembersPolicyToDBX(object: DBTEAMPOLICIESSuggestMembersPolicy) -> DBXTeamPoliciesSuggestMembersPolicy {
    if object.isDisabled() {
        return DBXTeamPoliciesSuggestMembersPolicyDisabled()
    }
    if object.isEnabled() {
        return DBXTeamPoliciesSuggestMembersPolicyEnabled()
    }
    if object.isOther() {
        return DBXTeamPoliciesSuggestMembersPolicyOther()
    }
    fatalError("codegen error")
}

func mapDBTEAMPOLICIESTeamMemberPoliciesToDBXOptional(object: DBTEAMPOLICIESTeamMemberPolicies?) -> DBXTeamPoliciesTeamMemberPolicies? {
    guard let object = object else { return nil }
    return mapDBTEAMPOLICIESTeamMemberPoliciesToDBX(object: object)
}

func mapDBTEAMPOLICIESTeamMemberPoliciesToDBX(object: DBTEAMPOLICIESTeamMemberPolicies) -> DBXTeamPoliciesTeamMemberPolicies {
    DBXTeamPoliciesTeamMemberPolicies(
        sharing: mapDBTEAMPOLICIESTeamSharingPoliciesToDBX(object: object.sharing),
        emmState: mapDBTEAMPOLICIESEmmStateToDBX(object: object.emmState),
        officeAddin: mapDBTEAMPOLICIESOfficeAddInPolicyToDBX(object: object.officeAddin),
        suggestMembersPolicy: mapDBTEAMPOLICIESSuggestMembersPolicyToDBX(object: object.suggestMembersPolicy)
    )
}

func mapDBTEAMPOLICIESTeamSharingPoliciesToDBXOptional(object: DBTEAMPOLICIESTeamSharingPolicies?) -> DBXTeamPoliciesTeamSharingPolicies? {
    guard let object = object else { return nil }
    return mapDBTEAMPOLICIESTeamSharingPoliciesToDBX(object: object)
}

func mapDBTEAMPOLICIESTeamSharingPoliciesToDBX(object: DBTEAMPOLICIESTeamSharingPolicies) -> DBXTeamPoliciesTeamSharingPolicies {
    DBXTeamPoliciesTeamSharingPolicies(
        sharedFolderMemberPolicy: mapDBTEAMPOLICIESSharedFolderMemberPolicyToDBX(object: object.sharedFolderMemberPolicy),
        sharedFolderJoinPolicy: mapDBTEAMPOLICIESSharedFolderJoinPolicyToDBX(object: object.sharedFolderJoinPolicy),
        sharedLinkCreatePolicy: mapDBTEAMPOLICIESSharedLinkCreatePolicyToDBX(object: object.sharedLinkCreatePolicy),
        groupCreationPolicy: mapDBTEAMPOLICIESGroupCreationToDBX(object: object.groupCreationPolicy),
        sharedFolderLinkRestrictionPolicy: mapDBTEAMPOLICIESSharedFolderBlanketLinkRestrictionPolicyToDBX(object: object.sharedFolderLinkRestrictionPolicy)
    )
}

func mapDBTEAMPOLICIESTwoStepVerificationPolicyToDBXOptional(object: DBTEAMPOLICIESTwoStepVerificationPolicy?) -> DBXTeamPoliciesTwoStepVerificationPolicy? {
    guard let object = object else { return nil }
    return mapDBTEAMPOLICIESTwoStepVerificationPolicyToDBX(object: object)
}

func mapDBTEAMPOLICIESTwoStepVerificationPolicyToDBX(object: DBTEAMPOLICIESTwoStepVerificationPolicy) -> DBXTeamPoliciesTwoStepVerificationPolicy {
    if object.isRequireTfaEnable() {
        return DBXTeamPoliciesTwoStepVerificationPolicyRequireTfaEnable()
    }
    if object.isRequireTfaDisable() {
        return DBXTeamPoliciesTwoStepVerificationPolicyRequireTfaDisable()
    }
    if object.isOther() {
        return DBXTeamPoliciesTwoStepVerificationPolicyOther()
    }
    fatalError("codegen error")
}

func mapDBTEAMPOLICIESTwoStepVerificationStateToDBXOptional(object: DBTEAMPOLICIESTwoStepVerificationState?) -> DBXTeamPoliciesTwoStepVerificationState? {
    guard let object = object else { return nil }
    return mapDBTEAMPOLICIESTwoStepVerificationStateToDBX(object: object)
}

func mapDBTEAMPOLICIESTwoStepVerificationStateToDBX(object: DBTEAMPOLICIESTwoStepVerificationState) -> DBXTeamPoliciesTwoStepVerificationState {
    if object.isRequired() {
        return DBXTeamPoliciesTwoStepVerificationStateRequired()
    }
    if object.isOptional() {
        return DBXTeamPoliciesTwoStepVerificationStateOptional()
    }
    if object.isDisabled() {
        return DBXTeamPoliciesTwoStepVerificationStateDisabled()
    }
    if object.isOther() {
        return DBXTeamPoliciesTwoStepVerificationStateOther()
    }
    fatalError("codegen error")
}
