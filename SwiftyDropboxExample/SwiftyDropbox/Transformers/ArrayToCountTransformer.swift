//
//  ArrayToCountTransformer.swift
//  FlashCloud
//
//  Created by krivoblotsky on 1/7/16.
//  Copyright © 2016 Home. All rights reserved.
//

import Foundation

@objc(ArrayToCountTransformer) class ArrayToCountTransformer:NSValueTransformer
{
    override class func allowsReverseTransformation() -> Bool
    {
        return false
    }
    
    override func transformedValue(value: AnyObject?) -> AnyObject?
    {
        guard let array = value as? Array<NSOperation> else { return NSNumber(integer: 0) }
        return NSNumber(integer: array.count)
    }
}

@objc(ArrayToBoolTransformer) class ArrayToBoolTransformer:NSValueTransformer
{
    override class func allowsReverseTransformation() -> Bool
    {
        return false
    }
    
    override func transformedValue(value: AnyObject?) -> AnyObject?
    {
        guard let array = value as? Array<NSOperation> else { return NSNumber(integer: 0) }
        return NSNumber(bool: !array.isEmpty)
    }
}

@objc(ArrayToBoolTransformer_Negative) class ArrayToBoolTransformer_Negative:NSValueTransformer
{
    override class func allowsReverseTransformation() -> Bool
    {
        return false
    }
    
    override func transformedValue(value: AnyObject?) -> AnyObject?
    {
        guard let array = value as? Array<NSOperation> else { return NSNumber(integer: 0) }
        return NSNumber(bool: array.isEmpty)
    }
}