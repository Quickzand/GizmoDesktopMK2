//
//  ActionModel.swift
//  GizmoDesktopMK2
//
//  Created by Matthew Sand on 11/7/24.
//

import Foundation

struct ActionModel : Codable, Identifiable, Hashable {
    var id : String
    var name : String
    var type : ActionType
    var modifiers : [ModifierButton : Bool]
    var key : String
    var shortcut : String
    
    enum CodingKeys: String, CodingKey {
          case id
            case name
          case type
        case modifiers
        case key
        case shortcut
      }

      public init(from decoder: Decoder) throws {
          let container = try decoder.container(keyedBy: CodingKeys.self)
          id = try container.decodeIfPresent(String.self, forKey: .id) ?? "DefaultID" // Provide a default or handle missing id
          name = try container.decodeIfPresent(String.self, forKey: .name) ?? "DefaultActionName"
          type = try container.decodeIfPresent(ActionType.self, forKey: .type) ?? ActionType.keybind
          modifiers = try container.decodeIfPresent([ModifierButton : Bool].self, forKey: .modifiers) ?? [:]
          key = try container.decodeIfPresent(String.self, forKey: .key) ?? ""
          shortcut = try container.decodeIfPresent(String.self, forKey: .shortcut) ?? ""
      }

    public init(id: String = UUID().uuidString,name: String = "DefaultID",  type: ActionType = .keybind, modifiers : [ModifierButton : Bool] = [:], key : String = "", shortcut : String = "") {
          self.id = id
          self.name = name
        self.type = type
        self.modifiers = modifiers
        self.key = key
        self.shortcut = shortcut
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
}
