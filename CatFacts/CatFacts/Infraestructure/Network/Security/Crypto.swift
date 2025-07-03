import Foundation
import CryptoKit

/// Enum to define the size of the key to be used in AES encryption.
/// - bits128: 16 bytes long key.
/// - bits192: 24 bytes long key.
/// - bits256: 32 bytes long key.
enum AESKeySize: Int {
    case bits128 = 16
    case bits192 = 24
    case bits256 = 32
}

public class Crypto {
    // MARK: - Properties
    private let sealedDataBox = "+C7P6ueLeX7IhrKPQs+7TW921jtgSW0jlQmqF+cdBTsGWJxyb9oZiWWJcT94SH/vomb0XIG/d5aS2zK4I9EKR9NpvgNFhsDU"
    private var privateKey: String
    
    init() {
        let obfuscatedPrivateKey: [UInt8] = [
            0x16+0x55,0x49+0x1C,0x76+0x03,0x5B-0x07,0x32+0x3D,0x6C-0x27,0x28+0x46,0x3B+0x28,0x6A+0x08,0x79-0x00,0x84-0x14,0xD5-0x61,0x56-0x12,0x3B+0x26,0xD6-0x62,0xBE-0x5D
        ]
        
        guard let privateKey = String(data: Data(obfuscatedPrivateKey), encoding: .utf8) else  {
            debugPrint("SSLPinningError: Unable to decrypt the security key")
            self.privateKey = ""
            return
        }
        
        self.privateKey = privateKey
    }
    
    // MARK: - Methods
    /// Pads a given key to be used in AES encryption with 32 bytes long by default. It uses the PKCS7 standard padding.
    ///  - Parameters:
    ///  - key: The key to be padded.
    ///  - size: The size of the key to be padded. Default is 32 bytes.
    ///  - Returns: The padded key.
    private func paddedKey_PKCS7(from key: String, withSize size: AESKeySize = .bits256) -> Data {
        // Get the data from the key in Bytes
        guard let keyData = key.data(using: .utf8) else { return Data() }
        // If the key is already the right size, return it
        if(keyData.count == size.rawValue) {return keyData}
        // If the key is bigger, truncate it and return it
        if(keyData.count > size.rawValue) {return keyData.prefix(size.rawValue)}
        // If the key is smaller, pad it
        let paddingSize = size.rawValue - keyData.count % size.rawValue
        let paddingByte: UInt8 = UInt8(paddingSize)
        let padding = Data(repeating: paddingByte, count: paddingSize)
        return keyData + padding
    }
    
    /// Decrypts a given data input using AES algorithm.
    /// Given the symmetric nature of the AES encryption, the key used for encryption has to be used for decryption.
    /// - Parameters:
    /// - input: The data to be decrypted.
    /// - key: The key to be used for decryption. If the key is 32 bytes long, it will be used directly. If the key is shorter than 32 bytes, it will be padded.
    private func decrypt(input: Data, key: String) -> Data {
        do {
            // Get the correct length key
            let keyData = paddedKey_PKCS7(from: key, withSize: .bits128)
            // Get the symmetric key from the key as a string
            let key = SymmetricKey(data: keyData)
            // Get box from the input, if the data is not a box then throw an error
            let box = try AES.GCM.SealedBox(combined: input)
            // Get the plaintext. If any error occurs during the opening process then throw exception
            let opened = try AES.GCM.open(box, using: key)
            // Return the cipher text
            return opened
        } catch {
            return "Error while decryption".data(using: .utf8)!
        }
    }
    
    public func getDecryptedPublicKey () -> String? {
        guard let sealedDataBoxData = Data(base64Encoded: sealedDataBox) else {
            print("Error while decrypting the public key: sealed box is not valid")
            return nil
        }
        let data = decrypt(input: sealedDataBoxData, key: privateKey)
        return String(data: data, encoding: .utf8)
    }
}
