//
//  GizmoDesktopMK2App.swift
//  GizmoDesktopMK2
//
//  Created by Matthew Sand on 11/7/24.
//

import SwiftUI

@main
struct GizmoDesktopMK2App: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    var body: some Scene {
        Settings {
               EmptyView()
           }
    }
}
