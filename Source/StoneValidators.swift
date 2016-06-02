import Foundation

// The objects in this file are used by generated code and should not need to be invoked manually.

var _assertFunc: (Bool,String) -> Void = { cond, message in precondition(cond, message) }

public func setAssertFunc(assertFunc: (Bool, String) -> Void) {
    _assertFunc = assertFunc
}

public func arrayValidator<T>(minItems minItems: Int? = nil, maxItems: Int? = nil, itemValidator: T -> Void) -> (Array<T>) -> Void {
    return { (value: Array<T>) -> Void in
        if let minItems = minItems {
            _assertFunc(value.count >= minItems, "\(value) must have at least \(minItems) items")
        }

        if let maxItems = maxItems {
            _assertFunc(value.count <= maxItems, "\(value) must have at most \(maxItems) items")
        }

        for el in value {
            itemValidator(el)
        }
    }
}

public func stringValidator(minLength minLength: Int? = nil, maxLength: Int? = nil, pattern: String? = nil) -> (String) -> Void {
    return { (value: String) -> Void in
        let length = value.characters.count
        if let minLength = minLength {
            _assertFunc(length >= minLength, "\"\(value)\" must be at least \(minLength) characters")
        }
        if let maxLength = maxLength {
            _assertFunc(length <= maxLength, "\"\(value)\" must be at most \(maxLength) characters")
        }

        if let pat = pattern {
            // patterns much match entire input sequence
            let re = try! NSRegularExpression(pattern: "\\A(?:\(pat))\\z", options: NSRegularExpressionOptions())
            let matches = re.matchesInString(value, options: NSMatchingOptions(), range: NSMakeRange(0, length))
            _assertFunc(matches.count > 0, "\"\(value) must match pattern \"\(re.pattern)\"")
        }
    }
}

public func comparableValidator<T: Comparable>(minValue minValue: T? = nil, maxValue: T? = nil) -> (T) -> Void {
    return { (value: T) -> Void in
        if let minValue = minValue {
            _assertFunc(minValue <= value, "\(value) must be at least \(minValue)")
        }

        if let maxValue = maxValue {
            _assertFunc(maxValue >= value, "\(value) must be at most \(maxValue)")
        }
    }
}

public func nullableValidator<T>(internalValidator: (T) -> Void) -> (T?) -> Void {
    return { (value: T?) -> Void in
        if let value = value {
            internalValidator(value)
        }
    }
}

public func binaryValidator(minLength minLength: Int?, maxLength: Int?) -> (NSData) -> Void {
    return { (value: NSData) -> Void in
        let length = value.length
        if let minLength = minLength {
            _assertFunc(length >= minLength, "\"\(value)\" must be at least \(minLength) bytes")
        }

        if let maxLength = maxLength {
            _assertFunc(length <= maxLength, "\"\(value)\" must be at most \(maxLength) bytes")
        }
    }
}
