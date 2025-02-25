//
//  KeyboardSimulations.swift
//  GizmoDesktopMK2
//
//  Created by Matthew Sand on 11/8/24.
//

import Foundation
import Cocoa

import Carbon.HIToolbox

enum MediaKey: UInt16 {
    case playPause = 0xCD    // Usage for Play/Pause
    case nextTrack = 0xB5   // Usage for Next Track
    case previousTrack = 0xB6 // Usage for Previous Track
    case stop = 0xB7        // Usage for Stop
}




// Map ModifierButton to CGEventFlags
func modifierFlags(for modifiers: [ModifierButton: Bool]) -> CGEventFlags {
    var flags: CGEventFlags = []
    
    if modifiers[.command] == true {
        flags.insert(.maskCommand)
    }
    if modifiers[.shift] == true {
        flags.insert(.maskShift)
    }
    if modifiers[.control] == true {
        flags.insert(.maskControl)
    }
    if modifiers[.option] == true {
        flags.insert(.maskAlternate)
    }
    
    return flags
}

// Get the key code from the first character of the key string
func keyCode(for character: Character) -> CGKeyCode? {
    let keyCodeMap: [Character: CGKeyCode] = [
        // Letters
        "a": 0, "b": 11, "c": 8, "d": 2, "e": 14, "f": 3, "g": 5, "h": 4,
        "i": 34, "j": 38, "k": 40, "l": 37, "m": 46, "n": 45, "o": 31,
        "p": 35, "q": 12, "r": 15, "s": 1, "t": 17, "u": 32, "v": 9,
        "w": 13, "x": 7, "y": 16, "z": 6,
        
        // Numbers
        "0": 29, "1": 18, "2": 19, "3": 20, "4": 21, "5": 23,
        "6": 22, "7": 26, "8": 28, "9": 25,
        
        // Common Symbols
        " ": 49,     // Space
        "\t": 48,    // Tab
        "\n": 36,    // Return/Enter
        "-": 27,     // Hyphen/Minus
        "=": 24,     // Equal Sign
        ";": 41,     // Semicolon
        "'": 39,     // Single Quote
        ",": 43,     // Comma
        ".": 47,     // Period
        "/": 44,     // Slash
        "\\": 42,    // Backslash
        "`": 50,     // Backtick/Grave Accent
        
        // Special Symbols
        "[": 33,     // Left Bracket
        "]": 30,     // Right Bracket
        "{": 33,     // Left Curly Brace (requires Shift modifier)
        "}": 30,     // Right Curly Brace (requires Shift modifier)
        "<": 43,     // Less-than (requires Shift modifier)
        ">": 47,     // Greater-than (requires Shift modifier)
        "!": 18,     // Exclamation Mark (requires Shift modifier)
        "@": 19,     // At symbol (requires Shift modifier)
        "#": 20,     // Hash/Pound (requires Shift modifier)
        "$": 21,     // Dollar sign (requires Shift modifier)
        "%": 23,     // Percent (requires Shift modifier)
        "^": 22,     // Caret (requires Shift modifier)
        "&": 26,     // Ampersand (requires Shift modifier)
        "*": 28,     // Asterisk (typically on the numeric keypad, Shift may be required on main keyboard)
        "(": 33,     // Left Parenthesis (requires Shift modifier)
        ")": 30,     // Right Parenthesis (requires Shift modifier)
        "+": 24,     // Plus (requires Shift modifier)
        "_": 27,     // Underscore (requires Shift modifier)
        "~": 50      // Tilde (requires Shift modifier)
    ]
    return keyCodeMap[character.lowercased().first!]
}

// Run the keybind action with modifiers
func runKeybindAction(_ action: ActionModel) {
    guard let firstChar = action.key.first,
          let keyCode = keyCode(for: firstChar) else { return }
    
    let flags = modifierFlags(for: action.modifiers)
    
    // Create and post key down event with modifiers
    let keyDown = CGEvent(keyboardEventSource: nil, virtualKey: keyCode, keyDown: true)
    keyDown?.flags = flags
    keyDown?.post(tap: .cghidEventTap)
    
    // Create and post key up event with modifiers
    let keyUp = CGEvent(keyboardEventSource: nil, virtualKey: keyCode, keyDown: false)
    keyUp?.flags = flags
    keyUp?.post(tap: .cghidEventTap)
    
    print("Ran keybind action: \(action.key) with modifiers: \(action.modifiers)")
}




func nextSong() {
    let keyCode = CGKeyCode(101)
    // Create and post key down event with modifiers
    let keyDown = CGEvent(keyboardEventSource: nil, virtualKey: keyCode, keyDown: true)
    keyDown?.post(tap: .cghidEventTap)
    
    // Create and post key up event with modifiers
    let keyUp = CGEvent(keyboardEventSource: nil, virtualKey: keyCode, keyDown: false)
    keyUp?.post(tap: .cghidEventTap)
}


func performLeftClick() {
    let source = CGEventSource(stateID: .hidSystemState)

    // Get the current mouse position
    var currentMousePosition = NSEvent.mouseLocation

    // Flip the Y-coordinate to match CGEvent's coordinate system
    if let screenHeight = NSScreen.main?.frame.height {
        currentMousePosition.y = screenHeight - currentMousePosition.y
    }

    // Create mouse down and mouse up events at the corrected position
    let mouseDown = CGEvent(mouseEventSource: source, mouseType: .leftMouseDown, mouseCursorPosition: currentMousePosition, mouseButton: .left)
    let mouseUp = CGEvent(mouseEventSource: source, mouseType: .leftMouseUp, mouseCursorPosition: currentMousePosition, mouseButton: .left)

    // Post the events
    mouseDown?.post(tap: .cghidEventTap)
    mouseUp?.post(tap: .cghidEventTap)
}

func performRightClick() {
    let source = CGEventSource(stateID: .hidSystemState)

    // Get the current mouse position
    var currentMousePosition = NSEvent.mouseLocation

    // Flip the Y-coordinate to match CGEvent's coordinate system
    if let screenHeight = NSScreen.main?.frame.height {
        currentMousePosition.y = screenHeight - currentMousePosition.y
    }

    // Create mouse down and mouse up events at the corrected position
    let mouseDown = CGEvent(mouseEventSource: source, mouseType: .rightMouseDown, mouseCursorPosition: currentMousePosition, mouseButton: .left)
    let mouseUp = CGEvent(mouseEventSource: source, mouseType: .rightMouseUp, mouseCursorPosition: currentMousePosition, mouseButton: .left)

    // Post the events
    mouseDown?.post(tap: .cghidEventTap)
    mouseUp?.post(tap: .cghidEventTap)
}


func openApp(bundleId: String) {
    if let appURL = NSWorkspace.shared.urlForApplication(withBundleIdentifier: bundleId) {
        let configuration = NSWorkspace.OpenConfiguration()
        NSWorkspace.shared.openApplication(at: appURL, configuration: configuration) { runningApp, error in
            if let error = error {
                print("Error opening app: \(error)")
            } else {
                print("App opened successfully: \(runningApp?.localizedName ?? "Unknown")")
            }
        }
    } else {
        print("Failed to find app URL for bundle ID: \(bundleId)")
    }
}

