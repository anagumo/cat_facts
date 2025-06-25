import Foundation

final class URLSessionService {
    private let session: URLSession
    static var shared: URLSession {
        URLSessionService().session
    }
    
    init() {
        session = URLSession(
            configuration: .ephemeral, // No storage for caches, cookies or credentials.
            delegate: SSLPinningService(), // Session delegate that handles the connection with the server
            delegateQueue: nil
        )
    }
}
