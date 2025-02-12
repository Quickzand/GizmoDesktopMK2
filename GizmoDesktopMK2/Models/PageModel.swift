//
//  Page.swift
//  GizmoMK2
//
//  Created by Matthew Sand on 11/7/24.
//

import Foundation

let colCount = 3
let rowCount = 7


struct PageModel : Identifiable, Codable {
    var id: String
    var executors : [ExecutorModel?]
    var name : String
    var nameVisible : Bool
    var backgroundType : PageBackgroundType
    var backgroundColor : String
    var primaryAccentColor : String
    var secondaryAccentColor : String
    var tertiaryAccentColor : String
    
    
    
    
    enum CodingKeys: String, CodingKey {
        case id
        case executors
        case name
        case nameVisible
        case backgroundType
        case backgroundColor
        case primaryAccentColor
        case secondaryAccentColor
        case tertiaryAccentColor
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decodeIfPresent(String.self, forKey: .id) ?? "DefaultID" // Provide a default or handle missing id
        name = try container.decodeIfPresent(String.self, forKey: .name) ?? "DefaultName"
        nameVisible = try container.decodeIfPresent(Bool.self, forKey: .nameVisible) ?? true
        executors = try container.decodeIfPresent([ExecutorModel?].self, forKey: .executors) ?? []
        backgroundType = try container.decodeIfPresent(PageBackgroundType.self, forKey: .backgroundType) ?? .mesh
        backgroundColor = try container.decodeIfPresent(String.self, forKey: .backgroundColor) ?? "#000000"
        primaryAccentColor = try container.decodeIfPresent(String.self, forKey: .primaryAccentColor) ?? "#00B06E"
        secondaryAccentColor = try container.decodeIfPresent(String.self, forKey: .secondaryAccentColor) ?? "#0078AE"
        tertiaryAccentColor = try container.decodeIfPresent(String.self, forKey: .tertiaryAccentColor) ?? "#9300B3"
    }
    
    public init(name : String = "DefaultName", executors : [ExecutorModel?] = []) {
        self.id = UUID().uuidString
        self.name = name
        self.executors = executors
        self.nameVisible = true
        self.backgroundType = .mesh
        self.backgroundColor = "#000000"
        self.primaryAccentColor = "#00B06E"
        self.secondaryAccentColor = "#0078AE"
        self.tertiaryAccentColor = "#9300B3"
    }
    
    func getExecutor(withId executorId: String) -> ExecutorModel? {
        return executors.first { $0?.id == executorId } ?? nil
    }
    
    
    //    Adjusts the executors count and makes sure that if the array is not colCount * rowCount length, the rest gets filled with nils
    static func adjustExecutors(page : PageModel) -> PageModel {
        var temp  = page
        while(temp.executors.count < colCount * rowCount) {
            temp.executors.append(nil)
        }
        return temp
    }
}


enum PageBackgroundType : String, Codable, CaseIterable, Identifiable, Hashable {
    case color = "Color"
    case mesh = "Mesh"
    case image = "Image"
    
    var id : Self {self}
}

