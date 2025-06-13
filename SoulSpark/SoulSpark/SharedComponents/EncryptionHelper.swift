import Foundation
import CryptoKit

// A helper class to encrypt and decrypt text using AES-GCM
class EncryptionHelper {
    
    // 🔐 Symmetric key for encryption/decryption (256-bit)
    // ⚠️ In real apps, store this key securely (e.g. Keychain or derived from password)
    static let key: SymmetricKey = KeychainHelper.generateAndStoreKeyIfNeeded()
    
    /// Encrypts a string to AES-GCM encrypted data
    /// - Parameter text: Plain text to encrypt
    /// - Returns: Encrypted Data (or nil if encryption fails)
    static func encrypt(_ text: String) -> Data? {
        /// Convert string to Data
        guard let data = text.data(using: .utf8)
        else { return nil }
        /// Encrypt, Combine nonce, ciphertext, and tag
        return try? AES.GCM.seal(data, using: key).combined
    }
    
    /// Decrypts AES-GCM encrypted data back to a string
    /// - Parameter data: The encrypted Data
    /// - Returns: Decrypted string (or nil if decryption fails)
    static func decrypt(_ encryptedData: Data) -> String? {
        guard let sealedBox = try? AES.GCM.SealedBox(combined: encryptedData),
              let decryptedData = try? AES.GCM.open(sealedBox, using: key),
              let decryptedText = String(data: decryptedData, encoding: .utf8)
        else { return nil }
        return decryptedText
    }
}
