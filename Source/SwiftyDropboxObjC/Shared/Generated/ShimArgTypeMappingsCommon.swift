///
/// Copyright (c) 2024 Dropbox, Inc. All rights reserved.
///
/// Auto-generated by Stone, do not modify.
///

import Foundation
import stone_sdk_objc
import stone_sdk_swift
import stone_sdk_swift_objc

func mapDBCOMMONPathRootToDBXOptional(object: DBCOMMONPathRoot?) -> DBXCommonPathRoot? {
    guard let object = object else { return nil }
    return mapDBCOMMONPathRootToDBX(object: object)
}

func mapDBCOMMONPathRootToDBX(object: DBCOMMONPathRoot) -> DBXCommonPathRoot {
    if object.isHome() {
        return DBXCommonPathRootHome()
    }
    if object.isRoot() {
        let root = object.root
        return DBXCommonPathRoot.factory(swift: .root(root))
    }
    if object.isNamespaceId() {
        let namespaceId = object.namespaceId
        return DBXCommonPathRoot.factory(swift: .namespaceId(namespaceId))
    }
    if object.isOther() {
        return DBXCommonPathRootOther()
    }
    fatalError("codegen error")
}

func mapDBCOMMONPathRootErrorToDBXOptional(object: DBCOMMONPathRootError?) -> DBXCommonPathRootError? {
    guard let object = object else { return nil }
    return mapDBCOMMONPathRootErrorToDBX(object: object)
}

func mapDBCOMMONPathRootErrorToDBX(object: DBCOMMONPathRootError) -> DBXCommonPathRootError {
    if object.isInvalidRoot() {
        let invalidRoot = mapDBCOMMONRootInfoToDBX(object: object.invalidRoot)
        return DBXCommonPathRootError.factory(swift: .invalidRoot(invalidRoot.swift))
    }
    if object.isNoPermission() {
        return DBXCommonPathRootErrorNoPermission()
    }
    if object.isOther() {
        return DBXCommonPathRootErrorOther()
    }
    fatalError("codegen error")
}

func mapDBCOMMONRootInfoToDBXOptional(object: DBCOMMONRootInfo?) -> DBXCommonRootInfo? {
    guard let object = object else { return nil }
    return mapDBCOMMONRootInfoToDBX(object: object)
}

func mapDBCOMMONRootInfoToDBX(object: DBCOMMONRootInfo) -> DBXCommonRootInfo {
    switch object {
    case let object as DBCOMMONTeamRootInfo:
        return DBXCommonTeamRootInfo(rootNamespaceId: object.rootNamespaceId, homeNamespaceId: object.homeNamespaceId, homePath: object.homePath)
    case let object as DBCOMMONUserRootInfo:
        return DBXCommonUserRootInfo(rootNamespaceId: object.rootNamespaceId, homeNamespaceId: object.homeNamespaceId)
    default:
        return DBXCommonRootInfo(rootNamespaceId: object.rootNamespaceId, homeNamespaceId: object.homeNamespaceId)
    }
}

func mapDBCOMMONTeamRootInfoToDBXOptional(object: DBCOMMONTeamRootInfo?) -> DBXCommonTeamRootInfo? {
    guard let object = object else { return nil }
    return mapDBCOMMONTeamRootInfoToDBX(object: object)
}

func mapDBCOMMONTeamRootInfoToDBX(object: DBCOMMONTeamRootInfo) -> DBXCommonTeamRootInfo {
    DBXCommonTeamRootInfo(rootNamespaceId: object.rootNamespaceId, homeNamespaceId: object.homeNamespaceId, homePath: object.homePath)
}

func mapDBCOMMONUserRootInfoToDBXOptional(object: DBCOMMONUserRootInfo?) -> DBXCommonUserRootInfo? {
    guard let object = object else { return nil }
    return mapDBCOMMONUserRootInfoToDBX(object: object)
}

func mapDBCOMMONUserRootInfoToDBX(object: DBCOMMONUserRootInfo) -> DBXCommonUserRootInfo {
    DBXCommonUserRootInfo(rootNamespaceId: object.rootNamespaceId, homeNamespaceId: object.homeNamespaceId)
}
