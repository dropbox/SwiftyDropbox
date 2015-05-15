import Foundation

// The objects in this file are used by generated code and should not need to be invoked manually.

var _assertFunc: (Bool,String) -> Void = { cond, message in assert(cond, message) }

public func setAssertFunc( assertFunc: (Bool, String) -> Void) {
    _assertFunc = assertFunc
}


public func arrayValidator<T>(#minItems : Int?, #maxItems : Int?, #itemValidator: T -> Void)(value : Array<T>) -> Void {
    if let min = minItems {
        _assertFunc(value.count >= min, "\(value) must have at least \(min) items")
    }
    
    if let max = maxItems {
        _assertFunc(value.count <= max, "\(value) must have at most \(max) items")
    }
    
    for el in value {
        itemValidator(el)
    }
    
}

public func arrayValidator<T>(#itemValidator: T -> Void)(value : Array<T>) -> Void {
    arrayValidator(minItems: nil, maxItems: nil, itemValidator: itemValidator)(value: value)
}

public func stringValidator(minLength : Int? = nil, maxLength : Int? = nil, pattern: String? = nil)(value: String) -> Void {
    let length = count(value)
    if let min = minLength {
        _assertFunc(length >= min, "\"\(value)\" must be at least \(min) characters")
    }
    if let max = maxLength {
        _assertFunc(length <= max, "\"\(value)\" must be at most \(max) characters")
    }
    
    if let pat = pattern {
        let re = NSRegularExpression(pattern: pat, options: nil, error: nil)!
        let matches = re.matchesInString(value, options: nil, range: NSMakeRange(0, length))
        _assertFunc(matches.count > 0, "\"\(value) must match pattern \"\(re.pattern)\"")
    }
}

public func comparableValidator<T: Comparable>(minValue : T? = nil, maxValue : T? = nil)(value: T) -> Void {
    if let min = minValue {
        _assertFunc(min <= value, "\(value) must be at least \(min)")
    }
    
    if let max = maxValue {
        _assertFunc(max >= value, "\(value) must be at most \(max)")
    }
}

public func nullableValidator<T>(internalValidator : (T) -> Void)(value : T?) -> Void {
    if let v = value {
        internalValidator(v)
    }
}

public func binaryValidator(#minLength : Int?, #maxLength: Int?)(value: NSData) -> Void {
    let length = value.length
    if let min = minLength {
        _assertFunc(length >= min, "\"\(value)\" must be at least \(min) bytes")
    }
    if let max = maxLength {
        _assertFunc(length <= max, "\"\(value)\" must be at most \(max) bytes")
    }
}