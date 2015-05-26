import Foundation
import Alamofire

public class Box<T> {
	public let unboxed : T
	init (_ v : T) { self.unboxed = v }
}
public enum CallError<ErrorType> : Printable {
    case InternalServerError(Int, String?)
    case BadInputError(String?)
    case RateLimitError
    case HTTPError(Int?, String?)
    case RouteError(Box<ErrorType>)
    
    
    public var description : String {
        switch self {
        case .InternalServerError(let code, let message):
            var ret = "Internal Server Error \(code)"
            if let m = message {
                ret += ": \(m)"
            }
            return ret
        case .BadInputError(let message):
            var ret = "Bad Input"
            if let m = message {
                ret += ": \(m)"
            }
            return ret
        case .RateLimitError:
            return "Rate limited"
        case .HTTPError(let code, let message):
            var ret = "HTTP Error"
            if let c = code {
                ret += "\(c)"
            }
            if let m = message {
                ret += ": \(m)"
            }
            return ret
        case .RouteError(let box):
            return "API route error - handle programmatically"
        }
    }
}

func utf8Decode(data: NSData) -> String? {
    if let nsstring = NSString(data: data, encoding: NSUTF8StringEncoding) {
        return nsstring as String
    } else {
        return nil
    }
}


/// Represents a Babel request
///
/// These objects are constructed by the SDK; users of the SDK do not need to create them manually.
///
/// Pass in a closure to the `response` method to handle a response or error.
public class BabelRequest<RType : JSONSerializer, EType : JSONSerializer> {
    let errorSerializer : EType
    let responseSerializer : RType
    let request : Request
    
    init(client: BabelClient,
        host: String,
        route: String,
        responseSerializer: RType,
        errorSerializer: EType,
        requestEncoder: (URLRequestConvertible, [String: AnyObject]?) -> (NSURLRequest, NSError?)) {
            self.errorSerializer = errorSerializer
            self.responseSerializer = responseSerializer
            let url = "\(client.baseHosts[host]!)\(route)"
            self.request = client.manager.request(.POST, url, parameters: [:], encoding: .Custom(requestEncoder))
    }
    

    
    func handleResponseError(response: NSHTTPURLResponse?, data: NSData) -> CallError<EType.ValueType> {
        if let code = response?.statusCode {
            switch code {
            case 500...599:
                let message = utf8Decode(data)
                return .InternalServerError(code, message)
            case 400:
                let message = utf8Decode(data)
                return .BadInputError(message)
            case 429:
                 return .RateLimitError
            case 409:
                let json = parseJSON(data)
                switch json {
                case .Dictionary(let d):
                    return .RouteError(Box(self.errorSerializer.deserialize(d["reason"]!)))
                default:
                    assert(false, "Failed to parse error type")
                }

            default:
                return .HTTPError(code, "An error occurred.")
            }
        } else {
            let message = utf8Decode(data)
            return .HTTPError(nil, message)
        }
    }
}

/// An "rpc-style" request
public class BabelRpcRequest<RType : JSONSerializer, EType : JSONSerializer> : BabelRequest<RType, EType> {
    init(client: BabelClient, host: String, route: String, params: JSON, responseSerializer: RType, errorSerializer: EType) {
        super.init( client: client, host: host, route: route, responseSerializer: responseSerializer, errorSerializer: errorSerializer,
        requestEncoder: ({ convertible, _ in
            var mutableRequest = convertible.URLRequest.copy() as! NSMutableURLRequest
            mutableRequest.addValue("application/json", forHTTPHeaderField: "Content-Type")
            mutableRequest.HTTPBody = dumpJSON(params)
            return (mutableRequest, nil)
        }))
    }
    
    /// Called when a request completes.
    ///
    /// :param: completionHandler A closure which takes a (response, error) and handles the result of the call appropriately.
    public func response(completionHandler: (RType.ValueType?, CallError<EType.ValueType>?) -> Void) -> Self {
        self.request.validate().response {
            (request, response, dataObj, error) -> Void in
            let data = dataObj as! NSData
            if error != nil {
                completionHandler(nil, self.handleResponseError(response, data: data))
            } else {
                completionHandler(self.responseSerializer.deserialize(parseJSON(data)), nil)
            }
        }
        return self
    }
}

public class BabelUploadRequest<RType : JSONSerializer, EType : JSONSerializer> : BabelRequest<RType, EType> {
    init(client: BabelClient, host: String, route: String, params: JSON, body: NSData, responseSerializer: RType, errorSerializer: EType) {
        super.init( client: client, host: host, route: route, responseSerializer: responseSerializer, errorSerializer: errorSerializer,
        requestEncoder: ({ convertible, _ in
            var mutableRequest = convertible.URLRequest.copy() as! NSMutableURLRequest
            mutableRequest.addValue("application/octet-stream", forHTTPHeaderField: "Content-Type")
            mutableRequest.HTTPBody = body
            if let data = dumpJSON(params) {
                let value = utf8Decode(data)
                mutableRequest.addValue(value, forHTTPHeaderField: "Dropbox-Api-Arg")
            }
            
            return (mutableRequest, nil)
        }))
    }
    
    /// Called as the upload progresses. 
    ///
    /// :param: closure
    ///         a callback taking three arguments (`bytesWritten`, `totalBytesWritten`, `totalBytesExpectedToWrite`)
    /// :returns: The request, for chaining purposes
    public func progress(closure: ((Int64, Int64, Int64) -> Void)? = nil) -> Self {
        self.request.progress(closure: closure)
        return self
    }
    
    /// Called when a request completes.
    ///
    /// :param: completionHandler 
    ///         A callback taking two arguments (`response`, `error`) which handles the result of the call appropriately.
    /// :returns: The request, for chaining purposes.
    public func response(completionHandler: (RType.ValueType?, CallError<EType.ValueType>?) -> Void) -> Self {
        self.request.validate().response {
            (request, response, dataObj, error) -> Void in
            let data = dataObj as! NSData
            if error != nil {
                completionHandler(nil, self.handleResponseError(response, data: data))
            } else {
                completionHandler(self.responseSerializer.deserialize(parseJSON(data)), nil)
            }
        }
        return self
    }

}

public class BabelDownloadRequest<RType : JSONSerializer, EType : JSONSerializer> : BabelRequest<RType, EType> {
    init(client: BabelClient, host: String, route: String, params: JSON, responseSerializer: RType, errorSerializer: EType) {
        super.init( client: client, host: host, route: route, responseSerializer: responseSerializer, errorSerializer: errorSerializer,
        requestEncoder: ({ convertible, _ in
            var mutableRequest = convertible.URLRequest.copy() as! NSMutableURLRequest
            if let data = dumpJSON(params) {
                let value = utf8Decode(data)
                mutableRequest.addValue(value, forHTTPHeaderField: "Dropbox-Api-Arg")
            }
            
            return (mutableRequest, nil)
        }))
    }
    
    /// Called as the download progresses
    /// 
    /// :param: closure
    ///         a callback taking three arguments (`bytesRead`, `totalBytesRead`, `totalBytesExpectedToRead`)
    /// :returns: The request, for chaining purposes.
    public func progress(closure: ((Int64, Int64, Int64) -> Void)? = nil) -> Self {
        self.request.progress(closure: closure)
        return self
    }
    
    /// Called when a request completes.
    ///
    /// :param: completionHandler
    ///         A callback taking two arguments (`response`, `error`) which handles the result of the call appropriately.
    /// :returns: The request, for chaining purposes.
    public func response(completionHandler: ( (RType.ValueType, NSData)?, CallError<EType.ValueType>?) -> Void) -> Self {
        self.request.validate().response {
            (request, response, dataObj, error) -> Void in
            let data = dataObj as! NSData
            if error != nil {
                completionHandler(nil, self.handleResponseError(response, data: data))
            } else {
                let result = response!.allHeaderFields["Dropbox-Api-Result"] as! String
                let resultData = result.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)!
                let resultObject = self.responseSerializer.deserialize(parseJSON(resultData))
                
                completionHandler( (resultObject, data), nil)
            }
        }
        return self
    }
}

/// A dropbox API client
public class BabelClient {
    var baseHosts : [String : String]
    
    var manager : Manager
    

    
    public init(manager : Manager, baseHosts : [String : String]) {
        self.baseHosts = baseHosts
        self.manager = manager
    }
}

