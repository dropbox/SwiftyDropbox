///
/// Copyright (c) 2024 Dropbox, Inc. All rights reserved.
///
/// Auto-generated by Stone, do not modify.
///

import Foundation
import stone_sdk_objc
import stone_sdk_swift
import stone_sdk_swift_objc

func mapDBXOpenidOpenIdErrorToDBOptional(object: DBXOpenidOpenIdError?) -> DBOPENIDOpenIdError? {
    guard let object = object else { return nil }
    return mapDBXOpenidOpenIdErrorToDB(object: object)
}

func mapDBXOpenidOpenIdErrorToDB(object: DBXOpenidOpenIdError) -> DBOPENIDOpenIdError {
    if object.asIncorrectOpenidScopes != nil {
        return DBOPENIDOpenIdError(incorrectOpenidScopes: ())
    }
    if object.asOther != nil {
        return DBOPENIDOpenIdError(other: ())
    }
    fatalError("codegen error")
}

func mapDBXOpenidUserInfoArgsToDBOptional(object: DBXOpenidUserInfoArgs?) -> DBOPENIDUserInfoArgs? {
    guard let object = object else { return nil }
    return mapDBXOpenidUserInfoArgsToDB(object: object)
}

func mapDBXOpenidUserInfoArgsToDB(object: DBXOpenidUserInfoArgs) -> DBOPENIDUserInfoArgs {
    DBOPENIDUserInfoArgs(default: ())
}

func mapDBXOpenidUserInfoErrorToDBOptional(object: DBXOpenidUserInfoError?) -> DBOPENIDUserInfoError? {
    guard let object = object else { return nil }
    return mapDBXOpenidUserInfoErrorToDB(object: object)
}

func mapDBXOpenidUserInfoErrorToDB(object: DBXOpenidUserInfoError) -> DBOPENIDUserInfoError {
    if let object = object.asOpenidError {
        let openidError = mapDBXOpenidOpenIdErrorToDB(object: object.openidError)
        return DBOPENIDUserInfoError(openidError: openidError)
    }
    if object.asOther != nil {
        return DBOPENIDUserInfoError(other: ())
    }
    fatalError("codegen error")
}

func mapDBXOpenidUserInfoResultToDBOptional(object: DBXOpenidUserInfoResult?) -> DBOPENIDUserInfoResult? {
    guard let object = object else { return nil }
    return mapDBXOpenidUserInfoResultToDB(object: object)
}

func mapDBXOpenidUserInfoResultToDB(object: DBXOpenidUserInfoResult) -> DBOPENIDUserInfoResult {
    DBOPENIDUserInfoResult(
        familyName: object.familyName,
        givenName: object.givenName,
        email: object.email,
        emailVerified: object.emailVerified,
        iss: object.iss,
        sub: object.sub
    )
}
