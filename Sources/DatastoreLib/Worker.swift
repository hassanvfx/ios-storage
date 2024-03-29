//
//  Storage+Manager.swift
//  spree3d
//
//  Created by hassan uriostegui on 1/22/21.
//

import Combine
import EasyStash
import Foundation
import UIKit

extension Datastore {
    /// IMPORTANT: Update this key whenever the stored models schema has changed
    static var GLOBALKEY = "datastorage:v1"
    static func global(key: String) -> String {
        "\(GLOBALKEY):\(key)"
    }
}

extension Datastore {
    func archive<T: DatastoreItem>(model: T) async throws {
        guard let storage = storage else {
            fatalError()
        }

        let state = model.getStorageItem()
        let key = Datastore.global(key: model.storageKey)

        do {
            try BackgroundTask.runThrowing { bgTask in
                guard model.storageEnprypted == false else {
                    do {
                        let data = try storage.options.encoder.encode(state)
                        let encryptedData = try encrypt(data: data)
                        let encryptedWrap = EncryptedWrap(data: encryptedData)

                        try storage.save(object: encryptedWrap, forKey: key)
                        bgTask.finish()
                    } catch {
                        throw error
                    }
                    return
                }
                try storage.save(object: state, forKey: key)
                bgTask.finish()
            }
        } catch {
            throw error
        }
    }

    func unarchive<T: DatastoreItem>(model: T) async throws {
        try await withCheckedThrowingContinuation { continuation in
            guard let storage = storage else {
                fatalError()
            }
            let key = Datastore.global(key: model.storageKey)
            do {
                guard model.storageEnprypted == false else {
                    do {
                        let encryptedWrap: EncryptedWrap = try storage.load(forKey: key, as: EncryptedWrap.self)

                        let decryptedData = try decrypt(data: encryptedWrap.data)
                        let decoder = storage.options.decoder

                        let state = try decoder.decode(T.ITEM.self, from: decryptedData)
                        DispatchQueue.main.async {
                            model.setStorageItem(state) {
                                continuation.resume()
                            }
                        }
                    } catch {
                        DispatchQueue.main.async {
                            model.setStorageItem(model.getStorageItemDefault()) {
                                continuation.resume()
                            }
                        }
                    }
                    return
                }
                let state: T.ITEM = try storage.load(forKey: key, as: T.ITEM.self)
                DispatchQueue.main.async {
                    model.setStorageItem(state) {
                        continuation.resume()
                    }
                }
            } catch {
                DispatchQueue.main.async {
                    model.setStorageItem(model.getStorageItemDefault()) {
                        continuation.resume()
                    }
                }
            }
        }
    }
}
