//
//  DemoAppApp.swift
//  DemoApp
//
//  Created by hassan uriostegui on 8/30/22.
//

import DatastoreLib
import SwiftUI

@main
struct DemoAppApp: App {
    @StateObject var model = Model()
    @StateObject var datastore = Datastore()
    func setupDatastore() {
        Task{
            do {
                try await datastore.connect(model: model)
            } catch {
                print(error)
            }
        }
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(model)
                .environmentObject(datastore)
                .onAppear(perform: setupDatastore)
        }
    }
}
