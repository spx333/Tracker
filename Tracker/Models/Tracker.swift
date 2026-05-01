//
//  Tracker.swift
//  Tracker
//
//  Created by Сергей Петров on 01.05.2026.
//

import UIKit

struct Tracker {
    let id: UUID
    let name: String
    let color: UIColor
    let emoji: String
    let schedule: [Weekday]
}
