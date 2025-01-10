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
    var coreActionType : CoreActionType
    
    enum CodingKeys: String, CodingKey {
          case id
            case name
          case type
        case modifiers
        case key
        case shortcut
        case coreActionType
      }

      public init(from decoder: Decoder) throws {
          let container = try decoder.container(keyedBy: CodingKeys.self)
          id = try container.decodeIfPresent(String.self, forKey: .id) ?? "DefaultID" // Provide a default or handle missing id
          name = try container.decodeIfPresent(String.self, forKey: .name) ?? "DefaultActionName"
          type = try container.decodeIfPresent(ActionType.self, forKey: .type) ?? ActionType.keybind
          modifiers = try container.decodeIfPresent([ModifierButton : Bool].self, forKey: .modifiers) ?? [:]
          key = try container.decodeIfPresent(String.self, forKey: .key) ?? ""
          shortcut = try container.decodeIfPresent(String.self, forKey: .shortcut) ?? ""
          coreActionType = try container.decodeIfPresent(CoreActionType.self, forKey: .coreActionType) ?? .nextSong
      }

    public init(id: String = UUID().uuidString,name: String = "DefaultID",  type: ActionType = .keybind, modifiers : [ModifierButton : Bool] = [:], key : String = "", shortcut : String = "", coreActionType : CoreActionType = .nextSong) {
          self.id = id
          self.name = name
        self.type = type
        self.modifiers = modifiers
        self.key = key
        self.shortcut = shortcut
        self.coreActionType = coreActionType
      }
}


enum ModifierButton : Codable, Equatable {
    case shift
    case command
    case control
    case option
}


enum ActionType : Codable {
    case keybind
    case siriShortcut
    case core
    
    static func < (lhs: ActionType, rhs: ActionType) -> Bool {
        switch (lhs, rhs) {
        case (.keybind, .siriShortcut):
            return true
        default:
            return false
        }
    }
    
    var associatedColor: Color {
        switch self {
        case .keybind:
            return Color("PrimaryAccentColor")
        case .siriShortcut:
            return Color("TertiaryAccentColor")
        case .core:
            return Color("SecondaryAccentColor")
        }
    }
    
    var associatedIcon : String {
        switch self {
        case .keybind:
            return "keyboard"
        case .siriShortcut:
            return "sparkles"
        case .core:
            return "bolt.fill"
        }
    }
}

enum CoreActionType : Codable {
    case nextSong
    case previousSong
}

