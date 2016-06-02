import Foundation
import Alamofire

public class DropboxTransportClient {
    static let version = "3.1.0"
    
    static let manager: Manager = {
        let manager = Manager(serverTrustPolicyManager: DropboxServerTrustPolicyManager())
        manager.startRequestsImmediately = false
        return manager
    }()
    static let backgroundManager: Manager = {
        let backgroundConfig = NSURLSessionConfiguration.backgroundSessionConfigurationWithIdentifier("com.dropbox.SwiftyDropbox")
        let backgroundManager = Manager(configuration: backgroundConfig, serverTrustPolicyManager: DropboxServerTrustPolicyManager())
        backgroundManager.startRequestsImmediately = false
        return backgroundManager
    }()

    var accessToken: DropboxAccessToken
    var selectUser: String?
    var baseHosts: [String: String]
    var userAgent: String

    func additionalHeaders(noauth: Bool) -> [String: String] {
        var headers = ["User-Agent": self.userAgent]
        if self.selectUser != nil {
            headers["Dropbox-Api-Select-User"] = self.selectUser
        }
        if (!noauth) {
            headers["Authorization"] = "Bearer \(self.accessToken)"
        }
        return headers
    }
    
    public convenience init(accessToken: DropboxAccessToken, selectUser: String? = nil) {
        let defaultBaseHosts = [
            "api": "https://api.dropbox.com/2",
            "content": "https://api-content.dropbox.com/2",
            "notify": "https://notify.dropboxapi.com/2",
            ]
        
        let defaultUserAgent = "OfficialDropboxSwiftSDKv2/\(DropboxTransportClient.version)"

        self.init(accessToken: accessToken, selectUser: selectUser, baseHosts: defaultBaseHosts, userAgent: defaultUserAgent)
    }
    
    public init(accessToken: DropboxAccessToken, selectUser: String?, baseHosts: [String: String], userAgent: String) {
        self.accessToken = accessToken
        self.selectUser = selectUser
        self.baseHosts = baseHosts
        self.userAgent = userAgent
    }

    public func request<ASerial: JSONSerializer, RSerial: JSONSerializer, ESerial: JSONSerializer>(route: Route<ASerial, RSerial, ESerial>,
                        serverArgs: ASerial.ValueType? = nil) -> RpcRequest<RSerial, ESerial> {
        let host = route.attrs["host"]! ?? "api"
        let url = "\(self.baseHosts[host]!)/\(route.namespace)/\(route.name)"
        let routeStyle: RouteStyle = RouteStyle(rawValue: route.attrs["style"]!!)!
        
        var rawJsonRequest: NSData?
        rawJsonRequest = nil

        if let serverArgs = serverArgs {
            let jsonRequestObj = route.argSerializer.serialize(serverArgs)
            rawJsonRequest = SerializeUtil.dumpJSON(jsonRequestObj)
        } else {
            let voidSerializer = route.argSerializer as! VoidSerializer
            let jsonRequestObj = voidSerializer.serialize()
            rawJsonRequest = SerializeUtil.dumpJSON(jsonRequestObj)
        }

        let headers = getHeaders(routeStyle, jsonRequest: rawJsonRequest, host: host)

        let encoding = ParameterEncoding.Custom { convertible, _ in
            let mutableRequest = convertible.URLRequest.copy() as! NSMutableURLRequest
            mutableRequest.HTTPBody = rawJsonRequest
            return (mutableRequest, nil)
        }

        let request = DropboxTransportClient.backgroundManager.request(.POST, url, parameters: [:], headers: headers, encoding: encoding)
        let rpcRequestObj = RpcRequest(request: request, responseSerializer: route.responseSerializer, errorSerializer: route.errorSerializer)
        
        request.resume()
            
        return rpcRequestObj
    }

    public func request<ASerial: JSONSerializer, RSerial: JSONSerializer, ESerial: JSONSerializer>(route: Route<ASerial, RSerial, ESerial>,
                        serverArgs: ASerial.ValueType, input: UploadBody) -> UploadRequest<RSerial, ESerial> {
        let host = route.attrs["host"]! ?? "api"
        let url = "\(self.baseHosts[host]!)/\(route.namespace)/\(route.name)"
        let routeStyle: RouteStyle = RouteStyle(rawValue: route.attrs["style"]!!)!
        
        let jsonRequestObj = route.argSerializer.serialize(serverArgs)
        let rawJsonRequest = SerializeUtil.dumpJSON(jsonRequestObj)
        
        let headers = getHeaders(routeStyle, jsonRequest: rawJsonRequest, host: host)
        
        let request: Alamofire.Request

        switch input {
        case let .Data(data):
            request = DropboxTransportClient.manager.upload(.POST, url, headers: headers, data: data)
        case let .File(file):
            request = DropboxTransportClient.backgroundManager.upload(.POST, url, headers: headers, file: file)
        case let .Stream(stream):
            request = DropboxTransportClient.manager.upload(.POST, url, headers: headers, stream: stream)
        }
        let uploadRequestObj = UploadRequest(request: request, responseSerializer: route.responseSerializer, errorSerializer: route.errorSerializer)
        request.resume()
        
        return uploadRequestObj
    }

    public func request<ASerial: JSONSerializer, RSerial: JSONSerializer, ESerial: JSONSerializer>(route: Route<ASerial, RSerial, ESerial>,
                        serverArgs: ASerial.ValueType, overwrite: Bool, destination: (NSURL, NSHTTPURLResponse) -> NSURL) -> DownloadRequestFile<RSerial, ESerial> {
        let host = route.attrs["host"]! ?? "api"
        let url = "\(self.baseHosts[host]!)/\(route.namespace)/\(route.name)"
        let routeStyle: RouteStyle = RouteStyle(rawValue: route.attrs["style"]!!)!
        
        let jsonRequestObj = route.argSerializer.serialize(serverArgs)
        let rawJsonRequest = SerializeUtil.dumpJSON(jsonRequestObj)
        
        let headers = getHeaders(routeStyle, jsonRequest: rawJsonRequest, host: host)

        weak var _self: DownloadRequestFile<RSerial, ESerial>!
        
        let dest: (NSURL, NSHTTPURLResponse) -> NSURL = { url, resp in
            var finalUrl = destination(url, resp)
            
            if 200 ... 299 ~= resp.statusCode {
                if NSFileManager.defaultManager().fileExistsAtPath(finalUrl.path!) {
                    if overwrite {
                        do {
                            try NSFileManager.defaultManager().removeItemAtURL(finalUrl)
                        } catch let error as NSError {
                            print("Error: \(error)")
                        }
                    } else {
                        print("Error: File already exists at \(finalUrl.path!)")
                    }
                }
            }
            else {
                _self.errorMessage = NSData(contentsOfURL: url)!
                // Alamofire will "move" the file to the temporary location where it already resides,
                // and where it will soon be automatically deleted
                finalUrl = url
            }
            
            _self.urlPath = finalUrl
            
            return finalUrl
        }
        
        let request = DropboxTransportClient.backgroundManager.download(.POST, url, headers: headers, destination: dest)

        let downloadRequestObj = DownloadRequestFile(request: request, responseSerializer: route.responseSerializer, errorSerializer: route.errorSerializer)
        _self = downloadRequestObj
        
        request.resume()
        
        return downloadRequestObj
    }

    public func request<ASerial: JSONSerializer, RSerial: JSONSerializer, ESerial: JSONSerializer>(route: Route<ASerial, RSerial, ESerial>,
                        serverArgs: ASerial.ValueType) -> DownloadRequestMemory<RSerial, ESerial> {
        let host = route.attrs["host"]! ?? "api"
        let url = "\(self.baseHosts[host]!)/\(route.namespace)/\(route.name)"
        let routeStyle: RouteStyle = RouteStyle(rawValue: route.attrs["style"]!!)!

        let jsonRequestObj = route.argSerializer.serialize(serverArgs)
        let rawJsonRequest = SerializeUtil.dumpJSON(jsonRequestObj)

        let headers = getHeaders(routeStyle, jsonRequest: rawJsonRequest, host: host)

        let request = DropboxTransportClient.backgroundManager.request(.POST, url, headers: headers)

        let downloadRequestObj = DownloadRequestMemory(request: request, responseSerializer: route.responseSerializer, errorSerializer: route.errorSerializer)

        request.resume()

        return downloadRequestObj
    }

    private func getHeaders(routeStyle: RouteStyle, jsonRequest: NSData?, host: String) -> [String: String] {
        var headers = [String: String]()
        let noauth = (host == "notify")
        
        for (header, val) in self.additionalHeaders(noauth) {
            headers[header] = val
        }
        
        if (routeStyle == RouteStyle.Rpc) {
            headers["Content-Type"] = "application/json"
        } else if (routeStyle == RouteStyle.Upload) {
            headers["Content-Type"] = "application/octet-stream"
            if let jsonRequest = jsonRequest {
                let value = asciiEscape(utf8Decode(jsonRequest))
                headers["Dropbox-Api-Arg"] = value
            }
        } else if (routeStyle == RouteStyle.Download) {
            if let jsonRequest = jsonRequest {
                let value = asciiEscape(utf8Decode(jsonRequest))
                headers["Dropbox-Api-Arg"] = value
            }
        }
        return headers
    }
}

public class Box<T> {
    public let unboxed: T
    init (_ v: T) { self.unboxed = v }
}

public enum CallError<EType>: CustomStringConvertible {
    case InternalServerError(Int, String?, String?)
    case BadInputError(String?, String?)
    case RateLimitError
    case HTTPError(Int?, String?, String?)
    case RouteError(Box<EType>, String?)
    case OSError(ErrorType?)
    
    public var description: String {
        switch self {
        case let .InternalServerError(code, message, requestId):
            var ret = ""
            if let r = requestId {
                ret += "[request-id \(r)] "
            }
            ret += "Internal Server Error \(code)"
            if let m = message {
                ret += ": \(m)"
            }
            return ret
        case let .BadInputError(message, requestId):
            var ret = ""
            if let r = requestId {
                ret += "[request-id \(r)] "
            }
            ret += "Bad Input"
            if let m = message {
                ret += ": \(m)"
            }
            return ret
        case .RateLimitError:
            return "Rate limited"
        case let .HTTPError(code, message, requestId):
            var ret = ""
            if let r = requestId {
                ret += "[request-id \(r)] "
            }
            ret += "HTTP Error"
            if let c = code {
                ret += "\(c)"
            }
            if let m = message {
                ret += ": \(m)"
            }
            return ret
        case let .RouteError(box, requestId):
            var ret = ""
            if let r = requestId {
                ret += "[request-id \(r)] "
            }
            ret += "API route error - \(box.unboxed)"
            return ret
        case let .OSError(err):
            if let e = err {
                return "\(e)"
            }
            return "An unknown system error"
        }
    }
}

func utf8Decode(data: NSData) -> String {
    return NSString(data: data, encoding: NSUTF8StringEncoding)! as String
}

func asciiEscape(s: String) -> String {
    var out: String = ""
    
    for char in s.unicodeScalars {
        var esc = "\(char)"
        if !char.isASCII() {
            esc = NSString(format:"\\u%04x", char.value) as String
        } else {
            esc = "\(char)"
        }
        out += esc
        
    }
    return out
}

public enum RouteStyle: String {
    case Rpc = "rpc"
    case Upload = "upload"
    case Download = "download"
    case Other
}

public enum UploadBody {
    case Data(NSData)
    case File(NSURL)
    case Stream(NSInputStream)
}

/// These objects are constructed by the SDK; users of the SDK do not need to create them manually.
///
/// Pass in a closure to the `response` method to handle a response or error.
public class Request<RSerial: JSONSerializer, ESerial: JSONSerializer> {
    let request: Alamofire.Request
    let responseSerializer: RSerial
    let errorSerializer: ESerial
    
    init(request: Alamofire.Request, responseSerializer: RSerial, errorSerializer: ESerial) {
        self.errorSerializer = errorSerializer
        self.responseSerializer = responseSerializer
        self.request = request
    }
    
    public func progress(closure: ((Int64, Int64, Int64) -> Void)? = nil) -> Self {
        self.request.progress(closure)
        return self
    }
    
    public func cancel() {
        self.request.cancel()
    }
    
    func handleResponseError(response: NSHTTPURLResponse?, data: NSData?, error: ErrorType?) -> CallError<ESerial.ValueType> {
        let requestId = response?.allHeaderFields["X-Dropbox-Request-Id"] as? String
        if let code = response?.statusCode {
            switch code {
            case 500...599:
                var message = ""
                if let d = data {
                    message = utf8Decode(d)
                }
                return .InternalServerError(code, message, requestId)
            case 400:
                var message = ""
                if let d = data {
                    message = utf8Decode(d)
                }
                return .BadInputError(message, requestId)
            case 429:
                 return .RateLimitError
            case 403, 404, 409:
                let json = SerializeUtil.parseJSON(data!)
                switch json {
                case .Dictionary(let d):
                    return .RouteError(Box(self.errorSerializer.deserialize(d["error"]!)), requestId)
                default:
                    fatalError("Failed to parse error type")
                }
            case 200:
                return .OSError(error)
            default:
                return .HTTPError(code, "An error occurred.", requestId)
            }
        } else {
            var message = ""
            if let d = data {
                message = utf8Decode(d)
            }
            return .HTTPError(nil, message, requestId)
        }
    }
}

/// An "rpc-style" request
public class RpcRequest<RSerial: JSONSerializer, ESerial: JSONSerializer>: Request<RSerial, ESerial> {
    public override init(request: Alamofire.Request, responseSerializer: RSerial, errorSerializer: ESerial) {
        super.init(request: request, responseSerializer: responseSerializer, errorSerializer: errorSerializer)
    }

    public func response(completionHandler: (RSerial.ValueType?, CallError<ESerial.ValueType>?) -> Void) -> Self {
        self.request.validate().response {
            (request, response, dataObj, error) -> Void in
            let data = dataObj!
            if error != nil {
                completionHandler(nil, self.handleResponseError(response, data: data, error: error))
            } else {
                completionHandler(self.responseSerializer.deserialize(SerializeUtil.parseJSON(data)), nil)
            }
        }
        return self
    }
}

/// An "upload-style" request
public class UploadRequest<RSerial: JSONSerializer, ESerial: JSONSerializer>: Request<RSerial, ESerial> {
    public override init(request: Alamofire.Request, responseSerializer: RSerial, errorSerializer: ESerial) {
        super.init(request: request, responseSerializer: responseSerializer, errorSerializer: errorSerializer)
    }

    public func response(completionHandler: (RSerial.ValueType?, CallError<ESerial.ValueType>?) -> Void) -> Self {
        self.request.validate().response {
            (request, response, dataObj, error) -> Void in
            let data = dataObj!
            if error != nil {
                completionHandler(nil, self.handleResponseError(response, data: data, error: error))
            } else {
                completionHandler(self.responseSerializer.deserialize(SerializeUtil.parseJSON(data)), nil)
            }
        }
        return self
    }
}


/// A "download-style" request to a file
public class DownloadRequestFile<RSerial: JSONSerializer, ESerial: JSONSerializer>: Request<RSerial, ESerial> {
    public var urlPath: NSURL?
    public var errorMessage: NSData

    public override init(request: Alamofire.Request, responseSerializer: RSerial, errorSerializer: ESerial) {
        urlPath = nil
        errorMessage = NSData()
        super.init(request: request, responseSerializer: responseSerializer, errorSerializer: errorSerializer)
    }

    public func response(completionHandler: ((RSerial.ValueType, NSURL)?, CallError<ESerial.ValueType>?) -> Void) -> Self {
        self.request.validate()
            .response {
            (request, response, data, error) -> Void in
            if error != nil {
                completionHandler(nil, self.handleResponseError(response, data: self.errorMessage, error: error))
            } else {
                let result = response!.allHeaderFields["Dropbox-Api-Result"] as! String
                let resultData = result.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)!
                let resultObject = self.responseSerializer.deserialize(SerializeUtil.parseJSON(resultData))
                
                completionHandler((resultObject, self.urlPath!), nil)
            }
        }
        return self
    }
}

/// A "download-style" request to memory
public class DownloadRequestMemory<RSerial: JSONSerializer, ESerial: JSONSerializer>: Request<RSerial, ESerial> {
    public override init(request: Alamofire.Request, responseSerializer: RSerial, errorSerializer: ESerial) {
        super.init(request: request, responseSerializer: responseSerializer, errorSerializer: errorSerializer)
    }

    public func response(completionHandler: ((RSerial.ValueType, NSData)?, CallError<ESerial.ValueType>?) -> Void) -> Self {
        self.request.validate()
            .response {
                (request, response, data, error) -> Void in
                if error != nil {
                    completionHandler(nil, self.handleResponseError(response, data: data, error: error))
                } else {
                    let result = response!.allHeaderFields["Dropbox-Api-Result"] as! String
                    let resultData = result.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)!
                    let resultObject = self.responseSerializer.deserialize(SerializeUtil.parseJSON(resultData))

                    completionHandler((resultObject, data!), nil)
                }
        }
        return self
    }
}
