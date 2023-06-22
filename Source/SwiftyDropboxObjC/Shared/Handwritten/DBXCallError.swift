///
/// Copyright (c) 2022 Dropbox, Inc. All rights reserved.
///

import Foundation
import SwiftyDropbox

extension CallError {
    var objc: DBXCallError {
        switch self {
        case let .internalServerError(code, message, requestId):
            return DBXInternalServerError(code: code, message: message, requestId: requestId, description: description)
        case let .badInputError(message, requestId):
            return DBXBadInputError(message: message, requestId: requestId, description: description)
        case let .authError(error, localizedUserMessage, message, requestId):
            return DBXAuthError(error: error, localizedUserMessage: localizedUserMessage, message: message, requestId: requestId, description: description)
        case let .accessError(error, localizedUserMessage, message, requestId):
            return DBXAccessError(error: error, localizedUserMessage: localizedUserMessage, message: message, requestId: requestId, description: description)
        case let .httpError(code, message, requestId):
            return DBXHttpError(code: code, message: message, requestId: requestId, description: description)
        case let .routeError(_, localizedUserMessage, message, requestId):
            return DBXRouteError(localizedUserMessage: localizedUserMessage, message: message, requestId: requestId, description: description)
        case let .rateLimitError(error, localizedUserMessage, message, requestId):
            return DBXRateLimitError(error: error, localizedUserMessage: localizedUserMessage, message: message, requestId: requestId, description: description)
        case let .serializationError(error):
            return DBXSerializationError(error: error, description: description)
        case let .reconnectionError(error):
            return DBXReconnectionError(error: error, description: description)
        case let .clientError(error):
            return DBXClientError(error: error, description: description)
        }
    }
}

@objc
public class DBXLocalizedUserMessage: NSObject {
    @objc
    public let text: String
    @objc
    public let locale: String

    convenience init(localizedUserMessage: LocalizedUserMessage) {
        self.init(text: localizedUserMessage.text, locale: localizedUserMessage.locale)
    }

    init(text: String, locale: String) {
        self.text = text
        self.locale = locale
    }
}

@objc
public class DBXCallError: NSObject {
    private let swiftDescription: String

    init(description: String) {
        self.swiftDescription = description
    }

    @objc
    public override var description: String {
        swiftDescription
    }

    @objc
    public var asInternalServerError: DBXInternalServerError? {
        self as? DBXInternalServerError
    }

    @objc
    public var asBadInputError: DBXBadInputError? {
        self as? DBXBadInputError
    }

    @objc
    public var asAuthError: DBXAuthError? {
        self as? DBXAuthError
    }

    @objc
    public var asAccessError: DBXAccessError? {
        self as? DBXAccessError
    }

    @objc
    public var asHttpError: DBXHttpError? {
        self as? DBXHttpError
    }

    @objc
    public var asRouteError: DBXRouteError? {
        self as? DBXRouteError
    }

    @objc
    public var asRateLimitError: DBXRateLimitError? {
        self as? DBXRateLimitError
    }

    @objc
    public var asSerializationError: DBXSerializationError? {
        self as? DBXSerializationError
    }

    @objc
    public var asReconnectionError: DBXReconnectionError? {
        self as? DBXReconnectionError
    }

    @objc
    public var asClientError: DBXClientError? {
        self as? DBXClientError
    }
}

@objc
public class DBXRequestError: DBXCallError {
    @objc
    public let message: String?
    @objc
    public let requestId: String?

    init(message: String?, requestId: String?, description: String) {
        self.message = message
        self.requestId = requestId

        super.init(description: description)
    }
}

@objc
public class DBXInternalServerError: DBXRequestError {
    @objc
    public let code: Int

    init(code: Int, message: String?, requestId: String?, description: String) {
        self.code = code

        super.init(message: message, requestId: requestId, description: description)
    }
}

@objc
public class DBXBadInputError: DBXRequestError {}

@objc
public class DBXRateLimitError: DBXRequestError {
    @objc
    public let error: DBXAuthRateLimitError
    @objc
    public let localizedUserMessage: DBXLocalizedUserMessage?

    init(error: Auth.RateLimitError, localizedUserMessage: LocalizedUserMessage?, message: String?, requestId: String?, description: String) {
        self.error = DBXAuthRateLimitError(swift: error)
        if let localizedUserMessage = localizedUserMessage {
            self.localizedUserMessage = DBXLocalizedUserMessage(localizedUserMessage: localizedUserMessage)
        } else {
            self.localizedUserMessage = nil
        }

        super.init(message: message, requestId: requestId, description: description)
    }
}

@objc
public class DBXHttpError: DBXRequestError {
    @objc
    public let code: Int

    init(code: Int?, message: String?, requestId: String?, description: String) {
        self.code = code ?? 0

        super.init(message: message, requestId: requestId, description: description)
    }
}

@objc
public class DBXAuthError: DBXRequestError {
    @objc
    public let error: DBXAuthAuthError
    @objc
    public let localizedUserMessage: DBXLocalizedUserMessage?

    init(error: Auth.AuthError, localizedUserMessage: LocalizedUserMessage?, message: String?, requestId: String?, description: String) {
        self.error = DBXAuthAuthError(swift: error)
        if let localizedUserMessage = localizedUserMessage {
            self.localizedUserMessage = DBXLocalizedUserMessage(localizedUserMessage: localizedUserMessage)
        } else {
            self.localizedUserMessage = nil
        }

        super.init(message: message, requestId: requestId, description: description)
    }
}

@objc
public class DBXAccessError: DBXRequestError {
    @objc
    public let error: DBXAuthAccessError
    @objc
    public let localizedUserMessage: DBXLocalizedUserMessage?

    init(error: Auth.AccessError, localizedUserMessage: LocalizedUserMessage?, message: String?, requestId: String?, description: String) {
        self.error = DBXAuthAccessError(swift: error)
        if let localizedUserMessage = localizedUserMessage {
            self.localizedUserMessage = DBXLocalizedUserMessage(localizedUserMessage: localizedUserMessage)
        } else {
            self.localizedUserMessage = nil
        }

        super.init(message: message, requestId: requestId, description: description)
    }
}

@objc
public class DBXRouteError: DBXRequestError {
    @objc
    public let localizedUserMessage: DBXLocalizedUserMessage?

    init(localizedUserMessage: LocalizedUserMessage?, message: String?, requestId: String?, description: String) {
        if let localizedUserMessage = localizedUserMessage {
            self.localizedUserMessage = DBXLocalizedUserMessage(localizedUserMessage: localizedUserMessage)
        } else {
            self.localizedUserMessage = nil
        }

        super.init(message: message, requestId: requestId, description: description)
    }
}

@objc
public class DBXSerializationError: DBXCallError {
    @objc
    public let error: Error

    init(error: Error, description: String) {
        self.error = error

        super.init(description: description)
    }
}

@objc
public class DBXReconnectionError: DBXCallError {
    @objc
    public let error: Error

    init(error: Error, description: String) {
        self.error = error

        super.init(description: description)
    }
}

@objc
public class DBXClientError: DBXCallError {
    @objc
    public let error: Error?

    init(error: Error?, description: String) {
        self.error = error

        super.init(description: description)
    }
}
