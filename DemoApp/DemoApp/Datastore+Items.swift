import Combine
import Datastore
import Foundation

class Model: ObservableObject {
    struct State: Codable {
        var value = 0
    }

    @Published var state = State()
    init() {}
    func increaseValue() {
        DispatchQueue.main.async {
            self.state.value = self.state.value + 1
        }
    }
}

extension Model: DatastoreItem {
    var storageKey: String {
        "store:v1"
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
        DispatchQueue.main.async {
            self.state = item
            completion()
        }
    }
}
