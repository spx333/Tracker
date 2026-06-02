//
//  UserDefaultsService.swift
//  Tracker
//
//  Created by Сергей Петров on 29.05.2026.
//


import Foundation

final class UserDefaultsService {
    static let shared = UserDefaultsService()
    
    private let defaults = UserDefaults.standard
    
    private enum Key {
        static let hasSeenOnboarding = "hasSeenOnboarding"
    }
    
    private init() {}
    
    var hasSeenOnboarding: Bool {
        get { defaults.bool(forKey: Key.hasSeenOnboarding) }
        set { defaults.set(newValue, forKey: Key.hasSeenOnboarding) }
    }
}
