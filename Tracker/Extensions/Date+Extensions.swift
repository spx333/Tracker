//
//  Date.swift
//  Tracker
//
//  Created by Сергей Петров on 24.04.2026.
//

import Foundation

extension Date {
    var trackerWeekday: Weekday {
        let weekdayNumber = Calendar.current.component(.weekday, from: self)
        return Weekday(rawValue: weekdayNumber) ?? .monday
    }
}
