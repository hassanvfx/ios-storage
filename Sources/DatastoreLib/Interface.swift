//
//  File.swift
//
//
//  Created by hassan uriostegui on 8/30/22.
//

import Combine
import Foundation


extension Datastore {
    static let STORAGE_DELAY_MS = 1234
}

public extension Datastore {
    func connect<T: DatastoreItem>(model: T) async throws {
        try await restoreAndObserve(model: model)
    }
}
