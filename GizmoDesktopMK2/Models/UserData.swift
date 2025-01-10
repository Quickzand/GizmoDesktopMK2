//
//  UserData.swift
//  GizmoDesktopMK2
//
//  Created by Matthew Sand on 11/7/24.
//

import Foundation

struct UserData : Codable{
    var actions : [ActionModel] = [] {
        didSet {
            save()
        }
    }
    var pages : [PageModel] = [PageModel(), PageModel()] {
        didSet {
            save()
        }
    }
    
    var rememberedApps : [AppInfoModel] = [] {
        didSet {
            save()
        }
    }
    
    // Save settings to UserDefaults
    func save() {
        if let encoded = try? JSONEncoder().encode(self) {
            UserDefaults.standard.set(encoded, forKey: "userData")
        }
    }

    // Load settings from UserDefaults
    static func load() -> UserData {
        if let savedData = UserDefaults.standard.data(forKey: "userData"),
           let decoded = try? JSONDecoder().decode(UserData.self, from: savedData) {
            var loadedData = decoded
            if loadedData.pages.isEmpty {
                loadedData.pages.append(PageModel())
            }
//            print("Loaded user data " + String(describing: loadedData))
            return loadedData
        }
        return UserData() // Return default settings if none are saved
    }
}
