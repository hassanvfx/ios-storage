//
//  Storage+Pipeline.swift
//
//  Created by hassan uriostegui on 1/22/21.
//

import Combine
import EasyStash
import Foundation

public class Datastore: ObservableObject {
    public init() {}

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
}

extension Datastore {
    func restoreAndObserve<T: DatastoreItem>(model: T) throws {
        func restore<T: DatastoreItem>(model: T, completion: @escaping () -> Void) throws {
            try unarchive(model: model, completion: completion)
        }
        func observeAndArchive<T: Any, T2: Error, ITEM: DatastoreItem>(_ publisher: AnyPublisher<T, T2>, model: ITEM, throttleMs: Int = Datastore.STORAGE_DELAY_MS) {
            storageObservers.append(
                publisher
                    .throttle(for: .milliseconds(throttleMs), scheduler: DispatchQueue.global(qos: .background), latest: true)
                    .receive(on: DispatchQueue.main)
                    .sink(receiveCompletion: { _ in }, receiveValue: { [weak self] _ in
                        try? self?.archive(model: model)
                    })
            )
        }

        try restore(model: model) {
            observeAndArchive(model.storagePublisher, model: model)
        }
    }
}
