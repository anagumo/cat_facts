import Foundation
import CryptoKit

/// Implementation of a Secure Sokets Layer (TLS) to protect the communication of the app with the server to avoid MITM or interceptions.
final class SSLPinningService: NSObject, URLSessionDelegate {
    // Local security key pinned
    private var localSecKey: String = ""
    
    // MARK: Lifecycle
    override init() {
        let obfuscatedSecKey: [UInt8] = [0x4D-0x0C,0x4E-0x1B,0x63-0x2F,0x12+0x30,0x3E+0x0C,0x14+0x3C,0x2C+0x06,0x0A+0x21,0xD8-0x67,0x4A+0x0B,0x3E-0x09,0x4E+0x28,0xBA-0x53,0x4C+0x2A,0x3D-0x0A,0x4F+0x04,0x41+0x36,0x5F-0x16,0x1D+0x53,0x5D-0x14,0x47-0x06,0x12+0x3F,0x94-0x42,0x86-0x3D,0x38+0x0D,0x47+0x20,0x27+0x42,0x38+0x18,0x3B+0x11,0x47+0x0C,0x21+0x2E,0x11+0x3A,0x67-0x20,0x06+0x53,0x30+0x07,0x71-0x26,0x20+0x29,0x98-0x43,0x50-0x20,0x54+0x13,0x96-0x21,0x15+0x59,0x02+0x47,0x07+0x36]
        
        guard let localSecKey = String(data: Data(obfuscatedSecKey), encoding: .utf8) else {
            debugPrint("SSLPinningError: Unable to unwrap the security key")
            return
        }
        
        self.localSecKey = localSecKey
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
        if secKeySHA256 == localSecKey {
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
