//
//  Extensions.swift
//  GizmoDesktopMK2
//
//  Created by Matthew Sand on 2/12/25.
//

import Foundation
import CoreGraphics
import AppKit

extension CGImage {
    func resize(size: CGSize) -> CGImage? {
        let width = Int(size.width)
        let height = Int(size.height)
        let bitsPerComponent = 8
        let bytesPerPixel = 4  // Fixed for RGBA
        let bytesPerRow = width * bytesPerPixel

        let colorSpace = CGColorSpaceCreateDeviceRGB() // No need for optional binding

        guard let context = CGContext(
            data: nil,
            width: width,
            height: height,
            bitsPerComponent: bitsPerComponent,
            bytesPerRow: bytesPerRow,
            space: colorSpace, // Use colorSpace directly
            bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue
        ) else {
            print("Failed to create CGContext for resizing")
            return nil
        }

        context.interpolationQuality = .high
        context.draw(self, in: CGRect(x: 0, y: 0, width: width, height: height))

        return context.makeImage()
    }
}
