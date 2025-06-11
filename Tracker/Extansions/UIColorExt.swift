//
//  UIColorExt.swift
//  Tracker
//
//  Created by Jojo Smith on 6/5/25.
//

import UIKit

extension UIColor {
    
    func toHex() -> String {
        guard let components = self.cgColor.components else { return "#FFFFFF" }
        let red = components[0]
        let green = components[1]
        let blue = components.count > 2 ? components[2] : components[0]
        let alpha = components.count > 3 ? components[3] : 1.0
        
        return String(format: "#%02X%02X%02X", Int(red * 255), Int(green * 255), Int(blue * 255))
    }
    
    static func fromHex(hex: String) -> UIColor {
        var hexSanitized = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        if hexSanitized.hasPrefix("#") {
            hexSanitized.remove(at: hexSanitized.startIndex)
        }
        
        if hexSanitized.count == 6 {
            var rgb: UInt64 = 0
            Scanner(string: hexSanitized).scanHexInt64(&rgb)
            
            let red = CGFloat((rgb & 0xFF0000) >> 16) / 255.0
            let green = CGFloat((rgb & 0x00FF00) >> 8) / 255.0
            let blue = CGFloat(rgb & 0x0000FF) / 255.0
            
            return UIColor(red: red, green: green, blue: blue, alpha: 1.0)
        }
        
        return UIColor.white
    }
}
