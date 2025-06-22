//
//  TrackersStore.swift
//  Tracker
//
//  Created by Jojo Smith on 6/8/25.
//

import CoreData

final class TrackerStore: NSObject, NSFetchedResultsControllerDelegate {
    static let shared = TrackerStore(context: PersistenceController.shared.context)
    
    private let context: NSManagedObjectContext
    private var fetchedResultsController: NSFetchedResultsController<TrackerCD>!
    
    var onUpdate: (() -> Void)?
    
    init(context: NSManagedObjectContext) {
        self.context = context
        super.init()
        setupFetchedResultsController()
    }
    
    private func setupFetchedResultsController() {
        let fetchRequest: NSFetchRequest<TrackerCD> = TrackerCD.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]
        
        fetchedResultsController = NSFetchedResultsController(
            fetchRequest: fetchRequest,
            managedObjectContext: context,
            sectionNameKeyPath: nil,
            cacheName: nil
        )
        
        fetchedResultsController.delegate = self
        
        do {
            try fetchedResultsController.performFetch()
        } catch {
            print("Ошибка TrackerStore: \(error)")
        }
    }
    
    func getTrackers() -> [TrackerCD] {
        return fetchedResultsController.fetchedObjects ?? []
    }
    
    func saveTracker(name: String, color: String, emoji: String, calendarData: Data, category: TrackerCategoryCD?, isCompleted: Bool) {
        let newTracker = TrackerCD(context: context)
        newTracker.id = UUID()
        newTracker.name = name
        newTracker.color = color
        newTracker.emoji = emoji
        newTracker.calendar = calendarData as NSData
        newTracker.category = category
        
        saveContext()
    }
    
    func togleIsPined(trackerID: UUID) {
        let fetchRequest: NSFetchRequest<TrackerCD> = TrackerCD.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %@", trackerID as CVarArg)
        do {
            let tracker = try context.fetch(fetchRequest)
            if let trackerCD = tracker.first {
                trackerCD.isPined.toggle()
            }
        } catch {
            print("ошибка при закреплении или откреплении трекера")
            return
        }
        saveContext()
    }
    
    func deleteTracker(trackerID: UUID) {
        let fetchRequest: NSFetchRequest<TrackerCD> = TrackerCD.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %@", trackerID as CVarArg)
        do {
            let tracker = try context.fetch(fetchRequest)
            if let trackerCD = tracker.first {
                context.delete(trackerCD)
            }
        } catch {
            print("ошибка при удалении трекера")
            return
        }
        
        saveContext()
    }
    
    private func saveContext() {
        do {
            try context.save()
        } catch {
            print("Ошибка при сохранении контекста: \(error)")
        }
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        onUpdate?()
    }
}
