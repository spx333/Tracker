//
//  TrackerRecordStore.swift
//  Tracker
//
//  Created by Сергей Петров on 20.05.2026.
//

import CoreData

protocol TrackerRecordStoreDelegate: AnyObject {
    func storeDidUpdateRecords()
}

final class TrackerRecordStore: NSObject {
    private let context: NSManagedObjectContext

    weak var delegate: TrackerRecordStoreDelegate?

    private lazy var fetchedResultsController: NSFetchedResultsController<TrackerRecordCoreData> = {
        let request: NSFetchRequest<TrackerRecordCoreData> = TrackerRecordCoreData.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: "date", ascending: true)]

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
            print("TrackerRecordStore performFetch error: \(error)")
        }
    }

    func addRecord(_ record: TrackerRecord) throws {
        let trackerRequest: NSFetchRequest<TrackerCoreData> = TrackerCoreData.fetchRequest()
        trackerRequest.predicate = NSPredicate(format: "id == %@", record.trackerID as CVarArg)
        trackerRequest.fetchLimit = 1

        let trackers = try context.fetch(trackerRequest)

        guard let trackerCoreData = trackers.first else { return }

        let recordCoreData = TrackerRecordCoreData(context: context)
        recordCoreData.date = record.date
        recordCoreData.tracker = trackerCoreData

        try context.save()
    }

    func deleteRecord(trackerID: UUID, date: Date) throws {
        let request: NSFetchRequest<TrackerRecordCoreData> = TrackerRecordCoreData.fetchRequest()
        request.predicate = NSPredicate(
            format: "tracker.id == %@ AND date == %@",
            trackerID as CVarArg,
            date as NSDate
        )
        request.fetchLimit = 1

        let records = try context.fetch(request)

        guard let record = records.first else { return }

        context.delete(record)
        try context.save()
    }

    func fetchRecords() -> [TrackerRecord] {
        let objects = fetchedResultsController.fetchedObjects ?? []

        return objects.compactMap { recordCoreData in
            guard
                let date = recordCoreData.date,
                let trackerID = recordCoreData.tracker?.id
            else {
                return nil
            }

            return TrackerRecord(trackerID: trackerID, date: date)
        }
    }
}

extension TrackerRecordStore: NSFetchedResultsControllerDelegate {
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        delegate?.storeDidUpdateRecords()
    }
}
