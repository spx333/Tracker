//
//  Weekday.swift
//  Tracker
//
//  Created by Сергей Петров on 24.04.2026.
//

import Foundation

enum Weekday: Int, CaseIterable, Codable {
    case sunday = 1
    case monday
    case tuesday
    case wednesday
    case thursday
    case friday
    case saturday
    
    var fullName: String {
        switch self {
        case .monday: NSLocalizedString("weekday_monday", comment: "Full weekday name")
        case .tuesday: NSLocalizedString("weekday_tuesday", comment: "Full weekday name")
        case .wednesday: NSLocalizedString("weekday_wednesday", comment: "Full weekday name")
        case .thursday: NSLocalizedString("weekday_thursday", comment: "Full weekday name")
        case .friday: NSLocalizedString("weekday_friday", comment: "Full weekday name")
        case .saturday: NSLocalizedString("weekday_saturday", comment: "Full weekday name")
        case .sunday: NSLocalizedString("weekday_sunday", comment: "Full weekday name")
        }
    }
    
    var shortName: String {
        switch self {
        case .monday: NSLocalizedString("weekday_short_monday", comment: "Short weekday name")
        case .tuesday: NSLocalizedString("weekday_short_tuesday", comment: "Short weekday name")
        case .wednesday: NSLocalizedString("weekday_short_wednesday", comment: "Short weekday name")
        case .thursday: NSLocalizedString("weekday_short_thursday", comment: "Short weekday name")
        case .friday: NSLocalizedString("weekday_short_friday", comment: "Short weekday name")
        case .saturday: NSLocalizedString("weekday_short_saturday", comment: "Short weekday name")
        case .sunday: NSLocalizedString("weekday_short_sunday", comment: "Short weekday name")
        }
    }
}
