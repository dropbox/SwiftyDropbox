import Foundation
import Alamofire

// Dropbox API errors
public let DropboxErrorDomain = "com.dropbox.error"

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


/// Represents a Dropbox API request
///
/// These objects are constructed by the SDK; users of the SDK do not need to create them manually.
///
/// Pass in a closure to the `response` method to handle a response or error.
public class DropboxRequest<RType : JSONSerializer, EType : JSONSerializer> {
    let errorSerializer : EType
    let responseSerializer : RType
    let request : Request
    
    init(client: DropboxClient,
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
public class DropboxRpcRequest<RType : JSONSerializer, EType : JSONSerializer> : DropboxRequest<RType, EType> {
    init(client: DropboxClient, host: String, route: String, params: JSON, responseSerializer: RType, errorSerializer: EType) {
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

public class DropboxUploadRequest<RType : JSONSerializer, EType : JSONSerializer> : DropboxRequest<RType, EType> {
    init(client: DropboxClient, host: String, route: String, params: JSON, body: NSData, responseSerializer: RType, errorSerializer: EType) {
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

public class DropboxDownloadRequest<RType : JSONSerializer, EType : JSONSerializer> : DropboxRequest<RType, EType> {
    init(client: DropboxClient, host: String, route: String, params: JSON, responseSerializer: RType, errorSerializer: EType) {
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
public class DropboxClient {
    var accessToken: DropboxAccessToken
    var baseHosts : [String : String]
    
    public static var sharedClient : DropboxClient!
    
    var manager : Manager
    
    public init(accessToken: DropboxAccessToken, baseApiUrl: String, baseContentUrl: String, baseNotifyUrl: String) {
        self.accessToken = accessToken
        self.baseHosts = [
            "meta" : baseApiUrl,
            "content": baseContentUrl,
            "notify": baseNotifyUrl,
        ]
        
        // Authentication header with access token
        
        let configuration = NSURLSessionConfiguration.defaultSessionConfiguration()
        
        configuration.HTTPAdditionalHeaders = [
            "Authorization" : "Bearer \(accessToken)",
        ]
        
        self.manager = Manager(configuration: configuration)

    }
    
    public convenience init(accessToken: DropboxAccessToken) {
        self.init(accessToken: accessToken,
            baseApiUrl: "https://api.dropbox.com/2-beta",
            baseContentUrl: "https://api-content.dropbox.com/2-beta",
            baseNotifyUrl: "https://api-notify.dropbox.com")
    }
    
    /// Invoke an RPC request. Users of the SDK should not need to call this manually.
    ///
    /// :param: host
    ///         The host to call
    /// :param: route
    ///         The route to call
    /// :param: params
    ///         The already-serialized parameter object
    /// :param: responseSerializer
    ///         The response serializer
    /// :param: errorSerializer
    ///         The error serializer
    /// :returns: A Dropbox RPC request
    func runRpcRequest<RType: JSONSerializer, EType: JSONSerializer>(#host: String, route: String, params: JSON,responseSerializer: RType, errorSerializer: EType) -> DropboxRpcRequest<RType, EType> {
        return DropboxRpcRequest(client: self, host: host, route: route, params: params, responseSerializer: responseSerializer, errorSerializer: errorSerializer)
    }
    
    /// Invoke an Upload request. Users of the SDK should not need to call this manually.
    ///
    /// :param: host
    ///         The host to call
    /// :param: route
    ///         The route to call
    /// :param: params
    ///         The already-serialized parameter object
    /// :param: responseSerializer
    ///         The response serializer
    /// :param: errorSerializer
    ///         The error serializer
    /// :returns: A Dropbox upload request
    func runUploadRequest<RType: JSONSerializer, EType: JSONSerializer>(#host: String, route: String, params: JSON, body: NSData, responseSerializer: RType, errorSerializer: EType) -> DropboxUploadRequest<RType, EType> {
        return DropboxUploadRequest(client: self, host: host, route: route, params: params, body: body, responseSerializer: responseSerializer, errorSerializer: errorSerializer)
    }
    
    /// Invoke a Download request. Users of the SDK should not need to call this manually.
    ///
    /// :param: host
    ///         The host to call
    /// :param: route
    ///         The route to call
    /// :param: params
    ///         The already-serialized parameter object
    /// :param: responseSerializer
    ///         The response serializer
    /// :param: errorSerializer
    ///         The error serializer
    /// :returns: A Dropbox RPC request
    func runDownloadRequest<RType: JSONSerializer, EType: JSONSerializer>(#host: String, route: String, params: JSON,responseSerializer: RType, errorSerializer: EType) -> DropboxDownloadRequest<RType, EType> {
        return DropboxDownloadRequest(client: self, host: host, route: route, params: params, responseSerializer: responseSerializer, errorSerializer: errorSerializer)
    }
}





