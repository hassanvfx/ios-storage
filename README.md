# Overview
![image](https://github.com/hassanvfx/ios-storage/assets/425926/3ef003af-0017-4946-a341-9a050d552763)


DataStore is a Swift library offering a simplified and efficient
alternative for data storage in SwiftUI applications. It surpasses Core
Data and Swift Data in simplicity, adds configurable encryption, and
transforms any `ObservableObject` into a persistence-enabled class by
conforming to a specific protocol. Upon initialization, it loads the
state from the disk, observes changes, and saves them to disk on a
background thread.

# Features

- **Simple Integration**: Easily integrates with SwiftUI applications.
- **Configurable Encryption**: Provides options for securing stored
  data.
- **Automatic Persistence**: Automatically handles the loading and
  saving of data.
- **Efficient Background Operations**: Performs disk operations on a
  background thread.
- **Conforms to ObservableObject**: Seamlessly works with SwiftUI’s data Publishers
  flow.
- **AES.GCM + 256 SecureKey Encryption** As suggested by [Dave Poireir](https://www.linkedin.com/in/dave-poirier-a9b25a9/)
- **Swift Actor for Tread Safety** As suggested by [Dave Poireir](https://www.linkedin.com/in/dave-poirier-a9b25a9/)

# Installation

Include `DatastoreLib` in your Swift Package Manager dependencies.

# Usage

## Setting Up Datastore

1.  Import `DatastoreLib` in your SwiftUI application.

2.  Initialize and configure `Datastore` in your main App structure.

``` swift
import DatastoreLib
import SwiftUI

// AppDelegate class
class AppDelegate: NSObject, UIApplicationDelegate {
    var datastore: Datastore?
    static let model = Model()

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        // Initialize and setup datastore
        datastore = Datastore()
        setupDatastore()
        return true
    }

    private func setupDatastore() {
        Task {
            do {
                try await datastore?.connect(model: Self.model)
            } catch {
                if error._code == Datastore.ErrorCodeNewStore {
                    // this is OK to pass
                    return
                } else {
                    // handle error
                }
            }
        }
    }
}

@main
struct DemoAppApp: App {
    // Register the AppDelegate
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
```

## Creating a ContentView

Create a `ContentView` that interacts with your model.

``` swift
import SwiftUI

struct ContentView: View {
    @ObservedObject var appDelegate = AppDelegate.model
    var body: some View {
        HStack {
            Text("Persisted Value: \(appDelegate.state.value)")
                .padding()
            Button(action: appDelegate.increaseValue) {
                Text("Increment Value")
                    .padding()
            }
        }
    }
}
```

## Defining a Model

Define a model that conforms to `ObservableObject` and `DatastoreItem`.

``` swift
import Combine
import DatastoreLib
import Foundation

class Model: ObservableObject {
    struct State: Codable {
        var value = 0
    }

    @Published var state = State()

    init() {}

    func increaseValue() {
        DispatchQueue.main.async {
            self.state.value += 1
        }
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
        self.state = item
        completion()
    }
}
```

## DatastoreItem Protocol

Implement the `DatastoreItem` protocol to define how your model
interacts with DataStore.

``` swift
import Foundation
import Combine

public protocol DatastoreItem {
    associatedtype ITEM: Codable
    var storageKey: String { get }
    var storageEnprypted: Bool { get }
    var storagePublisher: AnyPublisher<ITEM, Never> { get }
    func getStorageItem() -> ITEM
    func getStorageItemDefault() -> ITEM
    func setStorageItem(_ item: ITEM, completion: @escaping () -> Void)
}

public extension DatastoreItem {
    var storageEnprypted: Bool {
        true
    }
}
```

# Conclusion

DataStore offers a straightforward, efficient, and secure solution for
data persistence in SwiftUI applications. By conforming to
`DatastoreItem`, you can effortlessly integrate persistent data storage
into your SwiftUI models.
