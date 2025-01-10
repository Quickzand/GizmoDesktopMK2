//
//  Executor.swift
//  GizmoMK2
//
//  Created by Matthew Sand on 11/7/24.
//

import Foundation
import SwiftUI

struct ExecutorModel : Identifiable, Codable, Transferable {
    
    static var transferRepresentation: some TransferRepresentation {
        CodableRepresentation(for: ExecutorModel.self, contentType: .json)
    }
    
    
    var id : String
    var label: String
    var interactionType : InteractionType
    var actionID : String
    var secondaryActionID : String
    var upActionID : String
    var downActionID : String
    var leftActionID : String
    var rightActionID : String
    var labelHidden : Bool
    var icon : String
    var backgroundColor : String
    var foregroundColor : String
    var backgroundOpacity : Double
    var iconHidden : Bool
    
    enum CodingKeys: String, CodingKey {
          case label
          case id
          case actionID
        case secondaryActionID
        case upActionID
        case downActionID
        case leftActionID
        case rightActionID
        case interactionType
        case labelHidden
        case icon
        case iconHidden
        case backgroundColor
        case foregroundColor
        case backgroundOpacity
        
      }
    


      public init(from decoder: Decoder) throws {
          let container = try decoder.container(keyedBy: CodingKeys.self)
          label = try container.decodeIfPresent(String.self, forKey: .label) ?? "TestLabel"
          id = try container.decodeIfPresent(String.self, forKey: .id) ?? "DefaultID" // Provide a default or handle missing id
          interactionType = try container.decodeIfPresent(InteractionType.self, forKey: .interactionType) ?? .button
          actionID = try container.decodeIfPresent(String.self, forKey: .actionID) ?? ""
          secondaryActionID = try container.decodeIfPresent(String.self, forKey: .secondaryActionID) ?? ""
          upActionID = try container.decodeIfPresent(String.self, forKey: .upActionID) ?? ""
          downActionID = try container.decodeIfPresent(String.self, forKey: .downActionID) ?? ""
          leftActionID = try container.decodeIfPresent(String.self, forKey: .leftActionID) ?? ""
          rightActionID = try container.decodeIfPresent(String.self, forKey: .rightActionID) ?? ""
          labelHidden = try container.decodeIfPresent(Bool.self, forKey: .labelHidden) ?? false
          icon = try container.decodeIfPresent(String.self, forKey: .icon) ?? "bolt.fill"
          iconHidden = try container.decodeIfPresent(Bool.self, forKey: .iconHidden) ?? false
          backgroundColor = try container.decodeIfPresent(String.self, forKey: .backgroundColor) ?? "#000000"
          foregroundColor = try container.decodeIfPresent(String.self, forKey: .foregroundColor) ?? "#FFFFFF"
          backgroundOpacity = try container.decodeIfPresent(Double.self, forKey: .backgroundOpacity) ?? 1
          
      }

    public init(id: String = UUID().uuidString ,label: String = "TestLabel", interactionType : InteractionType = .button, actionID: String = "default", secondaryActionID : String = "", upActionID: String = "", downActionID: String = "", leftActionID: String = "", rightActionID: String = "", labelHidden: Bool = false, icon : String = "bolt.fill", backgroundColor : String = "#000000", foregroundColor : String = "#FFFFFF", backgroundOpacity : Double = 0.5, iconHidden : Bool = false) {
          self.label = label
          self.id = id
        self.interactionType = interactionType
          self.actionID = actionID
        self.secondaryActionID = secondaryActionID
        self.upActionID = upActionID
        self.downActionID = downActionID
        self.leftActionID = leftActionID
        self.rightActionID = rightActionID
        self.labelHidden = labelHidden
        self.icon = icon
        self.backgroundColor = backgroundColor
        self.foregroundColor = foregroundColor
        self.backgroundOpacity = backgroundOpacity
        self.iconHidden = iconHidden
      }
    
    static var defaultValue : ExecutorModel {
        ExecutorModel(id: UUID().uuidString, label: "", actionID: "")
    }
}

enum InteractionType : Codable {
    case button
    case knob
    case gesture
}
