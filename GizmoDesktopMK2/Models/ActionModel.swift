//
//  ActionModel.swift
//  GizmoMK2
//
//  Created by Matthew Sand on 11/7/24.
//

import Foundation
import SwiftUI

struct ActionModel : Codable, Identifiable, Hashable {
    var id : String
    var name : String
    var type : ActionType
    var modifiers : [ModifierButton : Bool]
    var key : String
    var shortcut : String
    var destinationPageId : String
    var numericValue : Double
    
    enum CodingKeys: String, CodingKey {
          case id
            case name
          case type
        case modifiers
        case key
        case shortcut
        case destinationPageId
        case numericValue
      }

      public init(from decoder: Decoder) throws {
          let container = try decoder.container(keyedBy: CodingKeys.self)
          id = try container.decodeIfPresent(String.self, forKey: .id) ?? "DefaultID" // Provide a default or handle missing id
          name = try container.decodeIfPresent(String.self, forKey: .name) ?? "DefaultActionName"
          type = try container.decodeIfPresent(ActionType.self, forKey: .type) ?? ActionType.none
          modifiers = try container.decodeIfPresent([ModifierButton : Bool].self, forKey: .modifiers) ?? [:]
          key = try container.decodeIfPresent(String.self, forKey: .key) ?? ""
          shortcut = try container.decodeIfPresent(String.self, forKey: .shortcut) ?? ""
          destinationPageId = try container.decodeIfPresent(String.self, forKey: .destinationPageId) ?? ""
          numericValue = try container.decodeIfPresent(Double.self, forKey: .numericValue) ?? 0
      }

    public init(id: String = UUID().uuidString,name: String = "DefaultID",  type: ActionType = .none, modifiers : [ModifierButton : Bool] = [:], key : String = "", shortcut : String = "", destinationPageId : String = "") {
          self.id = id
          self.name = name
        self.type = type
        self.modifiers = modifiers
        self.key = key
        self.shortcut = shortcut
        self.destinationPageId = destinationPageId
        self.numericValue = 0
      }
}


enum ModifierButton : Codable, Equatable, Identifiable, Hashable, CaseIterable {
    case shift
    case command
    case control
    case option
    
    var id : Self {self}
    
    var icon : String {
        switch self {
        case .shift:
            "shift"
        case .command:
            "command"
        case .control:
            "control"
        case .option:
            "option"
        }
    }
}


enum ActionCategory : Codable {
    case system
    case siriShortcut
    case core
    
    static func < (lhs: ActionCategory, rhs: ActionCategory) -> Bool {
        switch (lhs, rhs) {
        case (.system, .siriShortcut):
            return true
        default:
            return false
        }
    }
    
    var associatedColor: Color {
        switch self {
        case .system:
            return Color("PrimaryAccentColor")
        case .siriShortcut:
            return Color("TertiaryAccentColor")
        case .core:
            return Color("SecondaryAccentColor")
        }
    }
    
    var associatedIcon : String {
        switch self {
        case .system:
            return "desktopcomputer"
        case .siriShortcut:
            return "sparkles"
        case .core:
            return "bolt.fill"
        }
    }
}


enum ActionType : String, Codable, CaseIterable, Identifiable, Hashable {
    case keybind = "Keybinding"
    case siriShortcut = "Siri Shortcut"
    case nextSong = "Next Song"
    case previousSong = "Previous Song"
    case goToPage = "Go To Page"
    case volumeUp = "Volume Up"
    case volumeDown = "Volume Down"
    case setVolume = "Set Volume"
    case leftClick = "Left Click"
    case rightClick = "Right Click"
    case none = "None"
    
    var id : Self {self}
    
    var category : ActionCategory {
        switch self {
        case .keybind, .volumeUp, .volumeDown, .setVolume, .nextSong, .previousSong,  .leftClick, .rightClick:
            return .system
        case .siriShortcut:
            return .siriShortcut
        case .goToPage, .none:
            return .core
        }
    }
    
    var inputType : ActionValueInputType {
        switch self {
        case .keybind:
            return .Keybind
        case .volumeDown, .volumeUp, .setVolume:
            return .Numeric
        case .goToPage:
            return .Page
        default:
            return .none
        }
    }
    
    var valueLabel : String {
        switch self {
        case .volumeUp, .volumeDown, .setVolume:
            return "Amount"
        default:
            return "Value"
        
        }
    }
    
    var numericInputStartingValue : Double {
        switch self {
        case .volumeUp, .volumeDown, .setVolume:
            return 0
        default:
            return 0
        }
    }
    
    var numericInputEndingValue : Double {
        switch self {
        case .volumeUp, .volumeDown, .setVolume:
            return 1
        default:
            return 100
        }
    }
    
    var numericInputStepSize : Double {
        switch self {
        case .volumeUp, .volumeDown, .setVolume:
            return 0.1
        default:
            return 1
        }
    }
}

enum ActionValueInputType : Codable, Hashable, Identifiable {
    case Numeric
    case String
    case Keybind
    case Page
    case none
    
    var id : Self {self}
}
