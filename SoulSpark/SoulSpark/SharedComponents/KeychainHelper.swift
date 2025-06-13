import Foundation
import CryptoKit

/// A helper for securely storing and retrieving the AES symmetric key using the iOS Keychain.
enum KeychainHelper {

    /// A unique identifier used to store and retrieve the encryption key from the Keychain.
    static let keyTag = "com.yourapp.encryptionkey"

    /// Saves the symmetric key securely into the Keychain.
    /// - Parameter key: The AES symmetric key to save.
    static func saveKey(_ key: SymmetricKey) {
        let tag = keyTag.data(using: .utf8)! // Keychain requires Data
        let keyData = key.withUnsafeBytes { Data($0) } // Convert SymmetricKey to Data

        // Prepare the query to store the key in the Keychain
        let query: [String: Any] = [
            kSecClass as String: kSecClassKey,
            kSecAttrApplicationTag as String: tag,
            kSecValueData as String: keyData,
            kSecAttrKeyClass as String: kSecAttrKeyClassSymmetric,
            kSecAttrAccessible as String: kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly // Secure accessibility
        ]

        SecItemDelete(query as CFDictionary) // Clean up any existing key first
        SecItemAdd(query as CFDictionary, nil) // Store new key
    }

    /// Loads the stored symmetric key from the Keychain.
    /// - Returns: The previously saved `SymmetricKey`, or `nil` if it doesn't exist.
    static func loadKey() -> SymmetricKey? {
        let tag = keyTag.data(using: .utf8)!

        // Prepare query to fetch key
        let query: [String: Any] = [
            kSecClass as String: kSecClassKey,
            kSecAttrApplicationTag as String: tag,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]

        var item: CFTypeRef?
        let status = SecItemCopyMatching(query as CFDictionary, &item)

        // If found, convert data back to SymmetricKey
        if status == errSecSuccess, let data = item as? Data {
            return SymmetricKey(data: data)
        } else {
            return nil
        }
    }

    /// Returns the existing key if available, otherwise generates a new one, stores it, and returns it.
    /// - Returns: A valid `SymmetricKey` for encryption and decryption use.
    static func generateAndStoreKeyIfNeeded() -> SymmetricKey {
        if let existingKey = loadKey() {
            return existingKey
        } else {
            let newKey = SymmetricKey(size: .bits256)
            saveKey(newKey)
            return newKey
        }
    }
}
