//
//  UIColor+Hex.swift
//  Expensee
//
//  Created by Jun Meng on 1/5/20.
//  Copyright © 2020 Jun Meng. All rights reserved.
//

import UIKit

extension UIColor {
    typealias Hex = String

    convenience init?(_ hex: Hex, alpha: CGFloat? = nil) {

        guard let hexType = Type(from: hex), let components = hexType.components() else {
            return nil
        }

        #if os(iOS) || os(watchOS) || os(tvOS)
            self.init(red: components.red, green: components.green, blue: components.blue, alpha: alpha ?? components.alpha)
        #else
            self.init(calibratedRed: components.red, green: components.green, blue: components.blue, alpha: alpha ?? components.alpha)
        #endif
    }

    static func contrast(hex: String, lightColor: UIColor, darkColor: UIColor) -> UIColor {
        guard let hexType = Type(from: hex), let components = hexType.components() else {
            return lightColor
        }

        let luminance: [CGFloat] = [components.red, components.green, components.blue].map {
            if $0 <= 0.03928 { return $0 / 12.92 }
            return pow(($0 + 0.055) / 1.055, 2.4)
        }

        let luminanceContrast = (0.2126 * luminance[0]) + (0.7152 * luminance[1]) + (0.0722 * luminance[2])
        return (luminanceContrast > 0.179) ? darkColor : lightColor
    }

    /// The string hex value representation of the current color
    var hex: Hex {
        var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0, rgb: Int
        getRed(&r, green: &g, blue: &b, alpha: &a)

        if a == 1 { // no alpha value set, we are returning the short version
            rgb = (Int)(r * 255) << 16 | (Int)(g * 255) << 8 | (Int)(b * 255) << 0
            return String(format: "#%06x", rgb)
        } else {
            rgb = (Int)(r * 255) << 24 | (Int)(g * 255) << 16 | (Int)(b * 255) << 8 | (Int)(a * 255) << 0
            return String(format: "#%08x", rgb)
        }
    }

    private enum `Type` {

        case RGBshort(rgb: Hex)
        case RGBshortAlpha(rgba: Hex)
        case RGB(rgb: Hex)
        case RGBA(rgba: Hex)

        init?(from hex: Hex) {

            var hexString = hex
            hexString.removeHashIfNecessary()

            guard let t = Type.transform(hex: hexString) else {
                return nil
            }

            self = t
        }

        static func transform(hex string: Hex) -> Type? {
            switch string.count {
            case 3:
                return .RGBshort(rgb: string)
            case 4:
                return .RGBshortAlpha(rgba: string)
            case 6:
                return .RGB(rgb: string)
            case 8:
                return .RGBA(rgba: string)
            default:
                return nil
            }
        }

        var value: Hex {
            switch self {
            case .RGBshort(let rgb):
                return rgb
            case .RGBshortAlpha(let rgba):
                return rgba
            case .RGB(let rgb):
                return rgb
            case .RGBA(let rgba):
                return rgba
            }
        }

        typealias rgbComponents = (red: CGFloat, green: CGFloat, blue: CGFloat, alpha: CGFloat)
        func components() -> rgbComponents? {

            var hexValue: UInt64 = 0
            guard Scanner(string: value).scanHexInt64(&hexValue) else {
                return nil
            }

            let r, g, b, a, divisor: CGFloat

            switch self {
            case .RGBshort(_):
                divisor = 15
                r = CGFloat((hexValue & 0xF00) >> 8) / divisor
                g = CGFloat((hexValue & 0x0F0) >> 4) / divisor
                b = CGFloat(hexValue & 0x00F) / divisor
                a = 1
            case .RGBshortAlpha(_):
                divisor = 15
                r = CGFloat((hexValue & 0xF000) >> 12) / divisor
                g = CGFloat((hexValue & 0x0F00) >> 8) / divisor
                b = CGFloat((hexValue & 0x00F0) >> 4) / divisor
                a = CGFloat(hexValue & 0x000F) / divisor
            case .RGB(_):
                divisor = 255
                r = CGFloat((hexValue & 0xFF0000) >> 16) / divisor
                g = CGFloat((hexValue & 0x00FF00) >> 8) / divisor
                b = CGFloat(hexValue & 0x0000FF) / divisor
                a = 1
            case .RGBA(_):
                divisor = 255
                r = CGFloat((hexValue & 0xFF000000) >> 24) / divisor
                g = CGFloat((hexValue & 0x00FF0000) >> 16) / divisor
                b = CGFloat((hexValue & 0x0000FF00) >> 8) / divisor
                a = CGFloat(hexValue & 0x000000FF) / divisor
            }

            return (red: r, green: g, blue: b, alpha: a)
        }
    }
}

private extension String {

    mutating func removeHashIfNecessary() {
        if hasPrefix("#") {
            self = replacingOccurrences(of: "#", with: "")
        }
    }
}
