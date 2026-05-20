//
//  TrackerStore.swift
//  Tracker
//
//  Created by Сергей Петров on 20.05.2026.
//

import CoreData
import UIKit

protocol TrackerStoreDelegate: AnyObject {
    func storeDidUpdateTrackers()
}

final class TrackerStore: NSObject {
    private let context: NSManagedObjectContext
    private let categoryStore: TrackerCategoryStore

    weak var delegate: TrackerStoreDelegate?

    private lazy var fetchedResultsController: NSFetchedResultsController<TrackerCoreData> = {
        let request: NSFetchRequest<TrackerCoreData> = TrackerCoreData.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]

        let controller = NSFetchedResultsController(
            fetchRequest: request,
            managedObjectContext: context,
            sectionNameKeyPath: nil,
            cacheName: nil
        )
        controller.delegate = self
        return controller
    }()

    init(context: NSManagedObjectContext) {
        self.context = context
        self.categoryStore = TrackerCategoryStore(context: context)
        super.init()

        do {
            try fetchedResultsController.performFetch()
        } catch {
            print("TrackerStore performFetch error: \(error)")
        }
    }

    func addTracker(_ tracker: Tracker, categoryTitle: String) throws {
        let trackerCoreData = TrackerCoreData(context: context)
        trackerCoreData.id = tracker.id
        trackerCoreData.name = tracker.name
        trackerCoreData.emoji = tracker.emoji
        trackerCoreData.color = tracker.color.hexString
        trackerCoreData.setValue(tracker.schedule, forKey: "schedule")

        let category: TrackerCategoryCoreData
        if let existingCategory = try categoryStore.findCategory(with: categoryTitle) {
            category = existingCategory
        } else {
            let newCategory = TrackerCategoryCoreData(context: context)
            newCategory.title = categoryTitle
            category = newCategory
        }

        trackerCoreData.category = category

        do {
            try context.save()
        } catch {
            context.rollback()
            throw error
        }
    }

    func fetchTrackers() -> [Tracker] {
        let objects = fetchedResultsController.fetchedObjects ?? []
        return objects.compactMap(Self.makeTracker(from:))
    }

    static func makeTracker(from trackerCoreData: TrackerCoreData) -> Tracker? {
        guard
            let id = trackerCoreData.id,
            let name = trackerCoreData.name,
            let emoji = trackerCoreData.emoji,
            let colorHex = trackerCoreData.color,
            let color = UIColor(hexString: colorHex),
            let schedule = trackerCoreData.value(forKey: "schedule") as? [Weekday]
        else {
            return nil
        }

        return Tracker(
            id: id,
            name: name,
            color: color,
            emoji: emoji,
            schedule: schedule
        )
    }
}

extension TrackerStore: NSFetchedResultsControllerDelegate {
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        delegate?.storeDidUpdateTrackers()
    }
}
