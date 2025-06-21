//
//  TrackerCategoryStore.swift
//  Tracker
//
//  Created by Jojo Smith on 6/8/25.
//


import CoreData

final class TrackerCategoryStore: NSObject, NSFetchedResultsControllerDelegate {
    
    // MARK: - Singleton
    
    static let shared = TrackerCategoryStore(context: PersistenceController.shared.context)
    
    // MARK: - Properties
    
    private let context: NSManagedObjectContext
    private var fetchedResultsController: NSFetchedResultsController<TrackerCategoryCD>!
    
    var onUpdate: (() -> Void)?
    
    // MARK: - Init
    
    init(context: NSManagedObjectContext) {
        self.context = context
        super.init()
        setupFetchedResultsController()
    }
    
    // MARK: - Public Methods
    
    func fetchCategories() -> [TrackerCategoryCD] {
        return fetchedResultsController.fetchedObjects ?? []
    }
    
    func fetchCategory(byTitle category: String) -> TrackerCategoryCD? {
        return fetchedResultsController.fetchedObjects?.first(where: { $0.category == category })
    }
    
    func saveCategory(category: String) {
        let trackerCategory = TrackerCategoryCD(context: context)
        trackerCategory.category = category
        trackerCategory.trackers = []
        saveContext()
    }
    
    func deleteCategory(categoryName: String) {
        guard let trackerCategory = CoreDataService.shared.fetchCategory(byName: categoryName, context: context) else {
            print("[TrackerCategoryStore]: ошибка в deleteCategory")
            return
        }
        if let trackers = trackerCategory.trackers as? Set<TrackerCD> {
            trackers.forEach {
                context.delete($0)
            }
        }
        context.delete(trackerCategory)
        saveContext()
    }
    
    func updateCategory(categoryName: String, newCategoryName: String) {
        guard let trackerCategory = CoreDataService.shared.fetchCategory(byName: categoryName, context: context) else {
            print("[TrackerCategoryStore]: ошибка в updateCategory")
            return
        }
        trackerCategory.category = newCategoryName
        saveContext()
    }
    
    // MARK: - Private Methods
    
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
    
    private func saveContext() {
        do {
            try context.save()
        } catch {
            print("Ошибка при сохранении категории: \(error)")
        }
    }
    
    // MARK: - NSFetchedResultsControllerDelegate
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        onUpdate?()
    }
}

