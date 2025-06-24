import Foundation

final class URLRequestBuilder {
    private let urlRequestComponents: any URLRequestComponents
    
    init(urlRequestComponents: any URLRequestComponents) {
        self.urlRequestComponents = urlRequestComponents
    }
    
    private func url() throws -> URL {
        var urlComponents: URLComponents = URLComponents()
        urlComponents.scheme = "https"
        urlComponents.host = urlRequestComponents.host
        urlComponents.path = urlRequestComponents.path
        
        if let queryParameters = urlRequestComponents.queryParameters {
            urlComponents.queryItems = queryParameters.map {
                URLQueryItem(name: $0.key, value: $0.value)
            }
        }
        
        guard let url = urlComponents.url else {
            throw URLError(.badURL)
        }
        
        return url
    }
    
    func build() throws -> URLRequest {
        do {
            var urlRequest = try URLRequest(url: url())
            urlRequest.httpMethod = urlRequestComponents.httpMethod.rawValue
            urlRequest.allHTTPHeaderFields = [
                "Content-Type": "application/json",
                "Accept": "application/json"
            ].merging(urlRequestComponents.headers) { $1 }
            
            if let body = urlRequestComponents.body {
                urlRequest.httpBody = try JSONEncoder().encode(body)
            }
            
            return urlRequest
        } catch {
            throw URLError(.badURL)
        }
    }
}
