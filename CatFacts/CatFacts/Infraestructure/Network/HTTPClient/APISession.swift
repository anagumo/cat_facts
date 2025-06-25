import Foundation

protocol APISessionContract {
    func request<URLRequest: URLRequestComponents>(_ request: URLRequest) async throws -> URLRequest.Response
}

final class APISession: APISessionContract {
    static let shared = APISession()
    private let urlSession: URLSession
    
    init(urlSession: URLSession = URLSessionService.shared) {
        self.urlSession = urlSession
    }
    
    func request<URLRequest: URLRequestComponents>(_ request: URLRequest) async throws -> URLRequest.Response {
        let urlRequest = try URLRequestBuilder(urlRequestComponents: request).build()
        
        let (data, response) = try await urlSession.data(for: urlRequest)
        let statusCode = (response as? HTTPURLResponse)?.statusCode
        
        guard let statusCode else {
            throw URLError(.badServerResponse)
        }
        
        switch statusCode {
        case 200..<300:
            do {
                return try JSONDecoder().decode(URLRequest.Response.self, from: data)
            } catch {
                throw URLError(.cannotDecodeContentData)
            }
        default:
            throw URLError(.badServerResponse)
        }
    }
}
