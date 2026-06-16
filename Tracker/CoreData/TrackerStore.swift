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
    
    func deleteTracker(with id: UUID) throws {
        let trackerRequest: NSFetchRequest<TrackerCoreData> = TrackerCoreData.fetchRequest()
        trackerRequest.predicate = NSPredicate(format: "id == %@", id as CVarArg)
        trackerRequest.fetchLimit = 1

        guard let trackerCoreData = try context.fetch(trackerRequest).first else {
            return
        }

        let recordRequest: NSFetchRequest<TrackerRecordCoreData> = TrackerRecordCoreData.fetchRequest()
        recordRequest.predicate = NSPredicate(format: "tracker.id == %@", id as CVarArg)
        let records = try context.fetch(recordRequest)

        records.forEach { context.delete($0) }
        context.delete(trackerCoreData)

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
    
    func updateTracker(
        with id: UUID,
        newTracker: Tracker,
        categoryTitle: String
    ) throws {
        let request: NSFetchRequest<TrackerCoreData> = TrackerCoreData.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", id as CVarArg)
        request.fetchLimit = 1

        let trackers = try context.fetch(request)

        guard let trackerCoreData = trackers.first else { return }

        trackerCoreData.name = newTracker.name
        trackerCoreData.emoji = newTracker.emoji
        trackerCoreData.color = newTracker.color.hexString
        trackerCoreData.setValue(newTracker.schedule, forKey: "schedule")

        let category: TrackerCategoryCoreData
        if let existingCategory = try categoryStore.findCategory(with: categoryTitle) {
            category = existingCategory
        } else {
            let newCategory = TrackerCategoryCoreData(context: context)
            newCategory.title = categoryTitle
            category = newCategory
        }

        trackerCoreData.category = category

        try context.save()
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
