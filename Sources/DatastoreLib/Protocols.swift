//
//  File.swift
//  
//
//  Created by Eon Fluxor on 1/6/24.
//

import Foundation
import Combine

public protocol DatastoreItem {
    associatedtype ITEM: Codable
    var storageKey: String { get }
    var storageEnprypted: Bool { get }
    func getStorageItem() -> ITEM
    func getStorageItemDefault() -> ITEM
    func setStorageItem(_ item: ITEM, completion: @escaping () -> Void)
    var storagePublisher: AnyPublisher<ITEM, Never> { get }
}

public extension DatastoreItem{
    var storageEnprypted: Bool {
        true
    }
}
