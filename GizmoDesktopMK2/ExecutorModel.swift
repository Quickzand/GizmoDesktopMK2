//
//  ExecutableModel.swift
//  GizmoDesktopMK2
//
//  Created by Matthew Sand on 11/7/24.
//

import Foundation
import SwiftUI

struct ExecutorModel : Identifiable, Codable {
    var id : String
    var label: String
    var actionID : String
    var labelHidden : Bool = false
    var icon : String
    var backgroundColor : String
    var backgroundOpacity : Double
    
    enum CodingKeys: String, CodingKey {
          case label
          case id
          case actionID
        case labelHidden
        case icon
        case backgroundColor
        case backgroundOpacity
      }

      public init(from decoder: Decoder) throws {
          let container = try decoder.container(keyedBy: CodingKeys.self)
          label = try container.decodeIfPresent(String.self, forKey: .label) ?? "TestLabel"
          id = try container.decodeIfPresent(String.self, forKey: .id) ?? "DefaultID" // Provide a default or handle missing id
          actionID = try container.decodeIfPresent(String.self, forKey: .actionID) ?? ""
          labelHidden = try container.decodeIfPresent(Bool.self, forKey: .labelHidden) ?? false
          icon = try container.decodeIfPresent(String.self, forKey: .icon) ?? ""
          backgroundColor = try container.decodeIfPresent(String.self, forKey: .backgroundColor) ?? "#000000"
          backgroundOpacity = try container.decodeIfPresent(Double.self, forKey: .backgroundOpacity) ?? 1
      }

    public init(id: String = UUID().uuidString ,label: String = "TestLabel",  actionID: String = "", labelHidden: Bool = false, icon : String = "", backgroundColor : String = "#000000", backgroundOpacity : Double = 1.0) {
          self.label = label
          self.id = id
          self.actionID = actionID
        self.labelHidden = labelHidden
        self.icon = icon
        self.backgroundColor = backgroundColor
        self.backgroundOpacity = backgroundOpacity
      }
    
    static var defaultValue : ExecutorModel {
        ExecutorModel(id: UUID().uuidString, label: "", actionID: "")
    }
}
