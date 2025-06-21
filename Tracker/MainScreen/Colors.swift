//
//  Colors.swift
//  Tracker
//
//  Created by Jojo Smith on 6/18/25.
//

import UIKit

final class Colors {
    let viewBackgroundColor = UIColor { (traits: UITraitCollection) -> UIColor in
        if traits.userInterfaceStyle == .light {
            return .white
        } else {
            return .ypBlack
        }
    }
    
    let labelColor = UIColor { (traits: UITraitCollection) -> UIColor in
        if traits.userInterfaceStyle == .light {
            return .ypBlack
        } else {
            return .white
        }
    }
}
