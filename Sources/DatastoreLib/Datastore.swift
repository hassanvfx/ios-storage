//
//  Storage+Pipeline.swift
//  spree3d
//
//  Created by hassan uriostegui on 1/22/21.
//

import Combine
import EasyStash
import Foundation
import CryptoKit
public actor Datastore: ObservableObject {
  
    internal var encryptionKey: SymmetricKey?
    var storageObservers = [AnyCancellable]()
    var storage: EasyStash.Storage? {
        do {
            let storage = try EasyStash.Storage(options: Options())
            return storage
        } catch {
            return nil
        }
    }
   

    public init() {
        let storeKeyToKeychain: (String, Data) -> Void = { key, data in
            let query: [String: Any] = [
                kSecClass as String: kSecClassKey,
                kSecAttrApplicationTag as String: key,
                kSecValueData as String: data,
            ]
            SecItemAdd(query as CFDictionary, nil)
        }
        let retrieveKeyFromKeychain: (String) -> Data? = { key in
            let query: [String: Any] = [
                kSecClass as String: kSecClassKey,
                kSecAttrApplicationTag as String: key,
                kSecReturnData as String: kCFBooleanTrue!,
                kSecMatchLimit as String: kSecMatchLimitOne,
            ]
            var item: CFTypeRef?
            if SecItemCopyMatching(query as CFDictionary, &item) == noErr {
                return (item as? Data)
            }
            return nil
        }
        let keychainKey = "com.secureVault.datstore.db"
        if let storedKey = retrieveKeyFromKeychain(keychainKey) {
            encryptionKey = SymmetricKey(data: storedKey)
        } else {
            let newKey = SymmetricKey(size: .bits256)
            let keyData = newKey.withUnsafeBytes { Data(Array($0)) }
            storeKeyToKeychain(keychainKey, keyData)
            encryptionKey = newKey
        }
    }
}

extension Datastore {
    func restore<T: DatastoreItem>(model: T) async throws {
        try await unarchive(model: model)
    }
    func observeAndArchive<T: Any, T2: Error, ITEM: DatastoreItem>(_ publisher: AnyPublisher<T, T2>, model: ITEM, throttleMs: Int) async throws {
        storageObservers.append(
        publisher
            .throttle(for: .milliseconds(throttleMs), scheduler: DispatchQueue.global(qos: .background), latest: true)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { _ in }, receiveValue: { [weak self] _ in
                guard let self else { return }
                Task{
                    try? await self.archive(model: model)
                }
            })
        )
    }
    
    func restoreAndObserve<T: DatastoreItem>(model: T, throttleMs: Int) async throws {
        try await restore(model: model)
        try await observeAndArchive(model.storagePublisher, model: model, throttleMs:Int(throttleMs))
    }
    
}
