///
/// Copyright (c) 2016 Dropbox, Inc. All rights reserved.
///
/// Auto-generated by Stone, do not modify.
///

import Foundation

/// Datatypes and serializers for the team_common namespace
public class TeamCommon {
    /// The group type determines how a group is managed.
    public enum GroupManagementType: CustomStringConvertible, JSONRepresentable {
        /// A group which is managed by selected users.
        case userManaged
        /// A group which is managed by team admins only.
        case companyManaged
        /// A group which is managed automatically by Dropbox.
        case systemManaged
        /// An unspecified error.
        case other

        func json() throws -> JSON {
            try GroupManagementTypeSerializer().serialize(self)
        }

        public var description: String {
            do {
                return "\(SerializeUtil.prepareJSONForSerialization(try GroupManagementTypeSerializer().serialize(self)))"
            } catch {
                return "Failed to generate description for GroupManagementType: \(error)"
            }
        }
    }

    public class GroupManagementTypeSerializer: JSONSerializer {
        public init() {}
        public func serialize(_ value: GroupManagementType) throws -> JSON {
            switch value {
            case .userManaged:
                var d = [String: JSON]()
                d[".tag"] = .str("user_managed")
                return .dictionary(d)
            case .companyManaged:
                var d = [String: JSON]()
                d[".tag"] = .str("company_managed")
                return .dictionary(d)
            case .systemManaged:
                var d = [String: JSON]()
                d[".tag"] = .str("system_managed")
                return .dictionary(d)
            case .other:
                var d = [String: JSON]()
                d[".tag"] = .str("other")
                return .dictionary(d)
            }
        }

        public func deserialize(_ json: JSON) throws -> GroupManagementType {
            switch json {
            case .dictionary(let d):
                let tag = try Serialization.getTag(d)
                switch tag {
                case "user_managed":
                    return GroupManagementType.userManaged
                case "company_managed":
                    return GroupManagementType.companyManaged
                case "system_managed":
                    return GroupManagementType.systemManaged
                case "other":
                    return GroupManagementType.other
                default:
                    return GroupManagementType.other
                }
            default:
                throw JSONSerializerError.deserializeError(type: GroupManagementType.self, json: json)
            }
        }
    }

    /// Information about a group.
    public class GroupSummary: CustomStringConvertible, JSONRepresentable {
        /// (no description)
        public let groupName: String
        /// (no description)
        public let groupId: String
        /// External ID of group. This is an arbitrary ID that an admin can attach to a group.
        public let groupExternalId: String?
        /// The number of members in the group.
        public let memberCount: UInt32?
        /// Who is allowed to manage the group.
        public let groupManagementType: TeamCommon.GroupManagementType
        public init(
            groupName: String,
            groupId: String,
            groupManagementType: TeamCommon.GroupManagementType,
            groupExternalId: String? = nil,
            memberCount: UInt32? = nil
        ) {
            stringValidator()(groupName)
            self.groupName = groupName
            stringValidator()(groupId)
            self.groupId = groupId
            nullableValidator(stringValidator())(groupExternalId)
            self.groupExternalId = groupExternalId
            nullableValidator(comparableValidator())(memberCount)
            self.memberCount = memberCount
            self.groupManagementType = groupManagementType
        }

        func json() throws -> JSON {
            try GroupSummarySerializer().serialize(self)
        }

        public var description: String {
            do {
                return "\(SerializeUtil.prepareJSONForSerialization(try GroupSummarySerializer().serialize(self)))"
            } catch {
                return "Failed to generate description for GroupSummary: \(error)"
            }
        }
    }

    public class GroupSummarySerializer: JSONSerializer {
        public init() {}
        public func serialize(_ value: GroupSummary) throws -> JSON {
            let output = [
                "group_name": try Serialization._StringSerializer.serialize(value.groupName),
                "group_id": try Serialization._StringSerializer.serialize(value.groupId),
                "group_management_type": try TeamCommon.GroupManagementTypeSerializer().serialize(value.groupManagementType),
                "group_external_id": try NullableSerializer(Serialization._StringSerializer).serialize(value.groupExternalId),
                "member_count": try NullableSerializer(Serialization._UInt32Serializer).serialize(value.memberCount),
            ]
            return .dictionary(output)
        }

        public func deserialize(_ json: JSON) throws -> GroupSummary {
            switch json {
            case .dictionary(let dict):
                let groupName = try Serialization._StringSerializer.deserialize(dict["group_name"] ?? .null)
                let groupId = try Serialization._StringSerializer.deserialize(dict["group_id"] ?? .null)
                let groupManagementType = try TeamCommon.GroupManagementTypeSerializer().deserialize(dict["group_management_type"] ?? .null)
                let groupExternalId = try NullableSerializer(Serialization._StringSerializer).deserialize(dict["group_external_id"] ?? .null)
                let memberCount = try NullableSerializer(Serialization._UInt32Serializer).deserialize(dict["member_count"] ?? .null)
                return GroupSummary(
                    groupName: groupName,
                    groupId: groupId,
                    groupManagementType: groupManagementType,
                    groupExternalId: groupExternalId,
                    memberCount: memberCount
                )
            default:
                throw JSONSerializerError.deserializeError(type: GroupSummary.self, json: json)
            }
        }
    }

    /// The group type determines how a group is created and managed.
    public enum GroupType: CustomStringConvertible, JSONRepresentable {
        /// A group to which team members are automatically added. Applicable to team folders
        /// https://www.dropbox.com/help/986 only.
        case team
        /// A group is created and managed by a user.
        case userManaged
        /// An unspecified error.
        case other

        func json() throws -> JSON {
            try GroupTypeSerializer().serialize(self)
        }

        public var description: String {
            do {
                return "\(SerializeUtil.prepareJSONForSerialization(try GroupTypeSerializer().serialize(self)))"
            } catch {
                return "Failed to generate description for GroupType: \(error)"
            }
        }
    }

    public class GroupTypeSerializer: JSONSerializer {
        public init() {}
        public func serialize(_ value: GroupType) throws -> JSON {
            switch value {
            case .team:
                var d = [String: JSON]()
                d[".tag"] = .str("team")
                return .dictionary(d)
            case .userManaged:
                var d = [String: JSON]()
                d[".tag"] = .str("user_managed")
                return .dictionary(d)
            case .other:
                var d = [String: JSON]()
                d[".tag"] = .str("other")
                return .dictionary(d)
            }
        }

        public func deserialize(_ json: JSON) throws -> GroupType {
            switch json {
            case .dictionary(let d):
                let tag = try Serialization.getTag(d)
                switch tag {
                case "team":
                    return GroupType.team
                case "user_managed":
                    return GroupType.userManaged
                case "other":
                    return GroupType.other
                default:
                    return GroupType.other
                }
            default:
                throw JSONSerializerError.deserializeError(type: GroupType.self, json: json)
            }
        }
    }

    /// The type of the space limit imposed on a team member.
    public enum MemberSpaceLimitType: CustomStringConvertible, JSONRepresentable {
        /// The team member does not have imposed space limit.
        case off
        /// The team member has soft imposed space limit - the limit is used for display and for notifications.
        case alertOnly
        /// The team member has hard imposed space limit - Dropbox file sync will stop after the limit is reached.
        case stopSync
        /// An unspecified error.
        case other

        func json() throws -> JSON {
            try MemberSpaceLimitTypeSerializer().serialize(self)
        }

        public var description: String {
            do {
                return "\(SerializeUtil.prepareJSONForSerialization(try MemberSpaceLimitTypeSerializer().serialize(self)))"
            } catch {
                return "Failed to generate description for MemberSpaceLimitType: \(error)"
            }
        }
    }

    public class MemberSpaceLimitTypeSerializer: JSONSerializer {
        public init() {}
        public func serialize(_ value: MemberSpaceLimitType) throws -> JSON {
            switch value {
            case .off:
                var d = [String: JSON]()
                d[".tag"] = .str("off")
                return .dictionary(d)
            case .alertOnly:
                var d = [String: JSON]()
                d[".tag"] = .str("alert_only")
                return .dictionary(d)
            case .stopSync:
                var d = [String: JSON]()
                d[".tag"] = .str("stop_sync")
                return .dictionary(d)
            case .other:
                var d = [String: JSON]()
                d[".tag"] = .str("other")
                return .dictionary(d)
            }
        }

        public func deserialize(_ json: JSON) throws -> MemberSpaceLimitType {
            switch json {
            case .dictionary(let d):
                let tag = try Serialization.getTag(d)
                switch tag {
                case "off":
                    return MemberSpaceLimitType.off
                case "alert_only":
                    return MemberSpaceLimitType.alertOnly
                case "stop_sync":
                    return MemberSpaceLimitType.stopSync
                case "other":
                    return MemberSpaceLimitType.other
                default:
                    return MemberSpaceLimitType.other
                }
            default:
                throw JSONSerializerError.deserializeError(type: MemberSpaceLimitType.self, json: json)
            }
        }
    }

    /// Time range.
    public class TimeRange: CustomStringConvertible, JSONRepresentable {
        /// Optional starting time (inclusive).
        public let startTime: Date?
        /// Optional ending time (exclusive).
        public let endTime: Date?
        public init(startTime: Date? = nil, endTime: Date? = nil) {
            self.startTime = startTime
            self.endTime = endTime
        }

        func json() throws -> JSON {
            try TimeRangeSerializer().serialize(self)
        }

        public var description: String {
            do {
                return "\(SerializeUtil.prepareJSONForSerialization(try TimeRangeSerializer().serialize(self)))"
            } catch {
                return "Failed to generate description for TimeRange: \(error)"
            }
        }
    }

    public class TimeRangeSerializer: JSONSerializer {
        public init() {}
        public func serialize(_ value: TimeRange) throws -> JSON {
            let output = [
                "start_time": try NullableSerializer(NSDateSerializer("%Y-%m-%dT%H:%M:%SZ")).serialize(value.startTime),
                "end_time": try NullableSerializer(NSDateSerializer("%Y-%m-%dT%H:%M:%SZ")).serialize(value.endTime),
            ]
            return .dictionary(output)
        }

        public func deserialize(_ json: JSON) throws -> TimeRange {
            switch json {
            case .dictionary(let dict):
                let startTime = try NullableSerializer(NSDateSerializer("%Y-%m-%dT%H:%M:%SZ")).deserialize(dict["start_time"] ?? .null)
                let endTime = try NullableSerializer(NSDateSerializer("%Y-%m-%dT%H:%M:%SZ")).deserialize(dict["end_time"] ?? .null)
                return TimeRange(startTime: startTime, endTime: endTime)
            default:
                throw JSONSerializerError.deserializeError(type: TimeRange.self, json: json)
            }
        }
    }
}
