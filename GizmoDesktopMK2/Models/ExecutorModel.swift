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
    var action : ActionModel
    var secondaryAction : ActionModel
    var upAction : ActionModel
    var downAction : ActionModel
    var leftAction : ActionModel
    var rightAction : ActionModel
    var labelHidden : Bool
    var icon : String
    var backgroundColor : String
    var foregroundColor : String
    var backgroundOpacity : Double
    var backgroundImageData : Data
    
    
    var iconHidden : Bool
    
    enum CodingKeys: String, CodingKey {
        case label
        case id
        case action
        case secondaryAction
        case upAction
        case downAction
        case leftAction
        case rightAction
        case interactionType
        case labelHidden
        case icon
        case iconHidden
        case backgroundColor
        case foregroundColor
        case backgroundOpacity
        case backgroundImageData
    }

    
    
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        label = try container.decodeIfPresent(String.self, forKey: .label) ?? "TestLabel"
        id = try container.decodeIfPresent(String.self, forKey: .id) ?? "DefaultID" // Provide a default or handle missing id
        action = try container.decodeIfPresent(ActionModel.self, forKey: .action) ?? ActionModel()
        interactionType = try container.decodeIfPresent(InteractionType.self, forKey: .interactionType) ?? .button
        secondaryAction = try container.decodeIfPresent(ActionModel.self, forKey: .secondaryAction) ?? ActionModel()
        upAction = try container.decodeIfPresent(ActionModel.self, forKey: .upAction) ?? ActionModel()
        downAction = try container.decodeIfPresent(ActionModel.self, forKey: .downAction) ?? ActionModel()
        leftAction = try container.decodeIfPresent(ActionModel.self, forKey: .leftAction) ?? ActionModel()
        rightAction = try container.decodeIfPresent(ActionModel.self, forKey: .rightAction) ?? ActionModel()
        labelHidden = try container.decodeIfPresent(Bool.self, forKey: .labelHidden) ?? false
        icon = try container.decodeIfPresent(String.self, forKey: .icon) ?? "bolt.fill"
        iconHidden = try container.decodeIfPresent(Bool.self, forKey: .iconHidden) ?? false
        backgroundColor = try container.decodeIfPresent(String.self, forKey: .backgroundColor) ?? "#000000"
        foregroundColor = try container.decodeIfPresent(String.self, forKey: .foregroundColor) ?? "#FFFFFF"
        backgroundOpacity = try container.decodeIfPresent(Double.self, forKey: .backgroundOpacity) ?? 1
        backgroundImageData = try container.decodeIfPresent(Data.self, forKey: .backgroundImageData) ?? Data()
        
    }
    
    public init(id: String = UUID().uuidString ,label: String = "TestLabel", interactionType : InteractionType = .button, labelHidden: Bool = false, icon : String = "bolt.fill", backgroundColor : String = "#000000", foregroundColor : String = "#FFFFFF", backgroundOpacity : Double = 0.5, iconHidden : Bool = false) {
        self.label = label
        self.id = id
        self.action = ActionModel()
        self.interactionType = interactionType
        self.secondaryAction = ActionModel()
        self.upAction = ActionModel()
        self.downAction = ActionModel()
        self.leftAction = ActionModel()
        self.rightAction = ActionModel()
        self.labelHidden = labelHidden
        self.icon = icon
        self.backgroundColor = backgroundColor
        self.foregroundColor = foregroundColor
        self.backgroundOpacity = backgroundOpacity
        self.iconHidden = iconHidden
        self.backgroundImageData = Data()
    }
    
    static var defaultValue : ExecutorModel {
        ExecutorModel(id: UUID().uuidString, label: "")
    }
}



enum ActionContextOption : Codable {
    case action
    case secondaryAction
    case upAction
    case downAction
    case leftAction
    case rightAction
    
    func correspondingActionModel(for model: ExecutorModel) -> ActionModel {
        switch self {
        case .action:
            return model.action
        case .secondaryAction:
            return model.secondaryAction
        case .upAction:
            return model.upAction
        case .downAction:
            return model.downAction
        case .leftAction:
            return model.leftAction
        case .rightAction:
            return model.rightAction
        }
    }
}

enum InteractionType : Codable {
    case button
    case knob
    case gesture
}
