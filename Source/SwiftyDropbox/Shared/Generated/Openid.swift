///
/// Copyright (c) 2016 Dropbox, Inc. All rights reserved.
///
/// Auto-generated by Stone, do not modify.
///

import Foundation

/// Datatypes and serializers for the openid namespace
public class Openid {
    /// The OpenIdError union
    public enum OpenIdError: CustomStringConvertible, JSONRepresentable {
        /// Missing openid claims for the associated access token.
        case incorrectOpenidScopes
        /// An unspecified error.
        case other

        func json() throws -> JSON {
            try OpenIdErrorSerializer().serialize(self)
        }

        public var description: String {
            do {
                return "\(SerializeUtil.prepareJSONForSerialization(try OpenIdErrorSerializer().serialize(self)))"
            } catch {
                return "Failed to generate description for OpenIdError: \(error)"
            }
        }
    }

    public class OpenIdErrorSerializer: JSONSerializer {
        public init() {}
        public func serialize(_ value: OpenIdError) throws -> JSON {
            switch value {
            case .incorrectOpenidScopes:
                var d = [String: JSON]()
                d[".tag"] = .str("incorrect_openid_scopes")
                return .dictionary(d)
            case .other:
                var d = [String: JSON]()
                d[".tag"] = .str("other")
                return .dictionary(d)
            }
        }

        public func deserialize(_ json: JSON) throws -> OpenIdError {
            switch json {
            case .dictionary(let d):
                let tag = try Serialization.getTag(d)
                switch tag {
                case "incorrect_openid_scopes":
                    return OpenIdError.incorrectOpenidScopes
                case "other":
                    return OpenIdError.other
                default:
                    return OpenIdError.other
                }
            default:
                throw JSONSerializerError.deserializeError(type: OpenIdError.self, json: json)
            }
        }
    }

    /// No Parameters
    public class UserInfoArgs: CustomStringConvertible, JSONRepresentable {
        public init() {}

        func json() throws -> JSON {
            try UserInfoArgsSerializer().serialize(self)
        }

        public var description: String {
            do {
                return "\(SerializeUtil.prepareJSONForSerialization(try UserInfoArgsSerializer().serialize(self)))"
            } catch {
                return "Failed to generate description for UserInfoArgs: \(error)"
            }
        }
    }

    public class UserInfoArgsSerializer: JSONSerializer {
        public init() {}
        public func serialize(_ value: UserInfoArgs) throws -> JSON {
            let output = [String: JSON]()
            return .dictionary(output)
        }

        public func deserialize(_ json: JSON) throws -> UserInfoArgs {
            switch json {
            case .dictionary:
                return UserInfoArgs()
            default:
                throw JSONSerializerError.deserializeError(type: UserInfoArgs.self, json: json)
            }
        }
    }

    /// The UserInfoError union
    public enum UserInfoError: CustomStringConvertible, JSONRepresentable {
        /// An unspecified error.
        case openidError(Openid.OpenIdError)
        /// An unspecified error.
        case other

        func json() throws -> JSON {
            try UserInfoErrorSerializer().serialize(self)
        }

        public var description: String {
            do {
                return "\(SerializeUtil.prepareJSONForSerialization(try UserInfoErrorSerializer().serialize(self)))"
            } catch {
                return "Failed to generate description for UserInfoError: \(error)"
            }
        }
    }

    public class UserInfoErrorSerializer: JSONSerializer {
        public init() {}
        public func serialize(_ value: UserInfoError) throws -> JSON {
            switch value {
            case .openidError(let arg):
                var d = try ["openid_error": Openid.OpenIdErrorSerializer().serialize(arg)]
                d[".tag"] = .str("openid_error")
                return .dictionary(d)
            case .other:
                var d = [String: JSON]()
                d[".tag"] = .str("other")
                return .dictionary(d)
            }
        }

        public func deserialize(_ json: JSON) throws -> UserInfoError {
            switch json {
            case .dictionary(let d):
                let tag = try Serialization.getTag(d)
                switch tag {
                case "openid_error":
                    let v = try Openid.OpenIdErrorSerializer().deserialize(d["openid_error"] ?? .null)
                    return UserInfoError.openidError(v)
                case "other":
                    return UserInfoError.other
                default:
                    return UserInfoError.other
                }
            default:
                throw JSONSerializerError.deserializeError(type: UserInfoError.self, json: json)
            }
        }
    }

    /// The UserInfoResult struct
    public class UserInfoResult: CustomStringConvertible, JSONRepresentable {
        /// Last name of user.
        public let familyName: String?
        /// First name of user.
        public let givenName: String?
        /// Email address of user.
        public let email: String?
        /// If user is email verified.
        public let emailVerified: Bool?
        /// Issuer of token (in this case Dropbox).
        public let iss: String
        /// An identifier for the user. This is the Dropbox account_id, a string value such as
        /// dbid:AAH4f99T0taONIb-OurWxbNQ6ywGRopQngc.
        public let sub: String
        public init(familyName: String? = nil, givenName: String? = nil, email: String? = nil, emailVerified: Bool? = nil, iss: String = "", sub: String = "") {
            nullableValidator(stringValidator())(familyName)
            self.familyName = familyName
            nullableValidator(stringValidator())(givenName)
            self.givenName = givenName
            nullableValidator(stringValidator())(email)
            self.email = email
            self.emailVerified = emailVerified
            stringValidator()(iss)
            self.iss = iss
            stringValidator()(sub)
            self.sub = sub
        }

        func json() throws -> JSON {
            try UserInfoResultSerializer().serialize(self)
        }

        public var description: String {
            do {
                return "\(SerializeUtil.prepareJSONForSerialization(try UserInfoResultSerializer().serialize(self)))"
            } catch {
                return "Failed to generate description for UserInfoResult: \(error)"
            }
        }
    }

    public class UserInfoResultSerializer: JSONSerializer {
        public init() {}
        public func serialize(_ value: UserInfoResult) throws -> JSON {
            let output = [
                "family_name": try NullableSerializer(Serialization._StringSerializer).serialize(value.familyName),
                "given_name": try NullableSerializer(Serialization._StringSerializer).serialize(value.givenName),
                "email": try NullableSerializer(Serialization._StringSerializer).serialize(value.email),
                "email_verified": try NullableSerializer(Serialization._BoolSerializer).serialize(value.emailVerified),
                "iss": try Serialization._StringSerializer.serialize(value.iss),
                "sub": try Serialization._StringSerializer.serialize(value.sub),
            ]
            return .dictionary(output)
        }

        public func deserialize(_ json: JSON) throws -> UserInfoResult {
            switch json {
            case .dictionary(let dict):
                let familyName = try NullableSerializer(Serialization._StringSerializer).deserialize(dict["family_name"] ?? .null)
                let givenName = try NullableSerializer(Serialization._StringSerializer).deserialize(dict["given_name"] ?? .null)
                let email = try NullableSerializer(Serialization._StringSerializer).deserialize(dict["email"] ?? .null)
                let emailVerified = try NullableSerializer(Serialization._BoolSerializer).deserialize(dict["email_verified"] ?? .null)
                let iss = try Serialization._StringSerializer.deserialize(dict["iss"] ?? .str(""))
                let sub = try Serialization._StringSerializer.deserialize(dict["sub"] ?? .str(""))
                return UserInfoResult(familyName: familyName, givenName: givenName, email: email, emailVerified: emailVerified, iss: iss, sub: sub)
            default:
                throw JSONSerializerError.deserializeError(type: UserInfoResult.self, json: json)
            }
        }
    }

    /// Stone Route Objects

    static let userinfo = Route(
        name: "userinfo",
        version: 1,
        namespace: "openid",
        deprecated: false,
        argSerializer: Openid.UserInfoArgsSerializer(),
        responseSerializer: Openid.UserInfoResultSerializer(),
        errorSerializer: Openid.UserInfoErrorSerializer(),
        attributes: RouteAttributes(
            auth: [.user],
            host: .api,
            style: .rpc
        )
    )
}
