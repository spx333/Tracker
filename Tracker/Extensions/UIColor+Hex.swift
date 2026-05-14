//
//  UIColor+Hex.swift
//  Tracker
//
//  Created by Сергей Петров on 14.05.2026.
//

import UIKit

extension UIColor {
    var hexString: String? {
        let resolved = resolvedColor(with: UITraitCollection.current)
        guard let components = resolved.cgColor.components else { return nil }

        let r, g, b: CGFloat

        if components.count >= 3 {
            r = components[0]
            g = components[1]
            b = components[2]
        } else if components.count == 2 {
            r = components[0]
            g = components[0]
            b = components[0]
        } else {
            return nil
        }

        return String(
            format: "#%02lX%02lX%02lX",
            lround(Double(r * 255)),
            lround(Double(g * 255)),
            lround(Double(b * 255))
        )
    }

    convenience init?(hexString: String) {
        let hex = hexString.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        guard hex.count == 6, let int = UInt32(hex, radix: 16) else { return nil }

        let r = CGFloat((int >> 16) & 0xFF) / 255
        let g = CGFloat((int >> 8) & 0xFF) / 255
        let b = CGFloat(int & 0xFF) / 255

        self.init(red: r, green: g, blue: b, alpha: 1)
    }
}
