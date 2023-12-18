//
//  Copyright (c) 2022 Dropbox Inc. All rights reserved.
//

import Foundation

public struct LocalizedUserMessage {
    public var text: String
    public var locale: String
}

public enum ClientError: Error {
    case oauthError(Error)
    case urlSessionError(Error)
    case fileAccessError(Error)
    case requestObjectDeallocated
    case unexpectedState
    case other(Error)
}

public enum SerializationError: Error {
    case missingResultHeader
    case missingResultData
}

public enum CallError<EType>: Error, CustomStringConvertible {
    case internalServerError(Int, String?, String?)
    case badInputError(String?, String?)
    case rateLimitError(Auth.RateLimitError, LocalizedUserMessage?, String?, String?)
    case httpError(Int?, String?, String?)
    case authError(Auth.AuthError, LocalizedUserMessage?, String?, String?)
    case accessError(Auth.AccessError, LocalizedUserMessage?, String?, String?)
    case routeError(Box<EType>, LocalizedUserMessage?, String?, String?)
    case serializationError(Error)
    case reconnectionError(Error)
    case clientError(ClientError)

    public var description: String {
        switch self {
        case let .internalServerError(code, message, requestId):
            var ret = ""
            if let r = requestId {
                ret += "[request-id \(r)] "
            }
            ret += "Internal Server Error \(code)"
            if let m = message {
                ret += ": \(m)"
            }
            return ret
        case let .badInputError(message, requestId):
            var ret = ""
            if let r = requestId {
                ret += "[request-id \(r)] "
            }
            ret += "Bad Input"
            if let m = message {
                ret += ": \(m)"
            }
            return ret
        case let .authError(error, _, _, requestId):
            var ret = ""
            if let r = requestId {
                ret += "[request-id \(r)] "
            }
            ret += "API auth error - \(error)"
            return ret
        case let .accessError(error, _, _, requestId):
            var ret = ""
            if let r = requestId {
                ret += "[request-id \(r)] "
            }
            ret += "API access error - \(error)"
            return ret
        case let .httpError(code, message, requestId):
            var ret = ""
            if let r = requestId {
                ret += "[request-id \(r)] "
            }
            ret += "HTTP Error"
            if let c = code {
                ret += "\(c)"
            }
            if let m = message {
                ret += ": \(m)"
            }
            return ret
        case let .routeError(box, _, _, requestId):
            var ret = ""
            if let r = requestId {
                ret += "[request-id \(r)] "
            }
            ret += "API route error - \(box.unboxed)"
            return ret
        case let .rateLimitError(error, _, _, requestId):
            var ret = ""
            if let r = requestId {
                ret += "[request-id \(r)] "
            }
            ret += "API rate limit error - \(error)"
            return ret
        case let .serializationError(err):
            return "\(err)"
        case let .reconnectionError(err):
            return "\(err)"
        case let .clientError(err):
            return "\(err)"
        }
    }

    static func error<ESerial: JSONSerializer>(response: HTTPURLResponse, data: Data?, errorSerializer: ESerial) throws -> CallError<ESerial.ValueType> {
        let requestId = requestId(from: response)
        let code = response.statusCode

        switch code {
        case 500 ... 599:
            return .internalServerError(code, message(from: data), requestId)
        case 400:
            return .badInputError(message(from: data), requestId)
        case 401:
            let (errorJson, userMessage, errorSummary) = try components(from: data, errorSerializer: errorSerializer)
            return .authError(try Auth.AuthErrorSerializer().deserialize(errorJson), userMessage, errorSummary, requestId)
        case 403:
            let (errorJson, userMessage, errorSummary) = try components(from: data, errorSerializer: errorSerializer)
            return .accessError(try Auth.AccessErrorSerializer().deserialize(errorJson), userMessage, errorSummary, requestId)
        case 409:
            let (errorJson, userMessage, errorSummary) = try components(from: data, errorSerializer: errorSerializer)
            return .routeError(try Box(errorSerializer.deserialize(errorJson)), userMessage, errorSummary, requestId)
        case 429:
            let (errorJson, userMessage, errorSummary) = try components(from: data, errorSerializer: errorSerializer)
            return .rateLimitError(try Auth.RateLimitErrorSerializer().deserialize(errorJson), userMessage, errorSummary, requestId)
        default:
            return .httpError(code, "An error occurred.", requestId)
        }
    }

    init(clientError: ClientError) {
        self = .clientError(clientError)
    }

    init<ESerial: JSONSerializer>(_ response: HTTPURLResponse, data: Data, errorSerializer: ESerial) where ESerial.ValueType == EType {
        do {
            self = try Self.error(response: response, data: data, errorSerializer: errorSerializer)
        } catch {
            self = .serializationError(error)
        }
    }
}

private func requestId(from response: HTTPURLResponse?) -> String? {
    response?.allHeaderFields["X-Dropbox-Request-Id"] as? String
}

private func message(from data: Data?) -> String {
    var message = ""
    if let d = data {
        message = Utilities.utf8Decode(d)
    }
    return message
}

private func components<ESerial: JSONSerializer>(from data: Data?, errorSerializer: ESerial) throws -> (JSON, LocalizedUserMessage, String) {
    var jsonObject: [String: JSON] = [:]
    var json: JSON = .null

    do {
        json = try data.flatMap { try SerializeUtil.parseJSON($0) } ?? .null

        let dictionaryContents: ((JSON) -> [String: JSON]?) = { json in
            if case .dictionary(let contents) = json {
                return contents
            }
            return nil
        }

        jsonObject = try dictionaryContents(json).orThrow()

        return (
            try jsonObject["error"].orThrow(),
            getUserMessageFromJson(json: jsonObject, key: "user_message"),
            getStringFromJson(json: jsonObject, key: "error_summary")
        )
    } catch {
        throw JSONSerializerError.deserializeError(type: ESerial.ValueType.self, json: json)
    }
}

private func getUserMessageFromJson(json: [String: JSON], key: String) -> LocalizedUserMessage {
    if let json = json[key] {
        switch json {
        case .dictionary(let json):
            let text = getStringFromJson(json: json, key: "text")
            let locale = getStringFromJson(json: json, key: "locale")
            let userMessage = LocalizedUserMessage(text: text, locale: locale)
            return userMessage
        default:
            break
        }
    }

    return LocalizedUserMessage(text: "", locale: "")
}

private func getStringFromJson(json: [String: JSON], key: String) -> String {
    if let jsonStr = json[key] {
        switch jsonStr {
        case .str(let str):
            return str
        default:
            break
        }
    }

    return ""
}

public class Box<T> {
    public let unboxed: T
    init(_ v: T) { self.unboxed = v }
}
