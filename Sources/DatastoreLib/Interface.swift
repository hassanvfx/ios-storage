//
//  File.swift
//
//
//  Created by hassan uriostegui on 8/30/22.
//

import Combine
import Foundation

public protocol DatastoreItem {
    associatedtype ITEM: Codable
    var storageKey: String { get }
    func getStorageItem() -> ITEM
    func getStorageItemDefault() -> ITEM
    func setStorageItem(_ item: ITEM, completion: @escaping () -> Void)
    var storagePublisher: AnyPublisher<ITEM, Never> { get }
}

extension Datastore {
    static let STORAGE_DELAY_MS = 1234
}

public extension Datastore {
    func connect<T: DatastoreItem>(model: T) throws {
        Task{
            try await restoreAndObserve(model: model)
        }
    }
}
