///
/// Copyright (c) 2024 Dropbox, Inc. All rights reserved.
///
/// Auto-generated by Stone, do not modify.
///

import Foundation
import stone_sdk_objc
import stone_sdk_swift
import stone_sdk_swift_objc

func mapDBSEENSTATEPlatformTypeToDBXOptional(object: DBSEENSTATEPlatformType?) -> DBXSeenStatePlatformType? {
    guard let object = object else { return nil }
    return mapDBSEENSTATEPlatformTypeToDBX(object: object)
}

func mapDBSEENSTATEPlatformTypeToDBX(object: DBSEENSTATEPlatformType) -> DBXSeenStatePlatformType {
    if object.isWeb() {
        return DBXSeenStatePlatformTypeWeb()
    }
    if object.isDesktop() {
        return DBXSeenStatePlatformTypeDesktop()
    }
    if object.isMobileIos() {
        return DBXSeenStatePlatformTypeMobileIos()
    }
    if object.isMobileAndroid() {
        return DBXSeenStatePlatformTypeMobileAndroid()
    }
    if object.isApi() {
        return DBXSeenStatePlatformTypeApi()
    }
    if object.isUnknown() {
        return DBXSeenStatePlatformTypeUnknown()
    }
    if object.isMobile() {
        return DBXSeenStatePlatformTypeMobile()
    }
    if object.isOther() {
        return DBXSeenStatePlatformTypeOther()
    }
    fatalError("codegen error")
}
