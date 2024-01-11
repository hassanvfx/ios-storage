//
//  File.swift
//
//
//  Created by Eon Fluxor on 1/6/24.
//

import CryptoKit
import Foundation

extension Datastore {
    struct EncryptedWrap: Codable {
        var data: Data
    }

    enum EncryptionError: Error {
        case combinedDataNil
        case encryptionFailed(String)
    }

    enum DecryptionError: Error {
        case invalidData
        case decryptionFailed(String)
    }
}

// public extension Datastore {
//    private var keychainKey: String {
//        "com.__data__store__.secureVault"
//    }
//
//    func retrieveKeyFromKeychain() -> Data? {
//        let query: [String: Any] = [
//            kSecClass as String: kSecClassKey,
//            kSecAttrApplicationTag as String: keychainKey,
//            kSecReturnData as String: kCFBooleanTrue!,
//            kSecMatchLimit as String: kSecMatchLimitOne,
//        ]
//        var item: CFTypeRef?
//        if SecItemCopyMatching(query as CFDictionary, &item) == noErr {
//            return (item as? Data)
//        }
//        return nil
//    }
//
//    func storeKeyToKeychain(_ data: Data) {
//        let query: [String: Any] = [
//            kSecClass as String: kSecClassKey,
//            kSecAttrApplicationTag as String: keychainKey,
//            kSecValueData as String: data,
//        ]
//        SecItemAdd(query as CFDictionary, nil)
//    }
//
// }

extension Datastore {
    func encrypt(data: Data) throws -> Data {
        guard let encryptionKey else {
            assertionFailure()
            return Data()
        }
        return try encrypt(data, using: encryptionKey)
    }

    func decrypt(data: Data) throws -> Data {
        guard let encryptionKey else {
            assertionFailure()
            return Data()
        }
        return try decrypt(data, using: encryptionKey)
    }
}

extension Datastore {
    private func encrypt(_ data: Data, using key: SymmetricKey) throws -> Data {
        do {
            let sealedBox = try AES.GCM.seal(data, using: key)
            guard let combined = sealedBox.combined else {
                throw EncryptionError.combinedDataNil
            }
            return combined
        } catch {
            // Wrap the underlying error into our custom EncryptionError
            throw EncryptionError.encryptionFailed(error.localizedDescription)
        }
    }

    private func decrypt(_ data: Data, using key: SymmetricKey) throws -> Data {
        do {
            let box = try AES.GCM.SealedBox(combined: data)
            return try AES.GCM.open(box, using: key)
        } catch {
            // Wrap the underlying error into our custom DecryptionError
            throw DecryptionError.decryptionFailed(error.localizedDescription)
        }
    }
}
