//
//  AppDelegate.swift
//  Tracker
//
//  Created by Сергей Петров on 23.04.2026.
//

import UIKit
import AppMetricaCore

@main
final class AppDelegate: UIResponder, UIApplicationDelegate {
    
    lazy var coreDataStack = CoreDataStack()
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        if let configuration = AppMetricaConfiguration(apiKey: "9dba7c63-5fd2-433a-9200-cde5e168a84d") {
             AppMetrica.activate(with: configuration)
         }
        return true
    }
    
    // MARK: UISceneSession Lifecycle
    
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }
    
}
