//
//  SceneDelegate.swift
//  Tracker
//
//  Created by Сергей Петров on 23.04.2026.
//

import UIKit

private enum UserDefaultsKeys {
    static let hasSeenOnboarding = "hasSeenOnboarding"
}

final class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    
    var window: UIWindow?
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard
            let windowScene = scene as? UIWindowScene,
            let appDelegate = UIApplication.shared.delegate as? AppDelegate
        else {
            return
        }
        
        let context = appDelegate.coreDataStack.context
        
        let trackerStore = TrackerStore(context: context)
        let trackerCategoryStore = TrackerCategoryStore(context: context)
        let trackerRecordStore = TrackerRecordStore(context: context)
        
        let window = UIWindow(windowScene: windowScene)
        
        let hasSeenOnboarding = UserDefaults.standard.bool(forKey: UserDefaultsKeys.hasSeenOnboarding)
        
        if hasSeenOnboarding {
            window.rootViewController = RootTabBarController(
                trackerStore: trackerStore,
                trackerCategoryStore: trackerCategoryStore,
                trackerRecordStore: trackerRecordStore
            )
        } else {
            let onboardingViewController = OnboardingViewController()
            
            onboardingViewController.onFinish = {
                UserDefaults.standard.set(true, forKey: UserDefaultsKeys.hasSeenOnboarding)
                window.rootViewController = RootTabBarController(
                    trackerStore: trackerStore,
                    trackerCategoryStore: trackerCategoryStore,
                    trackerRecordStore: trackerRecordStore
                )
            }
            
            window.rootViewController = onboardingViewController
        }
        
        self.window = window
        window.makeKeyAndVisible()
        
    }
}

