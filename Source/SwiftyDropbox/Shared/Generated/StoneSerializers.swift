///
/// Copyright (c) 2016 Dropbox, Inc. All rights reserved.
///

import Foundation

// The objects in this file are used by generated code and should not need to be invoked manually.

public enum JSON: Equatable {
    case array([JSON])
    case dictionary([String: JSON])
    case str(String)
    case number(NSNumber)
    case null
}

public class SerializeUtil {
    public class func objectToJSON(_ json: AnyObject) throws -> JSON {
        switch json {
        case _ as NSNull:
            return .null
        case let num as NSNumber:
            return .number(num)
        case let str as String:
            return .str(str)
        case let dict as [String: AnyObject]:
            var ret = [String: JSON]()
            for (k, v) in dict {
                ret[k] = try objectToJSON(v)
            }
            return .dictionary(ret)
        case let array as [AnyObject]:
            return try .array(array.map(objectToJSON))
        default:
            throw JSONSerializerError<SerializeUtil>.unknownTypeOfJSON(json: json)
        }
    }

    public class func prepareJSONForSerialization(_ json: JSON) -> AnyObject {
        switch json {
        case .array(let array):
            return array.map(prepareJSONForSerialization) as AnyObject
        case .dictionary(let dict):
            var ret = [String: AnyObject]()
            for (k, v) in dict {
                // kind of a hack...
                switch v {
                case .null:
                    continue
                default:
                    ret[k] = prepareJSONForSerialization(v)
                }
            }
            return ret as AnyObject
        case .number(let n):
            return n
        case .str(let s):
            return s as AnyObject
        case .null:
            return NSNull()
        }
    }

    public class func dumpJSON(_ json: JSON) throws -> Data? {
        switch json {
        case .null:
            return "null".data(using: String.Encoding.utf8, allowLossyConversion: false)
        default:
            let obj: AnyObject = prepareJSONForSerialization(json)
            if JSONSerialization.isValidJSONObject(obj) {
                return try JSONSerialization.data(withJSONObject: obj, options: JSONSerialization.WritingOptions())
            } else {
                throw JSONSerializerError<SerializeUtil>.invalidTopLevelType(json: json, object: obj)
            }
        }
    }

    public class func parseJSON(_ data: Data) throws -> JSON {
        let obj: AnyObject = try JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.allowFragments) as AnyObject
        return try objectToJSON(obj)
    }
}

public protocol JSONSerializer {
    associatedtype ValueType
    func serialize(_: ValueType) throws -> JSON
    func deserialize(_: JSON) throws -> ValueType
}

enum JSONSerializerError<T>: Error {
    case unknownTypeOfJSON(json: AnyObject)
    case invalidTopLevelType(json: JSON, object: AnyObject)
    case deserializeError(type: T.Type, json: JSON)
    case missingOrMalformedFields(json: JSON)
    case missingOrMalformedTag(dict: [String: JSON], tag: JSON?)
    case unknownTag(type: T.Type, json: JSON, tag: String)
    case unexpectedSubtype(type: T.Type, subtype: Any)
}

public class VoidSerializer: JSONSerializer {
    public func serialize(_ value: Void) throws -> JSON {
        .null
    }

    public func deserialize(_ json: JSON) throws -> Void {
        switch json {
        case .null:
            return
        default:
            throw JSONSerializerError.deserializeError(type: ValueType.self, json: json)
        }
    }
}

public class ArraySerializer<T: JSONSerializer>: JSONSerializer {
    var elementSerializer: T

    init(_ elementSerializer: T) {
        self.elementSerializer = elementSerializer
    }

    public func serialize(_ arr: [T.ValueType]) throws -> JSON {
        .array(try arr.map { try self.elementSerializer.serialize($0) })
    }

    public func deserialize(_ json: JSON) throws -> [T.ValueType] {
        switch json {
        case .array(let arr):
            return try arr.map { try self.elementSerializer.deserialize($0) }
        default:
            throw JSONSerializerError.deserializeError(type: ValueType.self, json: json)
        }
    }
}

public class DictionarySerializer<T: JSONSerializer>: JSONSerializer {
    var valueSerializer: T

    init(_ elementSerializer: T) {
        self.valueSerializer = elementSerializer
    }

    public func serialize(_ dict: [String: T.ValueType]) throws -> JSON {
        .dictionary(try dict.mapValues { try self.valueSerializer.serialize($0) })
    }

    public func deserialize(_ json: JSON) throws -> [String: T.ValueType] {
        switch json {
        case .dictionary(let dict):
            return try dict.mapValues { try self.valueSerializer.deserialize($0) }
        default:
            throw JSONSerializerError.deserializeError(type: ValueType.self, json: json)
        }
    }
}

public class StringSerializer: JSONSerializer {
    public func serialize(_ value: String) throws -> JSON {
        .str(value)
    }

    public func deserialize(_ json: JSON) throws -> String {
        switch json {
        case .str(let s):
            return s
        default:
            throw JSONSerializerError.deserializeError(type: ValueType.self, json: json)
        }
    }
}

public class NSDateSerializer: JSONSerializer {
    var dateFormatter: DateFormatter

    fileprivate func convertFormat(_ format: String) -> String? {
        func symbolForToken(_ token: String) -> String {
            switch token {
            case "%a": // Weekday as locale’s abbreviated name.
                return "EEE"
            case "%A": // Weekday as locale’s full name.
                return "EEEE"
            case "%w": // Weekday as a decimal number, where 0 is Sunday and 6 is Saturday. 0, 1, ..., 6
                return "ccccc"
            case "%d": // Day of the month as a zero-padded decimal number. 01, 02, ..., 31
                return "dd"
            case "%b": // Month as locale’s abbreviated name.
                return "MMM"
            case "%B": // Month as locale’s full name.
                return "MMMM"
            case "%m": // Month as a zero-padded decimal number. 01, 02, ..., 12
                return "MM"
            case "%y": // Year without century as a zero-padded decimal number. 00, 01, ..., 99
                return "yy"
            case "%Y": // Year with century as a decimal number. 1970, 1988, 2001, 2013
                return "yyyy"
            case "%H": // Hour (24-hour clock) as a zero-padded decimal number. 00, 01, ..., 23
                return "HH"
            case "%I": // Hour (12-hour clock) as a zero-padded decimal number. 01, 02, ..., 12
                return "hh"
            case "%p": // Locale’s equivalent of either AM or PM.
                return "a"
            case "%M": // Minute as a zero-padded decimal number. 00, 01, ..., 59
                return "mm"
            case "%S": // Second as a zero-padded decimal number. 00, 01, ..., 59
                return "ss"
            case "%f": // Microsecond as a decimal number, zero-padded on the left. 000000, 000001, ..., 999999
                return "SSSSSS"
            case "%z": // UTC offset in the form +HHMM or -HHMM (empty string if the the object is naive). (empty), +0000, -0400, +1030
                return "Z"
            case "%Z": // Time zone name (empty string if the object is naive). (empty), UTC, EST, CST
                return "z"
            case "%j": // Day of the year as a zero-padded decimal number. 001, 002, ..., 366
                return "DDD"
            case "%U": // Week number of the year (Sunday as the first day of the week) as a zero padded decimal number. All days in a new year preceding the first Sunday are considered to be in week 0. 00, 01, ..., 53 (6)
                return "ww"
            case "%W": // Week number of the year (Monday as the first day of the week) as a decimal number. All days in a new year preceding the first Monday are considered to be in week 0. 00, 01, ..., 53 (6)
                return "ww" // one of these can't be right
            case "%c": // Locale’s appropriate date and time representation.
                return "" // unsupported
            case "%x": // Locale’s appropriate date representation.
                return "" // unsupported
            case "%X": // Locale’s appropriate time representation.
                return "" // unsupported
            case "%%": // A literal '%' character.
                return "%"
            default:
                return ""
            }
        }
        var newFormat = ""
        var inQuotedText = false
        var i = format.startIndex
        while i < format.endIndex {
            if format[i] == "%" {
                if format.index(after: i) >= format.endIndex {
                    return nil
                }
                i = format.index(after: i)
                let token = "%\(format[i])"
                if inQuotedText {
                    newFormat += "'"
                    inQuotedText = false
                }
                newFormat += symbolForToken(token)
            } else {
                if "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ".contains(format[i]) {
                    if !inQuotedText {
                        newFormat += "'"
                        inQuotedText = true
                    }
                } else if format[i] == "'" {
                    newFormat += "'"
                }
                newFormat += String(format[i])
            }
            i = format.index(after: i)
        }
        if inQuotedText {
            newFormat += "'"
        }
        return newFormat
    }

    init(_ dateFormat: String) {
        self.dateFormatter = DateFormatter()
        dateFormatter.timeZone = TimeZone(identifier: "UTC")
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.dateFormat = convertFormat(dateFormat)
    }

    public func serialize(_ value: Date) throws -> JSON {
        .str(dateFormatter.string(from: value))
    }

    public func deserialize(_ json: JSON) throws -> Date {
        switch json {
        case .str(let s):
            guard let date = dateFormatter.date(from: s) else {
                throw JSONSerializerError.deserializeError(type: ValueType.self, json: json)
            }
            return date
        default:
            throw JSONSerializerError.deserializeError(type: ValueType.self, json: json)
        }
    }
}

public class BoolSerializer: JSONSerializer {
    public func serialize(_ value: Bool) throws -> JSON {
        .number(NSNumber(value: value as Bool))
    }

    public func deserialize(_ json: JSON) throws -> Bool {
        switch json {
        case .number(let b):
            return b.boolValue
        default:
            throw JSONSerializerError.deserializeError(type: ValueType.self, json: json)
        }
    }
}

public class UInt64Serializer: JSONSerializer {
    public func serialize(_ value: UInt64) throws -> JSON {
        .number(NSNumber(value: value as UInt64))
    }

    public func deserialize(_ json: JSON) throws -> UInt64 {
        switch json {
        case .number(let n):
            return n.uint64Value
        default:
            throw JSONSerializerError.deserializeError(type: ValueType.self, json: json)
        }
    }
}

public class Int64Serializer: JSONSerializer {
    public func serialize(_ value: Int64) throws -> JSON {
        .number(NSNumber(value: value as Int64))
    }

    public func deserialize(_ json: JSON) throws -> Int64 {
        switch json {
        case .number(let n):
            return n.int64Value
        default:
            throw JSONSerializerError.deserializeError(type: ValueType.self, json: json)
        }
    }
}

public class Int32Serializer: JSONSerializer {
    public func serialize(_ value: Int32) throws -> JSON {
        .number(NSNumber(value: value as Int32))
    }

    public func deserialize(_ json: JSON) throws -> Int32 {
        switch json {
        case .number(let n):
            return n.int32Value
        default:
            throw JSONSerializerError.deserializeError(type: ValueType.self, json: json)
        }
    }
}

public class UInt32Serializer: JSONSerializer {
    public func serialize(_ value: UInt32) throws -> JSON {
        .number(NSNumber(value: value as UInt32))
    }

    public func deserialize(_ json: JSON) throws -> UInt32 {
        switch json {
        case .number(let n):
            return n.uint32Value
        default:
            throw JSONSerializerError.deserializeError(type: ValueType.self, json: json)
        }
    }
}

public class NSDataSerializer: JSONSerializer {
    public func serialize(_ value: Data) throws -> JSON {
        .str(value.base64EncodedString(options: []))
    }

    public func deserialize(_ json: JSON) throws -> Data {
        switch json {
        case .str(let s):
            guard let data = Data(base64Encoded: s, options: []) else {
                throw JSONSerializerError.deserializeError(type: ValueType.self, json: json)
            }
            return data
        default:
            throw JSONSerializerError.deserializeError(type: ValueType.self, json: json)
        }
    }
}

public class FloatSerializer: JSONSerializer {
    public func serialize(_ value: Float) throws -> JSON {
        .number(NSNumber(value: value as Float))
    }

    public func deserialize(_ json: JSON) throws -> Float {
        switch json {
        case .number(let n):
            return n.floatValue
        default:
            throw JSONSerializerError.deserializeError(type: ValueType.self, json: json)
        }
    }
}

public class DoubleSerializer: JSONSerializer {
    public func serialize(_ value: Double) throws -> JSON {
        .number(NSNumber(value: value as Double))
    }

    public func deserialize(_ json: JSON) throws -> Double {
        switch json {
        case .number(let n):
            return n.doubleValue
        default:
            throw JSONSerializerError.deserializeError(type: ValueType.self, json: json)
        }
    }
}

public class NullableSerializer<T: JSONSerializer>: JSONSerializer {
    var internalSerializer: T

    init(_ serializer: T) {
        self.internalSerializer = serializer
    }

    public func serialize(_ value: T.ValueType?) throws -> JSON {
        if let v = value {
            return try internalSerializer.serialize(v)
        } else {
            return .null
        }
    }

    public func deserialize(_ json: JSON) throws -> T.ValueType? {
        switch json {
        case .null:
            return nil
        default:
            return try internalSerializer.deserialize(json)
        }
    }
}

struct Serialization {
    static var _StringSerializer = StringSerializer()
    static var _BoolSerializer = BoolSerializer()
    static var _UInt64Serializer = UInt64Serializer()
    static var _UInt32Serializer = UInt32Serializer()
    static var _Int64Serializer = Int64Serializer()
    static var _Int32Serializer = Int32Serializer()

    static var _VoidSerializer = VoidSerializer()
    static var _NSDataSerializer = NSDataSerializer()
    static var _FloatSerializer = FloatSerializer()
    static var _DoubleSerializer = DoubleSerializer()

    static func getFields(_ json: JSON) throws -> [String: JSON] {
        switch json {
        case .dictionary(let dict):
            return dict
        default:
            throw JSONSerializerError<Serialization>.missingOrMalformedFields(json: json)
        }
    }

    static func getTag(_ d: [String: JSON]) throws -> String {
        let tag = d[".tag"]
        switch tag {
        case .str(let str):
            return str
        default:
            throw JSONSerializerError<Serialization>.missingOrMalformedTag(dict: d, tag: tag)
        }
    }
}
