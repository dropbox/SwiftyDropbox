///
/// Copyright (c) 2024 Dropbox, Inc. All rights reserved.
///
/// Auto-generated by Stone, do not modify.
///

import Foundation
import stone_sdk_objc
import stone_sdk_swift
import stone_sdk_swift_objc

func mapDBSECONDARYEMAILSSecondaryEmailToDBXOptional(object: DBSECONDARYEMAILSSecondaryEmail?) -> DBXSecondaryEmailsSecondaryEmail? {
    guard let object = object else { return nil }
    return mapDBSECONDARYEMAILSSecondaryEmailToDBX(object: object)
}

func mapDBSECONDARYEMAILSSecondaryEmailToDBX(object: DBSECONDARYEMAILSSecondaryEmail) -> DBXSecondaryEmailsSecondaryEmail {
    DBXSecondaryEmailsSecondaryEmail(email: object.email, isVerified: object.isVerified)
}
