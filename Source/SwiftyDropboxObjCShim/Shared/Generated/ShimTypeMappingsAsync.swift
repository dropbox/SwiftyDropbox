///
/// Copyright (c) 2024 Dropbox, Inc. All rights reserved.
///
/// Auto-generated by Stone, do not modify.
///

import Foundation
import stone_sdk_objc
import stone_sdk_swift
import stone_sdk_swift_objc

func mapDBXAsyncLaunchResultBaseToDBOptional(object: DBXAsyncLaunchResultBase?) -> DBASYNCLaunchResultBase? {
    guard let object = object else { return nil }
    return mapDBXAsyncLaunchResultBaseToDB(object: object)
}

func mapDBXAsyncLaunchResultBaseToDB(object: DBXAsyncLaunchResultBase) -> DBASYNCLaunchResultBase {
    if let object = object.asAsyncJobId {
        let asyncJobId = object.asyncJobId
        return DBASYNCLaunchResultBase(asyncJobId: asyncJobId)
    }
    fatalError("codegen error")
}

func mapDBXAsyncLaunchEmptyResultToDBOptional(object: DBXAsyncLaunchEmptyResult?) -> DBASYNCLaunchEmptyResult? {
    guard let object = object else { return nil }
    return mapDBXAsyncLaunchEmptyResultToDB(object: object)
}

func mapDBXAsyncLaunchEmptyResultToDB(object: DBXAsyncLaunchEmptyResult) -> DBASYNCLaunchEmptyResult {
    if let object = object.asAsyncJobId {
        let asyncJobId = object.asyncJobId
        return DBASYNCLaunchEmptyResult(asyncJobId: asyncJobId)
    }
    if object.asComplete != nil {
        return DBASYNCLaunchEmptyResult(complete: ())
    }
    fatalError("codegen error")
}

func mapDBXAsyncPollArgToDBOptional(object: DBXAsyncPollArg?) -> DBASYNCPollArg? {
    guard let object = object else { return nil }
    return mapDBXAsyncPollArgToDB(object: object)
}

func mapDBXAsyncPollArgToDB(object: DBXAsyncPollArg) -> DBASYNCPollArg {
    DBASYNCPollArg(asyncJobId: object.asyncJobId)
}

func mapDBXAsyncPollResultBaseToDBOptional(object: DBXAsyncPollResultBase?) -> DBASYNCPollResultBase? {
    guard let object = object else { return nil }
    return mapDBXAsyncPollResultBaseToDB(object: object)
}

func mapDBXAsyncPollResultBaseToDB(object: DBXAsyncPollResultBase) -> DBASYNCPollResultBase {
    if object.asInProgress != nil {
        return DBASYNCPollResultBase(inProgress: ())
    }
    fatalError("codegen error")
}

func mapDBXAsyncPollEmptyResultToDBOptional(object: DBXAsyncPollEmptyResult?) -> DBASYNCPollEmptyResult? {
    guard let object = object else { return nil }
    return mapDBXAsyncPollEmptyResultToDB(object: object)
}

func mapDBXAsyncPollEmptyResultToDB(object: DBXAsyncPollEmptyResult) -> DBASYNCPollEmptyResult {
    if object.asInProgress != nil {
        return DBASYNCPollEmptyResult(inProgress: ())
    }
    if object.asComplete != nil {
        return DBASYNCPollEmptyResult(complete: ())
    }
    fatalError("codegen error")
}

func mapDBXAsyncPollErrorToDBOptional(object: DBXAsyncPollError?) -> DBASYNCPollError? {
    guard let object = object else { return nil }
    return mapDBXAsyncPollErrorToDB(object: object)
}

func mapDBXAsyncPollErrorToDB(object: DBXAsyncPollError) -> DBASYNCPollError {
    if object.asInvalidAsyncJobId != nil {
        return DBASYNCPollError(invalidAsyncJobId: ())
    }
    if object.asInternalError != nil {
        return DBASYNCPollError(internalError: ())
    }
    if object.asOther != nil {
        return DBASYNCPollError(other: ())
    }
    fatalError("codegen error")
}
