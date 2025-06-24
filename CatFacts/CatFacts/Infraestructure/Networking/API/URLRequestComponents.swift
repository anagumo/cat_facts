import Foundation

protocol URLRequestComponents {
    // for URL components
    var host: String { get }
    var path: String { get }
    var queryParameters: [String: String]? { get }
    // for URL request
    var httpMethod: HTTPMethod { get }
    var headers: [String:String] { get }
    var body: Encodable? { get }
    // for HTTP response
    associatedtype Response: Decodable // The expected type is defined by the type that conforms this protocol
}

// MARK: - Default values for HTTP Request Components
extension URLRequestComponents {
    var host: String { "catfact.ninja" }
    var queryParameters: [String : String]? { [:] }
    var headers: [String : String] { [:] }
    var body: Encodable? { nil }
}
