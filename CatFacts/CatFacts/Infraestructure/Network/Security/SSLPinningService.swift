import Foundation
import CryptoKit

/// Implementation of a Secure Sokets Layer (TLS) to protect the communication of the app with the server to avoid MITM or interceptions.
final class SSLPinningService: NSObject, URLSessionDelegate {
    private let crypto: Crypto
    private let certificatePinning: Bool
    
    // MARK: Lifecycle
    override init() {
        crypto = Crypto()
        certificatePinning = true
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
        
        if certificatePinning {
            // Create an array of SSL policies
            let policies = NSMutableArray()
            let secPolicy = SecPolicyCreateSSL(true, "catfact.ninja" as CFString)
            policies.add(secPolicy)
            // Set SSL policies for a security certificate evaluation
            SecTrustSetPolicies(secTrust, policies)
            // Evaluate if the security server match with the previous policy set
            let isSecTrust = SecTrustEvaluateWithError(secTrust, nil)
            
            // Create a data representation of the remote security certificate
            let remoteSecCertificate: NSData = SecCertificateCopyData(secCertificate)
            // Get a representation of the local security certificate
            guard let localSecCertificatePath = Bundle.main.path(forResource: "catfact.ninja", ofType: "cer"),
                  let localSecCertificate = NSData(contentsOfFile: localSecCertificatePath) else {
                debugPrint("SSLPinnning Error: Local security certificate not found")
                completionHandler(.cancelAuthenticationChallenge, nil)
                return
            }
            
            if isSecTrust && remoteSecCertificate.isEqual(to: localSecCertificate as Data) {
                debugPrint("SSLPinnning Success: Security certificates match")
                completionHandler(.useCredential, URLCredential(trust: secTrust))
            } else {
                debugPrint("SSLPinning Error: Security certificates does not match")
                completionHandler(.cancelAuthenticationChallenge, nil)
            }
        } else {
            // Create a data representation of the security key
            let secKeyData = SecCertificateCopyData(secCertificate) as Data
            
            // Create a SHA256 representation of the security key data
            let secKeySHA256 = sha256(data: secKeyData)
            
            // Evaluate if security keys match
            if secKeySHA256 == crypto.getDecryptedPublicKey() {
                debugPrint("SSLPinnning Success: Security keys match")
                completionHandler(.useCredential, URLCredential(trust: secTrust))
            } else {
                debugPrint("SSLPinning Error: Security keys does not match")
                completionHandler(.cancelAuthenticationChallenge, nil)
            }
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
