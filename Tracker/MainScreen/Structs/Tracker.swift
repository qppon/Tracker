//
//  Tracker.swift
//  Tracker
//
//  Created by Jojo Smith on 3/10/25.
//

import UIKit

struct Tracker {
    let id: UUID
    let name: String
    let color: UIColor
    let emoji: String
    let calendar: [Weekday]?
    let date: Date?
    var isPined: Bool
    var category: String
}
