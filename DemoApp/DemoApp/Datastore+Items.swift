import Combine
import DatastoreLib
import Foundation

class Model: ObservableObject {
    struct State: Codable {
        var value = 0
    }

    @Published var state = State()
    init() {}
    @MainActor
    func increaseValue() {
        state.value = state.value + 1
    }
}

extension Model: DatastoreItem {
    var storageKey: String {
        "model:v1"
    }

    var storagePublisher: AnyPublisher<Model.State, Never> {
        $state.eraseToAnyPublisher()
    }

    func getStorageItem() -> Model.State {
        state
    }

    func getStorageItemDefault() -> Model.State {
        Model.State()
    }

    func setStorageItem(_ item: Model.State, completion: @escaping () -> Void) {
        state = item
        completion()
    }
}
