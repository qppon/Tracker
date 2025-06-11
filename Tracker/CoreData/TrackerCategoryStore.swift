//
//  TrackerCategoryStore.swift
//  Tracker
//
//  Created by Jojo Smith on 6/8/25.
//


import CoreData

final class TrackerCategoryStore: NSObject, NSFetchedResultsControllerDelegate {
    
    static let shared = TrackerCategoryStore(context: PersistenceController.shared.context)
    
    private let context: NSManagedObjectContext
    private var fetchedResultsController: NSFetchedResultsController<TrackerCategoryCD>!
    
    var onUpdate: (() -> Void)?
    
    init(context: NSManagedObjectContext) {
        self.context = context
        super.init()
        setupFetchedResultsController()
    }
    
    private func setupFetchedResultsController() {
        let fetchRequest: NSFetchRequest<TrackerCategoryCD> = TrackerCategoryCD.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "category", ascending: true)]
        
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
            print("Ошибка загрузки категорий: \(error)")
        }
    }
    
    func fetchCategories() -> [TrackerCategoryCD] {
        return fetchedResultsController.fetchedObjects ?? []
    }
    
    func fetchCategory(byTitle category: String) -> TrackerCategoryCD? {
        return fetchedResultsController.fetchedObjects?.first(where: { $0.category == category })
    }
    
    func saveCategory(category: String) -> TrackerCategoryCD {
        let trackerCategory = TrackerCategoryCD(context: context)
        trackerCategory.category = category
        saveContext()
        return trackerCategory
    }
    
    private func saveContext() {
        do {
            try context.save()
        } catch {
            print("Ошибка при сохранении категории: \(error)")
        }
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        onUpdate?()
    }
}

