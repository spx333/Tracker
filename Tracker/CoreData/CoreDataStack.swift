//
//  CoreDataStack.swift
//  Tracker
//
//  Created by Сергей Петров on 20.05.2026.
//

import CoreData

final class CoreDataStack {
    let persistentContainer: NSPersistentContainer

    var context: NSManagedObjectContext {
        persistentContainer.viewContext
    }

    init() {
        DaysValueTransformer.register()

        persistentContainer = NSPersistentContainer(name: "TrackerModel")
        persistentContainer.loadPersistentStores { _, error in
            if let error {
                assertionFailure("Failed to load persistent stores: \(error)")
            }
        }
    }

    func saveContext() throws {
        if context.hasChanges {
            try context.save()
        }
    }
}
