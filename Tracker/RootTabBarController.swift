//
//  ViewController.swift
//  Tracker
//
//  Created by Сергей Петров on 23.04.2026.
//

import UIKit

final class RootTabBarController: UITabBarController {
    
    private var topDivider: UIView?
    
    private let trackerStore: TrackerStore
    private let trackerCategoryStore: TrackerCategoryStore
    private let trackerRecordStore: TrackerRecordStore

    init(
        trackerStore: TrackerStore,
        trackerCategoryStore: TrackerCategoryStore,
        trackerRecordStore: TrackerRecordStore
    ) {
        self.trackerStore = trackerStore
        self.trackerCategoryStore = trackerCategoryStore
        self.trackerRecordStore = trackerRecordStore
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        nil
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTabs()
        addTopDividerToBar()

    }
    
    private func setupTabs() {
        let trackersVC = TrackersViewController(
            trackerStore: trackerStore,
            trackerCategoryStore: trackerCategoryStore,
            trackerRecordStore: trackerRecordStore
        )
        
        let statisticsVC = StatisticsViewController()
        
        let trackersNav = UINavigationController(rootViewController: trackersVC)
        
        trackersNav.tabBarItem = UITabBarItem(
            title: NSLocalizedString("trackers_title", comment: "Trackers tab title"),
            image: UIImage(resource: .trackers),
            selectedImage: nil,
        )
        
        statisticsVC.tabBarItem = UITabBarItem(
            title: NSLocalizedString("statistics_title", comment: "Statistics tab title"),
            image: UIImage(resource: .stats),
            selectedImage: nil
        )
        
        tabBar.tintColor = .trackerBlue
        viewControllers = [trackersNav, statisticsVC]
    }
    
    private func addTopDividerToBar() {
        let divider = UIView()
        divider.backgroundColor = .trackerGray
        divider.translatesAutoresizingMaskIntoConstraints = false
        
        tabBar.addSubview(divider)
        
        NSLayoutConstraint.activate([
            divider.topAnchor.constraint(equalTo: tabBar.topAnchor),
            divider.leadingAnchor.constraint(equalTo: tabBar.leadingAnchor),
            divider.trailingAnchor.constraint(equalTo: tabBar.trailingAnchor),
            divider.heightAnchor.constraint(equalToConstant: 1 / UIScreen.main.scale)
        ])
        
        topDivider = divider
    }
}
