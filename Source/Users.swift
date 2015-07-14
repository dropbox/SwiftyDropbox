
/* Autogenerated. Do not edit. */

import Foundation
public class Users {
    /// Arguments for `get_account`.
    ///
    /// :param: accountId
    ///        A user's account identifier.
    public class GetAccountArg: Printable {
        public let accountId : String
        public init(accountId: String) {
            stringValidator(minLength: 40, maxLength: 40)(value: accountId)
            self.accountId = accountId
        }
        public var description : String {
            return "\(prepareJSONForSerialization(GetAccountArgSerializer().serialize(self)))"
        }
    }
    public class GetAccountArgSerializer: JSONSerializer {
        public init() { }
        public func serialize(value: GetAccountArg) -> JSON {
            var output = [ 
            "account_id": Serialization._StringSerializer.serialize(value.accountId),
            ]
            return .Dictionary(output)
        }
        public func deserialize(json: JSON) -> GetAccountArg {
            switch json {
                case .Dictionary(let dict):
                    let accountId = Serialization._StringSerializer.deserialize(dict["account_id"] ?? .Null)
                    return GetAccountArg(accountId: accountId)
                default:
                    assert(false, "Type error deserializing")
                    return GetAccountArg(accountId: "")
            }
        }
    }
    /// Error returned by `get_account`.
    ///
    /// - NoAccount:
    ///   The specified `GetAccountArg.account_id` does not exist.
    /// - Unknown
    public enum GetAccountError : Printable {
        case NoAccount
        case Unknown
        public var description : String {
            return "\(prepareJSONForSerialization(GetAccountErrorSerializer().serialize(self)))"
        }
    }
    public class GetAccountErrorSerializer: JSONSerializer {
        public init() { }
        public func serialize(value: GetAccountError) -> JSON {
            switch value {
                case .NoAccount:
                    return .Dictionary([".tag": .Str("no_account")])
                case .Unknown:
                    return .Dictionary([".tag": .Str("unknown")])
            }
        }
        public func deserialize(json: JSON) -> GetAccountError {
            switch json {
                case .Dictionary(let d):
                    let tag = Serialization.getTag(d)
                    switch tag {
                        case "no_account":
                            return GetAccountError.NoAccount
                        case "unknown":
                            return GetAccountError.Unknown
                        default:
                            return GetAccountError.Unknown
                    }
                default:
                    assert(false, "Failed to deserialize")
                    return GetAccountError.Unknown
            }
        }
    }
    /// What type of account this user has.
    ///
    /// - Basic:
    ///   The basic account type.
    /// - Pro:
    ///   The Dropbox Pro account type.
    /// - Business:
    ///   The Dropbox for Business account type.
    public enum AccountType : Printable {
        case Basic
        case Pro
        case Business
        public var description : String {
            return "\(prepareJSONForSerialization(AccountTypeSerializer().serialize(self)))"
        }
    }
    public class AccountTypeSerializer: JSONSerializer {
        public init() { }
        public func serialize(value: AccountType) -> JSON {
            switch value {
                case .Basic:
                    return .Dictionary([".tag": .Str("basic")])
                case .Pro:
                    return .Dictionary([".tag": .Str("pro")])
                case .Business:
                    return .Dictionary([".tag": .Str("business")])
            }
        }
        public func deserialize(json: JSON) -> AccountType {
            switch json {
                case .Dictionary(let d):
                    let tag = Serialization.getTag(d)
                    switch tag {
                        case "basic":
                            return AccountType.Basic
                        case "pro":
                            return AccountType.Pro
                        case "business":
                            return AccountType.Business
                        default:
                            fatalError("Unknown tag \(tag)")
                    }
                default:
                    assert(false, "Failed to deserialize")
                    return AccountType.Basic
            }
        }
    }
    /// The amount of detail revealed about an account depends on the user being
    /// queried and the user making the query.
    ///
    /// :param: accountId
    ///        The user's unique Dropbox ID.
    /// :param: name
    ///        Details of a user's name.
    public class Account: Printable {
        public let accountId : String
        public let name : Name
        public init(accountId: String, name: Name) {
            stringValidator(minLength: 40, maxLength: 40)(value: accountId)
            self.accountId = accountId
            self.name = name
        }
        public var description : String {
            return "\(prepareJSONForSerialization(AccountSerializer().serialize(self)))"
        }
    }
    public class AccountSerializer: JSONSerializer {
        public init() { }
        public func serialize(value: Account) -> JSON {
            var output = [ 
            "account_id": Serialization._StringSerializer.serialize(value.accountId),
            "name": NameSerializer().serialize(value.name),
            ]
            return .Dictionary(output)
        }
        public func deserialize(json: JSON) -> Account {
            switch json {
                case .Dictionary(let dict):
                    let accountId = Serialization._StringSerializer.deserialize(dict["account_id"] ?? .Null)
                    let name = NameSerializer().deserialize(dict["name"] ?? .Null)
                    return Account(accountId: accountId, name: name)
                default:
                    assert(false, "Type error deserializing")
                    return Account(accountId: "", name: Name(givenName: "", surname: "", familiarName: "", displayName: ""))
            }
        }
    }
    /// Basic information about any account.
    ///
    /// :param: isTeammate
    ///        Whether this user is a teammate of the current user. If this
    ///        account is the current user's account, then this will be `true`.
    public class BasicAccount: Account, Printable {
        public let isTeammate : Bool
        public init(accountId: String, name: Name, isTeammate: Bool) {
            self.isTeammate = isTeammate
            super.init(accountId: accountId, name: name)
        }
        public override var description : String {
            return "\(prepareJSONForSerialization(BasicAccountSerializer().serialize(self)))"
        }
    }
    public class BasicAccountSerializer: JSONSerializer {
        public init() { }
        public func serialize(value: BasicAccount) -> JSON {
            var output = [ 
            "account_id": Serialization._StringSerializer.serialize(value.accountId),
            "name": NameSerializer().serialize(value.name),
            "is_teammate": Serialization._BoolSerializer.serialize(value.isTeammate),
            ]
            return .Dictionary(output)
        }
        public func deserialize(json: JSON) -> BasicAccount {
            switch json {
                case .Dictionary(let dict):
                    let accountId = Serialization._StringSerializer.deserialize(dict["account_id"] ?? .Null)
                    let name = NameSerializer().deserialize(dict["name"] ?? .Null)
                    let isTeammate = Serialization._BoolSerializer.deserialize(dict["is_teammate"] ?? .Null)
                    return BasicAccount(accountId: accountId, name: name, isTeammate: isTeammate)
                default:
                    assert(false, "Type error deserializing")
                    return BasicAccount(accountId: "", name: Users.Name(givenName: "", surname: "", familiarName: "", displayName: ""), isTeammate: false)
            }
        }
    }
    /// Detailed information about the current user's account.
    ///
    /// :param: email
    ///        The user's e-mail address.
    /// :param: country
    ///        The user's two-letter country code, if available. Country codes
    ///        are based on `ISO 3166-1
    ///        http://en.wikipedia.org/wiki/ISO_3166-1`.
    /// :param: locale
    ///        The language that the user specified. Locale tags will be `IETF
    ///        language tags http://en.wikipedia.org/wiki/IETF_language_tag`.
    /// :param: referralLink
    ///        The user's `referral link https://www.dropbox.com/referrals`.
    /// :param: team
    ///        If this account is a member of a team, information about that
    ///        team.
    /// :param: isPaired
    ///        Whether the user has a personal and work account. If the current
    ///        account is personal, then `team` will always be `null`, but
    ///        `is_paired` will indicate if a work account is linked.
    /// :param: accountType
    ///        What type of account this user has.
    public class FullAccount: Account, Printable {
        public let email : String
        public let country : String?
        public let locale : String
        public let referralLink : String
        public let team : Team?
        public let isPaired : Bool
        public let accountType : AccountType
        public init(accountId: String, name: Name, email: String, locale: String, referralLink: String, isPaired: Bool, accountType: AccountType, country: String? = nil, team: Team? = nil) {
            stringValidator()(value: email)
            self.email = email
            nullableValidator(stringValidator(minLength: 2, maxLength: 2))(value: country)
            self.country = country
            stringValidator(minLength: 2, maxLength: 2)(value: locale)
            self.locale = locale
            stringValidator()(value: referralLink)
            self.referralLink = referralLink
            self.team = team
            self.isPaired = isPaired
            self.accountType = accountType
            super.init(accountId: accountId, name: name)
        }
        public override var description : String {
            return "\(prepareJSONForSerialization(FullAccountSerializer().serialize(self)))"
        }
    }
    public class FullAccountSerializer: JSONSerializer {
        public init() { }
        public func serialize(value: FullAccount) -> JSON {
            var output = [ 
            "account_id": Serialization._StringSerializer.serialize(value.accountId),
            "name": NameSerializer().serialize(value.name),
            "email": Serialization._StringSerializer.serialize(value.email),
            "locale": Serialization._StringSerializer.serialize(value.locale),
            "referral_link": Serialization._StringSerializer.serialize(value.referralLink),
            "is_paired": Serialization._BoolSerializer.serialize(value.isPaired),
            "account_type": AccountTypeSerializer().serialize(value.accountType),
            "country": NullableSerializer(Serialization._StringSerializer).serialize(value.country),
            "team": NullableSerializer(TeamSerializer()).serialize(value.team),
            ]
            return .Dictionary(output)
        }
        public func deserialize(json: JSON) -> FullAccount {
            switch json {
                case .Dictionary(let dict):
                    let accountId = Serialization._StringSerializer.deserialize(dict["account_id"] ?? .Null)
                    let name = NameSerializer().deserialize(dict["name"] ?? .Null)
                    let email = Serialization._StringSerializer.deserialize(dict["email"] ?? .Null)
                    let locale = Serialization._StringSerializer.deserialize(dict["locale"] ?? .Null)
                    let referralLink = Serialization._StringSerializer.deserialize(dict["referral_link"] ?? .Null)
                    let isPaired = Serialization._BoolSerializer.deserialize(dict["is_paired"] ?? .Null)
                    let accountType = AccountTypeSerializer().deserialize(dict["account_type"] ?? .Null)
                    let country = NullableSerializer(Serialization._StringSerializer).deserialize(dict["country"] ?? .Null)
                    let team = NullableSerializer(TeamSerializer()).deserialize(dict["team"] ?? .Null)
                    return FullAccount(accountId: accountId, name: name, email: email, locale: locale, referralLink: referralLink, isPaired: isPaired, accountType: accountType, country: country, team: team)
                default:
                    assert(false, "Type error deserializing")
                    return FullAccount(accountId: "", name: Users.Name(givenName: "", surname: "", familiarName: "", displayName: ""), email: "", locale: "", referralLink: "", isPaired: false, accountType: Users.AccountType.Basic, country: nil, team: nil)
            }
        }
    }
    /// Information about a team.
    ///
    /// :param: id
    ///        The team's unique ID.
    /// :param: name
    ///        The name of the team.
    public class Team: Printable {
        public let id : String
        public let name : String
        public init(id: String, name: String) {
            stringValidator()(value: id)
            self.id = id
            stringValidator()(value: name)
            self.name = name
        }
        public var description : String {
            return "\(prepareJSONForSerialization(TeamSerializer().serialize(self)))"
        }
    }
    public class TeamSerializer: JSONSerializer {
        public init() { }
        public func serialize(value: Team) -> JSON {
            var output = [ 
            "id": Serialization._StringSerializer.serialize(value.id),
            "name": Serialization._StringSerializer.serialize(value.name),
            ]
            return .Dictionary(output)
        }
        public func deserialize(json: JSON) -> Team {
            switch json {
                case .Dictionary(let dict):
                    let id = Serialization._StringSerializer.deserialize(dict["id"] ?? .Null)
                    let name = Serialization._StringSerializer.deserialize(dict["name"] ?? .Null)
                    return Team(id: id, name: name)
                default:
                    assert(false, "Type error deserializing")
                    return Team(id: "", name: "")
            }
        }
    }
    /// Representations for a person's name to assist with internationalization.
    ///
    /// :param: givenName
    ///        Also known as a first name.
    /// :param: surname
    ///        Also known as a last name or family name.
    /// :param: familiarName
    ///        Locale-dependent name. In the US, a person's familiar name is
    ///        their `given_name`, but elsewhere, it could be any combination of
    ///        a person's `given_name` and `surname`.
    /// :param: displayName
    ///        A name that can be used directly to represent the name of a
    ///        user's Dropbox account.
    public class Name: Printable {
        public let givenName : String
        public let surname : String
        public let familiarName : String
        public let displayName : String
        public init(givenName: String, surname: String, familiarName: String, displayName: String) {
            stringValidator()(value: givenName)
            self.givenName = givenName
            stringValidator()(value: surname)
            self.surname = surname
            stringValidator()(value: familiarName)
            self.familiarName = familiarName
            stringValidator()(value: displayName)
            self.displayName = displayName
        }
        public var description : String {
            return "\(prepareJSONForSerialization(NameSerializer().serialize(self)))"
        }
    }
    public class NameSerializer: JSONSerializer {
        public init() { }
        public func serialize(value: Name) -> JSON {
            var output = [ 
            "given_name": Serialization._StringSerializer.serialize(value.givenName),
            "surname": Serialization._StringSerializer.serialize(value.surname),
            "familiar_name": Serialization._StringSerializer.serialize(value.familiarName),
            "display_name": Serialization._StringSerializer.serialize(value.displayName),
            ]
            return .Dictionary(output)
        }
        public func deserialize(json: JSON) -> Name {
            switch json {
                case .Dictionary(let dict):
                    let givenName = Serialization._StringSerializer.deserialize(dict["given_name"] ?? .Null)
                    let surname = Serialization._StringSerializer.deserialize(dict["surname"] ?? .Null)
                    let familiarName = Serialization._StringSerializer.deserialize(dict["familiar_name"] ?? .Null)
                    let displayName = Serialization._StringSerializer.deserialize(dict["display_name"] ?? .Null)
                    return Name(givenName: givenName, surname: surname, familiarName: familiarName, displayName: displayName)
                default:
                    assert(false, "Type error deserializing")
                    return Name(givenName: "", surname: "", familiarName: "", displayName: "")
            }
        }
    }
    /// Information about a user's space usage and quota.
    ///
    /// :param: allocated
    ///        The user's total space allocation (bytes).
    /// :param: used
    ///        The user's total space usage (bytes).
    public class SpaceUsage: Printable {
        public let allocated : UInt64
        public let used : UInt64
        public init(allocated: UInt64, used: UInt64) {
            comparableValidator()(value: allocated)
            self.allocated = allocated
            comparableValidator()(value: used)
            self.used = used
        }
        public var description : String {
            return "\(prepareJSONForSerialization(SpaceUsageSerializer().serialize(self)))"
        }
    }
    public class SpaceUsageSerializer: JSONSerializer {
        public init() { }
        public func serialize(value: SpaceUsage) -> JSON {
            var output = [ 
            "allocated": Serialization._UInt64Serializer.serialize(value.allocated),
            "used": Serialization._UInt64Serializer.serialize(value.used),
            ]
            return .Dictionary(output)
        }
        public func deserialize(json: JSON) -> SpaceUsage {
            switch json {
                case .Dictionary(let dict):
                    let allocated = Serialization._UInt64Serializer.deserialize(dict["allocated"] ?? .Null)
                    let used = Serialization._UInt64Serializer.deserialize(dict["used"] ?? .Null)
                    return SpaceUsage(allocated: allocated, used: used)
                default:
                    assert(false, "Type error deserializing")
                    return SpaceUsage(allocated: 0, used: 0)
            }
        }
    }
}
extension BabelClient {
    /// Get information about a user's account.
    ///
    /// :param: accountId
    ///        A user's account identifier.
    public func usersGetAccount(#accountId: String) -> BabelRpcRequest<Users.BasicAccountSerializer, Users.GetAccountErrorSerializer> {
        let request = Users.GetAccountArg(accountId: accountId)
        return BabelRpcRequest(client: self, host: "meta", route: "/users/get_account", params: Users.GetAccountArgSerializer().serialize(request), responseSerializer: Users.BasicAccountSerializer(), errorSerializer: Users.GetAccountErrorSerializer())
    }
    /// Get information about the current user's account.
    ///
    public func usersGetCurrentAccount() -> BabelRpcRequest<Users.FullAccountSerializer, VoidSerializer> {
        return BabelRpcRequest(client: self, host: "meta", route: "/users/get_current_account", params: Serialization._VoidSerializer.serialize(), responseSerializer: Users.FullAccountSerializer(), errorSerializer: Serialization._VoidSerializer)
    }
    /// Get the space usage information for the current user's account.
    ///
    public func usersGetSpaceUsage() -> BabelRpcRequest<Users.SpaceUsageSerializer, VoidSerializer> {
        return BabelRpcRequest(client: self, host: "meta", route: "/users/get_space_usage", params: Serialization._VoidSerializer.serialize(), responseSerializer: Users.SpaceUsageSerializer(), errorSerializer: Serialization._VoidSerializer)
    }
}
