//
//  File.swift
//
//
//  Created by hassan uriostegui on 8/30/22.
//

import Combine
import Foundation


public extension Datastore {
    static let ErrorCodeNewStore = 260
    static let TinyDelay = 234
}

public extension Datastore {
    func connect<T: DatastoreItem>(model: T, throttleMs:Int = Datastore.TinyDelay) async throws {
        try await restoreAndObserve(model: model, throttleMs:throttleMs)
    }
}
