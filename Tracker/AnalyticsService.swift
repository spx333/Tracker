//
//  AnalyticsService.swift
//  Tracker
//
//  Created by Сергей Петров on 18.06.2026.
//

import Foundation
import AppMetricaCore

protocol AnalyticsServiceProtocol {
    func report(event: AnalyticsEvent, screen: AnalyticsScreen, item: AnalyticsItem?)
}

enum AnalyticsEvent: String {
    case open
    case close
    case click
}

enum AnalyticsScreen: String {
    case main = "Main"
}

enum AnalyticsItem: String {
    case addTrack = "add_track"
    case track
    case filter
    case edit
    case delete
}

final class AnalyticsService: AnalyticsServiceProtocol {
    private let eventName = "tracker_event"

    func report(event: AnalyticsEvent, screen: AnalyticsScreen, item: AnalyticsItem?) {
        var parameters: [String: String] = [
            "event": event.rawValue,
            "screen": screen.rawValue
        ]

        if let item {
            parameters["item"] = item.rawValue
        }

        #if DEBUG
        print("ANALYTICS EVENT: \(parameters)")
        #endif

        AppMetrica.reportEvent(
            name: eventName,
            parameters: parameters,
            onFailure: { error in
                #if DEBUG
                print("Failed to report event: \(error.localizedDescription)")
                #endif
            }
        )
    }
}
