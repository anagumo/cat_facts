import Foundation
import CryptoKit

/// Implementation of a Secure Sokets Layer (TLS) to protect the communication of the app with the server to avoid MITM or interceptions.
final class SSLPinningService: NSObject, URLSessionDelegate {
    private let crypto: Crypto
    
    // MARK: Lifecycle
    override init() {
        crypto = Crypto()
    }
    
    // Intercept server connection to evaluate the server trust
    func urlSession(_ session: URLSession, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        
        // Get the security trust and certificate
        guard let secTrust = challenge.protectionSpace.serverTrust,
              let secCertificate = (SecTrustCopyCertificateChain(secTrust) as? [SecCertificate])?.first
        else {
            debugPrint("SSLPinning Error: Server is not trust")
            completionHandler(.cancelAuthenticationChallenge, nil)
            return
        }
        
        // Create a data representation of the security key
        let secKeyData = SecCertificateCopyData(secCertificate) as Data
        
        // Create a SHA256 representation of the security key data
        let secKeySHA256 = sha256(data: secKeyData)
        
        // Evaluate if security keys match
        if secKeySHA256 == crypto.getDecryptedPublicKey() {
            debugPrint("SSLPinnning Success: Security Keys match")
            completionHandler(.useCredential, URLCredential(trust: secTrust))
        } else {
            debugPrint("SSLPinning Error: Security keys does not match")
            completionHandler(.cancelAuthenticationChallenge, nil)
        }
    }
}

extension SSLPinningService {
    /// Create a SHA256 representation of the data passed as parameter (crypto kit)
    /// - Parameter data: The data that will be converted to SHA256.
    /// - Returns: The SHA256 representation of data.
    private func sha256(data: Data) -> String {
        let hash = SHA256.hash(data: data)
        return Data(hash).base64EncodedString()
    }
}
