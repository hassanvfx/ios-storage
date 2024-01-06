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
public class Datastore: ObservableObject {
  
    internal var encryptionKey: SymmetricKey?
    var storageObservers = [AnyCancellable]()
    var storage: EasyStash.Storage? {
        do {
            let storage = try EasyStash.Storage(options: Options())
            return storage
        } catch {
            // LogService.assert(.storageManager, "Failed to create storage")
            return nil
        }
    }
   

    public init() {
        if let storedKey = retrieveKeyFromKeychain() {
            encryptionKey = SymmetricKey(data: storedKey)
        } else {
            let newKey = SymmetricKey(size: .bits256)
            let keyData = newKey.withUnsafeBytes { Data(Array($0)) }
            storeKeyToKeychain(keyData)
            encryptionKey = newKey
        }
    }
}

extension Datastore {
    func restore<T: DatastoreItem>(model: T) async throws {
        try await unarchive(model: model)
    }
    func observeAndArchive<T: Any, T2: Error, ITEM: DatastoreItem>(_ publisher: AnyPublisher<T, T2>, model: ITEM, throttleMs: Int = Datastore.STORAGE_DELAY_MS) async throws {
        storageObservers.append(
        publisher
            .throttle(for: .milliseconds(throttleMs), scheduler: DispatchQueue.global(qos: .background), latest: true)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { _ in }, receiveValue: { [weak self] _ in
                try? self?.archive(model: model)
            })
        )
    }
    
    func restoreAndObserve<T: DatastoreItem>(model: T) async throws {
        try await restore(model: model)
        try await observeAndArchive(model.storagePublisher, model: model)
    }
    
//    func restoreAndObserve<T: DatastoreItem>(model: T) throws {
//        func restore<T: DatastoreItem>(model: T, completion: @escaping () -> Void) throws {
//            try unarchive(model: model, completion: completion)
//        }
//        func observeAndArchive<T: Any, T2: Error, ITEM: DatastoreItem>(_ publisher: AnyPublisher<T, T2>, model: ITEM, throttleMs: Int = Datastore.STORAGE_DELAY_MS) {
//            storageObservers.append(
//                publisher
//                    .throttle(for: .milliseconds(throttleMs), scheduler: DispatchQueue.global(qos: .background), latest: true)
//                    .receive(on: DispatchQueue.main)
//                    .sink(receiveCompletion: { _ in }, receiveValue: { [weak self] _ in
//                        try? self?.archive(model: model)
//                    })
//            )
//        }
//
//        try restore(model: model) {
//            observeAndArchive(model.storagePublisher, model: model)
//        }
//    }
}
