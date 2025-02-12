//
//  AppInfoModel.swift
//  GizmoDesktopMK2
//
//  Created by Matthew Sand on 11/20/24.
//

import Foundation
import AppKit

struct AppInfoModel : Codable, Hashable {
    let name : String
    let bundleID: String
    var appIcon : CGImage? = nil
    var associatedPageIDs : [String : Bool]
    
    enum CodingKeys: CodingKey {
        case name
        case bundleID
        case associatedPageIDs
    }
    
    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.name = try container.decode(String.self, forKey: .name)
        self.bundleID = try container.decode(String.self, forKey: .bundleID)
        self.associatedPageIDs = try container.decode([String : Bool].self, forKey: .associatedPageIDs)
    }
    
    init (name: String, bundleID: String, associatedPageIDs: [String : Bool] = [:]) {
        self.name = name
        self.bundleID = bundleID
        self.associatedPageIDs = associatedPageIDs
    }
    
}
