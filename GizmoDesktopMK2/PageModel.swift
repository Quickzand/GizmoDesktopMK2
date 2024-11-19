//
//  PageModel.swift
//  GizmoDesktopMK2
//
//  Created by Matthew Sand on 11/7/24.
//

import Foundation

public struct PageModel: Codable {
    var id: String = UUID().uuidString
    var executors : [ExecutorModel?] = []
}
