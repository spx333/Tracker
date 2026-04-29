//
//  ViewController.swift
//  Tracker
//
//  Created by Сергей Петров on 23.04.2026.
//

import UIKit

final class RootTabBarController: UITabBarController {

    override func viewDidLoad() {
            super.viewDidLoad()
            setupTabs()
        }

        private func setupTabs() {
            let trackersVC = TrackersViewController()
            let statisticsVC = StatisticsViewController()

            let trackersNav = UINavigationController(rootViewController: trackersVC)

            trackersNav.tabBarItem = UITabBarItem(
                title: "Трекеры",
                image: UIImage(resource: .trackers),
                selectedImage: nil
            )
          
            statisticsVC.tabBarItem = UITabBarItem(
                title: "Статистика",
                image: UIImage(resource: .stats),
                selectedImage: nil
            )

            viewControllers = [trackersNav, statisticsVC]
        }
}
