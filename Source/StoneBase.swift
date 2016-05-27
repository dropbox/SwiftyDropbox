import Foundation

// The objects in this file are used by generated code and should not need to be invoked manually.

public class Route {
    public let name: String
    public let namespace: String
    public let deprecated: Bool
    public let attrs: [String: String?]

    public init(name: String, namespace: String, deprecated: Bool, attrs: [String: String?]) {
        self.name = name
        self.namespace = namespace
        self.deprecated = deprecated
        self.attrs = attrs
    }
}
