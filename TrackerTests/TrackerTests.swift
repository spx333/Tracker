//
//  TrackerTests.swift
//  TrackerTests
//
//  Created by Сергей Петров on 23.04.2026.
//

import SnapshotTesting
import XCTest
@testable import Tracker

final class TrackerTests: XCTestCase {
    
    override func setUp() {
            super.setUp()
            isRecording = false
        }
    
    func testTrackersViewControllerLight() {
        
        let coreDataStack = CoreDataStack()
        let trackerCategoryStore = TrackerCategoryStore(context: coreDataStack.context)
        let trackerStore = TrackerStore(context: coreDataStack.context)
        let trackerRecordStore = TrackerRecordStore(context: coreDataStack.context)

        let viewController = TrackersViewController(
            trackerStore: trackerStore,
            trackerCategoryStore: trackerCategoryStore,
            trackerRecordStore: trackerRecordStore
        )

        let navigationController = UINavigationController(rootViewController: viewController)

        assertSnapshot(
            of: navigationController,
            as: .image(traits: .init(userInterfaceStyle: .light))
        )
    }
    
    func testTrackersViewControllerDark() {
        let coreDataStack = CoreDataStack()
        let trackerCategoryStore = TrackerCategoryStore(context: coreDataStack.context)
        let trackerStore = TrackerStore(context: coreDataStack.context)
        let trackerRecordStore = TrackerRecordStore(context: coreDataStack.context)

        let viewController = TrackersViewController(
            trackerStore: trackerStore,
            trackerCategoryStore: trackerCategoryStore,
            trackerRecordStore: trackerRecordStore
        )

        let navigationController = UINavigationController(rootViewController: viewController)

        assertSnapshot(
            of: navigationController,
            as: .image(traits: .init(userInterfaceStyle: .dark))
        )
    }
}
