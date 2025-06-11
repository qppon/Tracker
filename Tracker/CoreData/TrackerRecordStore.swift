//
//  TrackerRecordStore.swift
//  Tracker
//
//  Created by Jojo Smith on 6/8/25.
//


import CoreData
import UIKit

final class TrackerRecordStore: NSObject, NSFetchedResultsControllerDelegate {
    
    static let shared = TrackerRecordStore(context: PersistenceController.shared.context)
    private let context: NSManagedObjectContext
    private var fetchedResultsController: NSFetchedResultsController<TrackerRecordCD>!
    var completedTrackers: [TrackerRecordCD] = []
    
    var onUpdate: (() -> Void)?
    
    init(context: NSManagedObjectContext) {
        self.context = context
        super.init()
        setupFetchedResultsController()
    }
    
    private func setupFetchedResultsController() {
        let fetchRequest: NSFetchRequest<TrackerRecordCD> = TrackerRecordCD.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "date", ascending: true)]
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
            print("Ошибка загрузки записей: \(error)")
        }
    }
    
    func fetchRecords() -> [TrackerRecordCD] {
        return fetchedResultsController.fetchedObjects ?? []
    }
    
    func fetchRecords(forTracker tracker: TrackerCD) -> [TrackerRecordCD] {
        return fetchedResultsController.fetchedObjects?.filter { $0.trackerID == tracker } ?? []
    }
    
    func saveRecord(forTracker trackerId: UUID, onDate date: Date) {
        let record = TrackerRecordCD(context: context)
        record.date = date
        record.id = trackerId
        completedTrackers.append(record)
        saveContext()
    }
    
    func saveLocalRecords(completedTrackers: [TrackerRecordCD]) {
        self.completedTrackers = completedTrackers
    }
    
    func deleteRecord(completedTracker: TrackerRecord) {
        guard let completedTrackerCD = completedTrackers.first(where: { $0.id == completedTracker.id && Calendar.current.compare($0.date!, to: completedTracker.date, toGranularity: .day)  == .orderedSame }) else {
            print("[TrackerRecordStore]: Запись не удалена")
            return
        }
        context.delete(completedTrackerCD)
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

