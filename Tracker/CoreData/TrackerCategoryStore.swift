//
//  TrackerCategoryStore.swift
//  Tracker
//
//  Created by Сергей Петров on 20.05.2026.
//

import CoreData

protocol TrackerCategoryStoreDelegate: AnyObject {
    func storeDidUpdateCategories()
}

final class TrackerCategoryStore: NSObject {
    private let context: NSManagedObjectContext

    weak var delegate: TrackerCategoryStoreDelegate?

    private lazy var fetchedResultsController: NSFetchedResultsController<TrackerCategoryCoreData> = {
        let request: NSFetchRequest<TrackerCategoryCoreData> = TrackerCategoryCoreData.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: "title", ascending: true)]

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
        super.init()

        do {
            try fetchedResultsController.performFetch()
        } catch {
            print("TrackerCategoryStore performFetch error: \(error)")
        }
    }

    func addCategory(title: String) throws {
        let category = TrackerCategoryCoreData(context: context)
        category.title = title
        try context.save()
    }

    func fetchCategories() -> [TrackerCategory] {
        let objects = fetchedResultsController.fetchedObjects ?? []

        return objects.compactMap { categoryCoreData in
            guard let title = categoryCoreData.title else { return nil }

            let trackersSet = categoryCoreData.trackers as? Set<TrackerCoreData> ?? []
            let trackers = trackersSet.compactMap { TrackerStore.makeTracker(from: $0) }
                .sorted { $0.name < $1.name }

            return TrackerCategory(title: title, trackers: trackers)
        }
    }

    func findCategory(with title: String) throws -> TrackerCategoryCoreData? {
        let request: NSFetchRequest<TrackerCategoryCoreData> = TrackerCategoryCoreData.fetchRequest()
        request.predicate = NSPredicate(format: "title == %@", title)
        request.fetchLimit = 1

        let categories = try context.fetch(request)
        return categories.first
    }
}

extension TrackerCategoryStore: NSFetchedResultsControllerDelegate {
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        delegate?.storeDidUpdateCategories()
    }
}
