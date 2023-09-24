//
//  Storage+Manager.swift
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
    func archive<T: DatastoreItem>(model: T) throws {
        guard let storage = storage else {
            fatalError()
        }

        let state = model.getStorageItem()
        let key = Datastore.global(key: model.storageKey)

        do {
            try BackgroundTask.runThrowing { bgTask in

                try storage.save(object: state, forKey: key)
                bgTask.finish()
            }
        } catch {
            throw error
        }
    }

    func unarchive<T: DatastoreItem>(model: T, completion: @escaping () -> Void = {}) throws {
        guard let storage = storage else {
            fatalError()
        }

        let key = Datastore.global(key: model.storageKey)

        do {
            let state: T.ITEM = try storage.load(forKey: key, as: T.ITEM.self)
            DispatchQueue.main.async {
                model.setStorageItem(state, completion: completion)
                completion()
            }

        } catch {
            completion()
            throw error
        }
    }
}
