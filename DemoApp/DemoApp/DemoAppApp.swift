//
//  DemoAppApp.swift
//  DemoApp
//
//  Created by hassan uriostegui on 8/30/22.
//

import DatastoreLib
import SwiftUI
import UIKit

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
