//
//  Shortcuts.swift
//  GizmoDesktopMK2
//
//  Created by Matthew Sand on 11/14/24.
//

import Foundation

func fetchShortcuts() -> [String] {
    let task = Process()
    task.executableURL = URL(fileURLWithPath: "/usr/bin/env")
    task.arguments = ["shortcuts", "list"]

    let pipe = Pipe()
    task.standardOutput = pipe
    do {
        try task.run()
        task.waitUntilExit()
    } catch {
        print("Failed to run shortcuts list command:", error)
        return []
    }

    let data = pipe.fileHandleForReading.readDataToEndOfFile()
    let output = String(data: data, encoding: .utf8) ?? ""
    return output.split(separator: "\n").map { String($0) }
}

func runShortcut(named name: String) {
    print("Running shortcut named:", name)
    let task = Process()
    task.executableURL = URL(fileURLWithPath: "/usr/bin/env")
    task.arguments = ["shortcuts", "run", name]

    do {
        try task.run()
        task.waitUntilExit()
    } catch {
        print("Failed to run shortcut:", error)
    }
}


func runShortcutAction(_ action: ActionModel) {
    runShortcut(named: action.shortcut)
}


