//
//  DemoAppApp.swift
//  DemoApp
//
//  Created by hassan uriostegui on 8/30/22.
//

import SwiftUI
import Framework

class Model:ObservableObject{
    init(){
        let framework = Framework()
        framework.test()
    }
}

@main
struct DemoAppApp: App {
    @ObservedObject var model = Model()
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
