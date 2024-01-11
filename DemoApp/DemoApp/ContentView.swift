//
//  ContentView.swift
//  DemoApp
//
//  Created by hassan uriostegui on 8/30/22.
//

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

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
