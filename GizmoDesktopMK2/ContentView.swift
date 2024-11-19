//
//  ContentView.swift
//  GizmoDesktopMK2
//
//  Created by Matthew Sand on 11/7/24.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var appState: AppState
    var body: some View {
        VStack {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundStyle(.tint)
            Text("Hello, world!")
        }
        .onAppear {

        }
        .padding()
    }
}

#Preview {
    ContentView()
}
