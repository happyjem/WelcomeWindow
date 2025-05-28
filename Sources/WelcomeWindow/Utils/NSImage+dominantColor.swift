//
//  File.swift
//  WelcomeWindow
//
//  Created by Giorgi Tchelidze on 29.05.25.
//

import AppKit
import CoreImage

extension NSImage {
    func dominantColor(sampleCount: Int = 1000) -> NSColor? {
        guard let cgImage = self.cgImage(forProposedRect: nil, context: nil, hints: nil) else { return nil }

        let width = cgImage.width
        let height = cgImage.height

        guard let context = CGContext(
            data: nil,
            width: width,
            height: height,
            bitsPerComponent: 8,
            bytesPerRow: width * 4,
            space: CGColorSpaceCreateDeviceRGB(),
            bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue
        ) else { return nil }

        context.draw(cgImage, in: CGRect(x: 0, y: 0, width: width, height: height))
        guard let pixelData = context.data else { return nil }

        let data = pixelData.bindMemory(to: UInt8.self, capacity: width * height * 4)
        var colorCount: [UInt32: Int] = [:]

        // swiftlint:disable identifier_name
        for _ in 0..<sampleCount {
            let x = Int.random(in: 0..<width)
            let y = Int.random(in: 0..<height)
            let offset = 4 * (y * width + x)

            let r = data[offset]
            let g = data[offset + 1]
            let b = data[offset + 2]
            let a = data[offset + 3]

            if a < 10 { continue } // skip mostly transparent pixels

            let rgb = (UInt32(r) << 16) + (UInt32(g) << 8) + UInt32(b)
            colorCount[rgb, default: 0] += 1
        }

        guard let (rgb, _) = colorCount.max(by: { $0.value < $1.value }) else { return nil }

        let r = CGFloat((rgb >> 16) & 0xFF) / 255.0
        let g = CGFloat((rgb >> 8) & 0xFF) / 255.0
        let b = CGFloat(rgb & 0xFF) / 255.0
        // swiftlint:enable identifier_name

        return NSColor(red: r, green: g, blue: b, alpha: 1.0)
    }
}
