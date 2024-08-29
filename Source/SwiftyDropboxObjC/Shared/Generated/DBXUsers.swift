///
/// Copyright (c) 2022 Dropbox, Inc. All rights reserved.
///
/// Auto-generated by Stone, do not modify.
///

import Foundation
import SwiftyDropbox

/// Objective-C compatible datatypes for the users namespace
/// For Swift see users

/// The amount of detail revealed about an account depends on the user being queried and the user making the query.
@objc
public class DBXUsersAccount: NSObject {
    /// The user's unique Dropbox ID.
    @objc
    public var accountId: String { swift.accountId }
    /// Details of a user's name.
    @objc
    public var name: DBXUsersName { DBXUsersName(swift: swift.name) }
    /// The user's email address. Do not rely on this without checking the emailVerified field. Even then, it's
    /// possible that the user has since lost access to their email.
    @objc
    public var email: String { swift.email }
    /// Whether the user has verified their email address.
    @objc
    public var emailVerified: NSNumber { swift.emailVerified as NSNumber }
    /// URL for the photo representing the user, if one is set.
    @objc
    public var profilePhotoUrl: String? { swift.profilePhotoUrl }
    /// Whether the user has been disabled.
    @objc
    public var disabled: NSNumber { swift.disabled as NSNumber }

    @objc
    public init(accountId: String, name: DBXUsersName, email: String, emailVerified: NSNumber, disabled: NSNumber, profilePhotoUrl: String?) {
        self.swift = Users.Account(
            accountId: accountId,
            name: name.swift,
            email: email,
            emailVerified: emailVerified.boolValue,
            disabled: disabled.boolValue,
            profilePhotoUrl: profilePhotoUrl
        )
    }

    public let swift: Users.Account

    public init(swift: Users.Account) {
        self.swift = swift
    }

    @objc
    public override var description: String { swift.description }
}

/// Basic information about any account.
@objc
public class DBXUsersBasicAccount: DBXUsersAccount {
    /// Whether this user is a teammate of the current user. If this account is the current user's account, then
    /// this will be true.
    @objc
    public var isTeammate: NSNumber { subSwift.isTeammate as NSNumber }
    /// The user's unique team member id. This field will only be present if the user is part of a team and
    /// isTeammate is true.
    @objc
    public var teamMemberId: String? { subSwift.teamMemberId }

    @objc
    public init(
        accountId: String,
        name: DBXUsersName,
        email: String,
        emailVerified: NSNumber,
        disabled: NSNumber,
        isTeammate: NSNumber,
        profilePhotoUrl: String?,
        teamMemberId: String?
    ) {
        let swift = Users.BasicAccount(
            accountId: accountId,
            name: name.swift,
            email: email,
            emailVerified: emailVerified.boolValue,
            disabled: disabled.boolValue,
            isTeammate: isTeammate.boolValue,
            profilePhotoUrl: profilePhotoUrl,
            teamMemberId: teamMemberId
        )
        self.subSwift = swift
        super.init(swift: swift)
    }

    public let subSwift: Users.BasicAccount

    public init(swift: Users.BasicAccount) {
        self.subSwift = swift
        super.init(swift: swift)
    }

    @objc
    public override var description: String { subSwift.description }
}

/// The value for fileLocking in UserFeature.
@objc
public class DBXUsersFileLockingValue: NSObject {
    public let swift: Users.FileLockingValue

    fileprivate init(swift: Users.FileLockingValue) {
        self.swift = swift
    }

    public static func factory(swift: Users.FileLockingValue) -> DBXUsersFileLockingValue {
        switch swift {
        case .enabled(let swiftArg):
            let arg = NSNumber(value: swiftArg)
            return DBXUsersFileLockingValueEnabled(arg)
        case .other:
            return DBXUsersFileLockingValueOther()
        }
    }

    @objc
    public override var description: String { swift.description }

    @objc
    public var asEnabled: DBXUsersFileLockingValueEnabled? {
        self as? DBXUsersFileLockingValueEnabled
    }

    @objc
    public var asOther: DBXUsersFileLockingValueOther? {
        self as? DBXUsersFileLockingValueOther
    }
}

/// When this value is True, the user can lock files in shared directories. When the value is False the user can
/// unlock the files they have locked or request to unlock files locked by others.
@objc
public class DBXUsersFileLockingValueEnabled: DBXUsersFileLockingValue {
    @objc
    public var enabled: NSNumber

    @objc
    public init(_ arg: NSNumber) {
        self.enabled = arg
        let swift = Users.FileLockingValue.enabled(arg.boolValue)
        super.init(swift: swift)
    }
}

/// An unspecified error.
@objc
public class DBXUsersFileLockingValueOther: DBXUsersFileLockingValue {
    @objc
    public init() {
        let swift = Users.FileLockingValue.other
        super.init(swift: swift)
    }
}

/// Detailed information about the current user's account.
@objc
public class DBXUsersFullAccount: DBXUsersAccount {
    /// The user's two-letter country code, if available. Country codes are based on ISO 3166-1
    /// http://en.wikipedia.org/wiki/ISO_3166-1.
    @objc
    public var country: String? { subSwift.country }
    /// The language that the user specified. Locale tags will be IETF language tags
    /// http://en.wikipedia.org/wiki/IETF_language_tag.
    @objc
    public var locale: String { subSwift.locale }
    /// The user's referral link https://www.dropbox.com/referrals.
    @objc
    public var referralLink: String { subSwift.referralLink }
    /// If this account is a member of a team, information about that team.
    @objc
    public var team: DBXUsersFullTeam? { guard let swift = subSwift.team else { return nil }
        return DBXUsersFullTeam(swift: swift)
    }

    /// This account's unique team member id. This field will only be present if team is present.
    @objc
    public var teamMemberId: String? { subSwift.teamMemberId }
    /// Whether the user has a personal and work account. If the current account is personal, then team will always
    /// be null, but isPaired will indicate if a work account is linked.
    @objc
    public var isPaired: NSNumber { subSwift.isPaired as NSNumber }
    /// What type of account this user has.
    @objc
    public var accountType: DBXUsersCommonAccountType { DBXUsersCommonAccountType.factory(swift: subSwift.accountType) }
    /// The root info for this account.
    @objc
    public var rootInfo: DBXCommonRootInfo {
        DBXCommonRootInfo.wrapPreservingSubtypes(swift: subSwift.rootInfo)
    }

    @objc
    public init(
        accountId: String,
        name: DBXUsersName,
        email: String,
        emailVerified: NSNumber,
        disabled: NSNumber,
        locale: String,
        referralLink: String,
        isPaired: NSNumber,
        accountType: DBXUsersCommonAccountType,
        rootInfo: DBXCommonRootInfo,
        profilePhotoUrl: String?,
        country: String?,
        team: DBXUsersFullTeam?,
        teamMemberId: String?
    ) {
        let swift = Users.FullAccount(
            accountId: accountId,
            name: name.swift,
            email: email,
            emailVerified: emailVerified.boolValue,
            disabled: disabled.boolValue,
            locale: locale,
            referralLink: referralLink,
            isPaired: isPaired.boolValue,
            accountType: accountType.swift,
            rootInfo: rootInfo.swift,
            profilePhotoUrl: profilePhotoUrl,
            country: country,
            team: team?.subSwift,
            teamMemberId: teamMemberId
        )
        self.subSwift = swift
        super.init(swift: swift)
    }

    public let subSwift: Users.FullAccount

    public init(swift: Users.FullAccount) {
        self.subSwift = swift
        super.init(swift: swift)
    }

    @objc
    public override var description: String { subSwift.description }
}

/// Information about a team.
@objc
public class DBXUsersTeam: NSObject {
    /// The team's unique ID.
    @objc
    public var id: String { swift.id }
    /// The name of the team.
    @objc
    public var name: String { swift.name }

    @objc
    public init(id: String, name: String) {
        self.swift = Users.Team(id: id, name: name)
    }

    public let swift: Users.Team

    public init(swift: Users.Team) {
        self.swift = swift
    }

    @objc
    public override var description: String { swift.description }
}

/// Detailed information about a team.
@objc
public class DBXUsersFullTeam: DBXUsersTeam {
    /// Team policies governing sharing.
    @objc
    public var sharingPolicies: DBXTeamPoliciesTeamSharingPolicies { DBXTeamPoliciesTeamSharingPolicies(swift: subSwift.sharingPolicies) }
    /// Team policy governing the use of the Office Add-In.
    @objc
    public var officeAddinPolicy: DBXTeamPoliciesOfficeAddInPolicy { DBXTeamPoliciesOfficeAddInPolicy.factory(swift: subSwift.officeAddinPolicy) }

    @objc
    public init(id: String, name: String, sharingPolicies: DBXTeamPoliciesTeamSharingPolicies, officeAddinPolicy: DBXTeamPoliciesOfficeAddInPolicy) {
        let swift = Users.FullTeam(id: id, name: name, sharingPolicies: sharingPolicies.swift, officeAddinPolicy: officeAddinPolicy.swift)
        self.subSwift = swift
        super.init(swift: swift)
    }

    public let subSwift: Users.FullTeam

    public init(swift: Users.FullTeam) {
        self.subSwift = swift
        super.init(swift: swift)
    }

    @objc
    public override var description: String { subSwift.description }
}

/// Objective-C compatible GetAccountArg struct
@objc
public class DBXUsersGetAccountArg: NSObject {
    /// A user's account identifier.
    @objc
    public var accountId: String { swift.accountId }

    @objc
    public init(accountId: String) {
        self.swift = Users.GetAccountArg(accountId: accountId)
    }

    public let swift: Users.GetAccountArg

    public init(swift: Users.GetAccountArg) {
        self.swift = swift
    }

    @objc
    public override var description: String { swift.description }
}

/// Objective-C compatible GetAccountBatchArg struct
@objc
public class DBXUsersGetAccountBatchArg: NSObject {
    /// List of user account identifiers.  Should not contain any duplicate account IDs.
    @objc
    public var accountIds: [String] { swift.accountIds }

    @objc
    public init(accountIds: [String]) {
        self.swift = Users.GetAccountBatchArg(accountIds: accountIds)
    }

    public let swift: Users.GetAccountBatchArg

    public init(swift: Users.GetAccountBatchArg) {
        self.swift = swift
    }

    @objc
    public override var description: String { swift.description }
}

/// Objective-C compatible GetAccountBatchError union
@objc
public class DBXUsersGetAccountBatchError: NSObject {
    public let swift: Users.GetAccountBatchError

    fileprivate init(swift: Users.GetAccountBatchError) {
        self.swift = swift
    }

    public static func factory(swift: Users.GetAccountBatchError) -> DBXUsersGetAccountBatchError {
        switch swift {
        case .noAccount(let swiftArg):
            let arg = swiftArg
            return DBXUsersGetAccountBatchErrorNoAccount(arg)
        case .other:
            return DBXUsersGetAccountBatchErrorOther()
        }
    }

    @objc
    public override var description: String { swift.description }

    @objc
    public var asNoAccount: DBXUsersGetAccountBatchErrorNoAccount? {
        self as? DBXUsersGetAccountBatchErrorNoAccount
    }

    @objc
    public var asOther: DBXUsersGetAccountBatchErrorOther? {
        self as? DBXUsersGetAccountBatchErrorOther
    }
}

/// The value is an account ID specified in accountIds in GetAccountBatchArg that does not exist.
@objc
public class DBXUsersGetAccountBatchErrorNoAccount: DBXUsersGetAccountBatchError {
    @objc
    public var noAccount: String

    @objc
    public init(_ arg: String) {
        self.noAccount = arg
        let swift = Users.GetAccountBatchError.noAccount(arg)
        super.init(swift: swift)
    }
}

/// An unspecified error.
@objc
public class DBXUsersGetAccountBatchErrorOther: DBXUsersGetAccountBatchError {
    @objc
    public init() {
        let swift = Users.GetAccountBatchError.other
        super.init(swift: swift)
    }
}

/// Objective-C compatible GetAccountError union
@objc
public class DBXUsersGetAccountError: NSObject {
    public let swift: Users.GetAccountError

    fileprivate init(swift: Users.GetAccountError) {
        self.swift = swift
    }

    public static func factory(swift: Users.GetAccountError) -> DBXUsersGetAccountError {
        switch swift {
        case .noAccount:
            return DBXUsersGetAccountErrorNoAccount()
        case .other:
            return DBXUsersGetAccountErrorOther()
        }
    }

    @objc
    public override var description: String { swift.description }

    @objc
    public var asNoAccount: DBXUsersGetAccountErrorNoAccount? {
        self as? DBXUsersGetAccountErrorNoAccount
    }

    @objc
    public var asOther: DBXUsersGetAccountErrorOther? {
        self as? DBXUsersGetAccountErrorOther
    }
}

/// The specified accountId in GetAccountArg does not exist.
@objc
public class DBXUsersGetAccountErrorNoAccount: DBXUsersGetAccountError {
    @objc
    public init() {
        let swift = Users.GetAccountError.noAccount
        super.init(swift: swift)
    }
}

/// An unspecified error.
@objc
public class DBXUsersGetAccountErrorOther: DBXUsersGetAccountError {
    @objc
    public init() {
        let swift = Users.GetAccountError.other
        super.init(swift: swift)
    }
}

/// Objective-C compatible IndividualSpaceAllocation struct
@objc
public class DBXUsersIndividualSpaceAllocation: NSObject {
    /// The total space allocated to the user's account (bytes).
    @objc
    public var allocated: NSNumber { swift.allocated as NSNumber }

    @objc
    public init(allocated: NSNumber) {
        self.swift = Users.IndividualSpaceAllocation(allocated: allocated.uint64Value)
    }

    public let swift: Users.IndividualSpaceAllocation

    public init(swift: Users.IndividualSpaceAllocation) {
        self.swift = swift
    }

    @objc
    public override var description: String { swift.description }
}

/// Representations for a person's name to assist with internationalization.
@objc
public class DBXUsersName: NSObject {
    /// Also known as a first name.
    @objc
    public var givenName: String { swift.givenName }
    /// Also known as a last name or family name.
    @objc
    public var surname: String { swift.surname }
    /// Locale-dependent name. In the US, a person's familiar name is their givenName, but elsewhere, it could be
    /// any combination of a person's givenName and surname.
    @objc
    public var familiarName: String { swift.familiarName }
    /// A name that can be used directly to represent the name of a user's Dropbox account.
    @objc
    public var displayName: String { swift.displayName }
    /// An abbreviated form of the person's name. Their initials in most locales.
    @objc
    public var abbreviatedName: String { swift.abbreviatedName }

    @objc
    public init(givenName: String, surname: String, familiarName: String, displayName: String, abbreviatedName: String) {
        self.swift = Users.Name(givenName: givenName, surname: surname, familiarName: familiarName, displayName: displayName, abbreviatedName: abbreviatedName)
    }

    public let swift: Users.Name

    public init(swift: Users.Name) {
        self.swift = swift
    }

    @objc
    public override var description: String { swift.description }
}

/// The value for paperAsFiles in UserFeature.
@objc
public class DBXUsersPaperAsFilesValue: NSObject {
    public let swift: Users.PaperAsFilesValue

    fileprivate init(swift: Users.PaperAsFilesValue) {
        self.swift = swift
    }

    public static func factory(swift: Users.PaperAsFilesValue) -> DBXUsersPaperAsFilesValue {
        switch swift {
        case .enabled(let swiftArg):
            let arg = NSNumber(value: swiftArg)
            return DBXUsersPaperAsFilesValueEnabled(arg)
        case .other:
            return DBXUsersPaperAsFilesValueOther()
        }
    }

    @objc
    public override var description: String { swift.description }

    @objc
    public var asEnabled: DBXUsersPaperAsFilesValueEnabled? {
        self as? DBXUsersPaperAsFilesValueEnabled
    }

    @objc
    public var asOther: DBXUsersPaperAsFilesValueOther? {
        self as? DBXUsersPaperAsFilesValueOther
    }
}

/// When this value is true, the user's Paper docs are accessible in Dropbox with the .paper extension and must
/// be accessed via the /files endpoints.  When this value is false, the user's Paper docs are stored
/// separate from Dropbox files and folders and should be accessed via the /paper endpoints.
@objc
public class DBXUsersPaperAsFilesValueEnabled: DBXUsersPaperAsFilesValue {
    @objc
    public var enabled: NSNumber

    @objc
    public init(_ arg: NSNumber) {
        self.enabled = arg
        let swift = Users.PaperAsFilesValue.enabled(arg.boolValue)
        super.init(swift: swift)
    }
}

/// An unspecified error.
@objc
public class DBXUsersPaperAsFilesValueOther: DBXUsersPaperAsFilesValue {
    @objc
    public init() {
        let swift = Users.PaperAsFilesValue.other
        super.init(swift: swift)
    }
}

/// Space is allocated differently based on the type of account.
@objc
public class DBXUsersSpaceAllocation: NSObject {
    public let swift: Users.SpaceAllocation

    fileprivate init(swift: Users.SpaceAllocation) {
        self.swift = swift
    }

    public static func factory(swift: Users.SpaceAllocation) -> DBXUsersSpaceAllocation {
        switch swift {
        case .individual(let swiftArg):
            let arg = DBXUsersIndividualSpaceAllocation(swift: swiftArg)
            return DBXUsersSpaceAllocationIndividual(arg)
        case .team(let swiftArg):
            let arg = DBXUsersTeamSpaceAllocation(swift: swiftArg)
            return DBXUsersSpaceAllocationTeam(arg)
        case .other:
            return DBXUsersSpaceAllocationOther()
        }
    }

    @objc
    public override var description: String { swift.description }

    @objc
    public var asIndividual: DBXUsersSpaceAllocationIndividual? {
        self as? DBXUsersSpaceAllocationIndividual
    }

    @objc
    public var asTeam: DBXUsersSpaceAllocationTeam? {
        self as? DBXUsersSpaceAllocationTeam
    }

    @objc
    public var asOther: DBXUsersSpaceAllocationOther? {
        self as? DBXUsersSpaceAllocationOther
    }
}

/// The user's space allocation applies only to their individual account.
@objc
public class DBXUsersSpaceAllocationIndividual: DBXUsersSpaceAllocation {
    @objc
    public var individual: DBXUsersIndividualSpaceAllocation

    @objc
    public init(_ arg: DBXUsersIndividualSpaceAllocation) {
        self.individual = arg
        let swift = Users.SpaceAllocation.individual(arg.swift)
        super.init(swift: swift)
    }
}

/// The user shares space with other members of their team.
@objc
public class DBXUsersSpaceAllocationTeam: DBXUsersSpaceAllocation {
    @objc
    public var team: DBXUsersTeamSpaceAllocation

    @objc
    public init(_ arg: DBXUsersTeamSpaceAllocation) {
        self.team = arg
        let swift = Users.SpaceAllocation.team(arg.swift)
        super.init(swift: swift)
    }
}

/// An unspecified error.
@objc
public class DBXUsersSpaceAllocationOther: DBXUsersSpaceAllocation {
    @objc
    public init() {
        let swift = Users.SpaceAllocation.other
        super.init(swift: swift)
    }
}

/// Information about a user's space usage and quota.
@objc
public class DBXUsersSpaceUsage: NSObject {
    /// The user's total space usage (bytes).
    @objc
    public var used: NSNumber { swift.used as NSNumber }
    /// The user's space allocation.
    @objc
    public var allocation: DBXUsersSpaceAllocation { DBXUsersSpaceAllocation.factory(swift: swift.allocation) }

    @objc
    public init(used: NSNumber, allocation: DBXUsersSpaceAllocation) {
        self.swift = Users.SpaceUsage(used: used.uint64Value, allocation: allocation.swift)
    }

    public let swift: Users.SpaceUsage

    public init(swift: Users.SpaceUsage) {
        self.swift = swift
    }

    @objc
    public override var description: String { swift.description }
}

/// Objective-C compatible TeamSpaceAllocation struct
@objc
public class DBXUsersTeamSpaceAllocation: NSObject {
    /// The total space currently used by the user's team (bytes).
    @objc
    public var used: NSNumber { swift.used as NSNumber }
    /// The total space allocated to the user's team (bytes).
    @objc
    public var allocated: NSNumber { swift.allocated as NSNumber }
    /// The total space allocated to the user within its team allocated space (0 means that no restriction is
    /// imposed on the user's quota within its team).
    @objc
    public var userWithinTeamSpaceAllocated: NSNumber { swift.userWithinTeamSpaceAllocated as NSNumber }
    /// The type of the space limit imposed on the team member (off, alert_only, stop_sync).
    @objc
    public var userWithinTeamSpaceLimitType: DBXTeamCommonMemberSpaceLimitType {
        DBXTeamCommonMemberSpaceLimitType.factory(swift: swift.userWithinTeamSpaceLimitType)
    }

    /// An accurate cached calculation of a team member's total space usage (bytes).
    @objc
    public var userWithinTeamSpaceUsedCached: NSNumber { swift.userWithinTeamSpaceUsedCached as NSNumber }

    @objc
    public init(
        used: NSNumber,
        allocated: NSNumber,
        userWithinTeamSpaceAllocated: NSNumber,
        userWithinTeamSpaceLimitType: DBXTeamCommonMemberSpaceLimitType,
        userWithinTeamSpaceUsedCached: NSNumber
    ) {
        self.swift = Users.TeamSpaceAllocation(
            used: used.uint64Value,
            allocated: allocated.uint64Value,
            userWithinTeamSpaceAllocated: userWithinTeamSpaceAllocated.uint64Value,
            userWithinTeamSpaceLimitType: userWithinTeamSpaceLimitType.swift,
            userWithinTeamSpaceUsedCached: userWithinTeamSpaceUsedCached.uint64Value
        )
    }

    public let swift: Users.TeamSpaceAllocation

    public init(swift: Users.TeamSpaceAllocation) {
        self.swift = swift
    }

    @objc
    public override var description: String { swift.description }
}

/// A set of features that a Dropbox User account may have configured.
@objc
public class DBXUsersUserFeature: NSObject {
    public let swift: Users.UserFeature

    fileprivate init(swift: Users.UserFeature) {
        self.swift = swift
    }

    public static func factory(swift: Users.UserFeature) -> DBXUsersUserFeature {
        switch swift {
        case .paperAsFiles:
            return DBXUsersUserFeaturePaperAsFiles()
        case .fileLocking:
            return DBXUsersUserFeatureFileLocking()
        case .other:
            return DBXUsersUserFeatureOther()
        }
    }

    @objc
    public override var description: String { swift.description }

    @objc
    public var asPaperAsFiles: DBXUsersUserFeaturePaperAsFiles? {
        self as? DBXUsersUserFeaturePaperAsFiles
    }

    @objc
    public var asFileLocking: DBXUsersUserFeatureFileLocking? {
        self as? DBXUsersUserFeatureFileLocking
    }

    @objc
    public var asOther: DBXUsersUserFeatureOther? {
        self as? DBXUsersUserFeatureOther
    }
}

/// This feature contains information about how the user's Paper files are stored.
@objc
public class DBXUsersUserFeaturePaperAsFiles: DBXUsersUserFeature {
    @objc
    public init() {
        let swift = Users.UserFeature.paperAsFiles
        super.init(swift: swift)
    }
}

/// This feature allows users to lock files in order to restrict other users from editing them.
@objc
public class DBXUsersUserFeatureFileLocking: DBXUsersUserFeature {
    @objc
    public init() {
        let swift = Users.UserFeature.fileLocking
        super.init(swift: swift)
    }
}

/// An unspecified error.
@objc
public class DBXUsersUserFeatureOther: DBXUsersUserFeature {
    @objc
    public init() {
        let swift = Users.UserFeature.other
        super.init(swift: swift)
    }
}

/// Values that correspond to entries in UserFeature.
@objc
public class DBXUsersUserFeatureValue: NSObject {
    public let swift: Users.UserFeatureValue

    fileprivate init(swift: Users.UserFeatureValue) {
        self.swift = swift
    }

    public static func factory(swift: Users.UserFeatureValue) -> DBXUsersUserFeatureValue {
        switch swift {
        case .paperAsFiles(let swiftArg):
            let arg = DBXUsersPaperAsFilesValue.factory(swift: swiftArg)
            return DBXUsersUserFeatureValuePaperAsFiles(arg)
        case .fileLocking(let swiftArg):
            let arg = DBXUsersFileLockingValue.factory(swift: swiftArg)
            return DBXUsersUserFeatureValueFileLocking(arg)
        case .other:
            return DBXUsersUserFeatureValueOther()
        }
    }

    @objc
    public override var description: String { swift.description }

    @objc
    public var asPaperAsFiles: DBXUsersUserFeatureValuePaperAsFiles? {
        self as? DBXUsersUserFeatureValuePaperAsFiles
    }

    @objc
    public var asFileLocking: DBXUsersUserFeatureValueFileLocking? {
        self as? DBXUsersUserFeatureValueFileLocking
    }

    @objc
    public var asOther: DBXUsersUserFeatureValueOther? {
        self as? DBXUsersUserFeatureValueOther
    }
}

/// An unspecified error.
@objc
public class DBXUsersUserFeatureValuePaperAsFiles: DBXUsersUserFeatureValue {
    @objc
    public var paperAsFiles: DBXUsersPaperAsFilesValue

    @objc
    public init(_ arg: DBXUsersPaperAsFilesValue) {
        self.paperAsFiles = arg
        let swift = Users.UserFeatureValue.paperAsFiles(arg.swift)
        super.init(swift: swift)
    }
}

/// An unspecified error.
@objc
public class DBXUsersUserFeatureValueFileLocking: DBXUsersUserFeatureValue {
    @objc
    public var fileLocking: DBXUsersFileLockingValue

    @objc
    public init(_ arg: DBXUsersFileLockingValue) {
        self.fileLocking = arg
        let swift = Users.UserFeatureValue.fileLocking(arg.swift)
        super.init(swift: swift)
    }
}

/// An unspecified error.
@objc
public class DBXUsersUserFeatureValueOther: DBXUsersUserFeatureValue {
    @objc
    public init() {
        let swift = Users.UserFeatureValue.other
        super.init(swift: swift)
    }
}

/// Objective-C compatible UserFeaturesGetValuesBatchArg struct
@objc
public class DBXUsersUserFeaturesGetValuesBatchArg: NSObject {
    /// A list of features in UserFeature. If the list is empty, this route will return
    /// UserFeaturesGetValuesBatchError.
    @objc
    public var features: [DBXUsersUserFeature] { swift.features.map { DBXUsersUserFeature.factory(swift: $0) } }

    @objc
    public init(features: [DBXUsersUserFeature]) {
        self.swift = Users.UserFeaturesGetValuesBatchArg(features: features.map(\.swift))
    }

    public let swift: Users.UserFeaturesGetValuesBatchArg

    public init(swift: Users.UserFeaturesGetValuesBatchArg) {
        self.swift = swift
    }

    @objc
    public override var description: String { swift.description }
}

/// Objective-C compatible UserFeaturesGetValuesBatchError union
@objc
public class DBXUsersUserFeaturesGetValuesBatchError: NSObject {
    public let swift: Users.UserFeaturesGetValuesBatchError

    fileprivate init(swift: Users.UserFeaturesGetValuesBatchError) {
        self.swift = swift
    }

    public static func factory(swift: Users.UserFeaturesGetValuesBatchError) -> DBXUsersUserFeaturesGetValuesBatchError {
        switch swift {
        case .emptyFeaturesList:
            return DBXUsersUserFeaturesGetValuesBatchErrorEmptyFeaturesList()
        case .other:
            return DBXUsersUserFeaturesGetValuesBatchErrorOther()
        }
    }

    @objc
    public override var description: String { swift.description }

    @objc
    public var asEmptyFeaturesList: DBXUsersUserFeaturesGetValuesBatchErrorEmptyFeaturesList? {
        self as? DBXUsersUserFeaturesGetValuesBatchErrorEmptyFeaturesList
    }

    @objc
    public var asOther: DBXUsersUserFeaturesGetValuesBatchErrorOther? {
        self as? DBXUsersUserFeaturesGetValuesBatchErrorOther
    }
}

/// At least one UserFeature must be included in the UserFeaturesGetValuesBatchArg.features list.
@objc
public class DBXUsersUserFeaturesGetValuesBatchErrorEmptyFeaturesList: DBXUsersUserFeaturesGetValuesBatchError {
    @objc
    public init() {
        let swift = Users.UserFeaturesGetValuesBatchError.emptyFeaturesList
        super.init(swift: swift)
    }
}

/// An unspecified error.
@objc
public class DBXUsersUserFeaturesGetValuesBatchErrorOther: DBXUsersUserFeaturesGetValuesBatchError {
    @objc
    public init() {
        let swift = Users.UserFeaturesGetValuesBatchError.other
        super.init(swift: swift)
    }
}

/// Objective-C compatible UserFeaturesGetValuesBatchResult struct
@objc
public class DBXUsersUserFeaturesGetValuesBatchResult: NSObject {
    /// (no description)
    @objc
    public var values: [DBXUsersUserFeatureValue] { swift.values.map { DBXUsersUserFeatureValue.factory(swift: $0) } }

    @objc
    public init(values: [DBXUsersUserFeatureValue]) {
        self.swift = Users.UserFeaturesGetValuesBatchResult(values: values.map(\.swift))
    }

    public let swift: Users.UserFeaturesGetValuesBatchResult

    public init(swift: Users.UserFeaturesGetValuesBatchResult) {
        self.swift = swift
    }

    @objc
    public override var description: String { swift.description }
}
