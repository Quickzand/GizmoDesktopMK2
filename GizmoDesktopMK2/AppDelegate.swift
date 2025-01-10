//
//  AppDelegate.swift
//  GizmoDesktopMK2
//
//  Created by Matthew Sand on 12/26/24.
//

import Foundation
import SwiftUI
import AppKit


class AppDelegate: NSObject, NSApplicationDelegate {
    var statusItem: NSStatusItem?
    var popover: NSPopover?

    func applicationDidFinishLaunching(_ notification: Notification) {
        // Create the menu bar item
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)
        
        if let button = statusItem?.button {
            // Use the Gizmo logo as the button image
            let image: NSImage = {
                   let ratio = $0.size.height / $0.size.width
                   $0.size.height = 24
                   $0.size.width = 24 / ratio
                   return $0
               }(NSImage(named: "GizmoIcon")!)

            button.image = image
            button.image?.isTemplate = false // Ensures it adapts to light/dark mode
            button.action = #selector(togglePopover(_:))
        }

        // Create the popover with SwiftUI content
        let contentView = ContentView().environmentObject(AppState())
        popover = NSPopover()
        popover?.contentViewController = NSHostingController(rootView: contentView)
        popover?.behavior = .transient

    }

    @objc func togglePopover(_ sender: Any?) {
        guard let button = statusItem?.button, let popover = popover else { return }
        if popover.isShown {
            popover.performClose(sender)
        } else {
            popover.show(relativeTo: button.bounds, of: button, preferredEdge: .minY)
        }
    }
}
