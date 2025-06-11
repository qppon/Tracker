//
//  CoreDataService.swift
//  Tracker
//
//  Created by Jojo Smith on 6/8/25.
//

import CoreData

class CoreDataService {
    static let shared = CoreDataService()
    
    private init() {}
    
    func fetchCategory(byName name: String, context: NSManagedObjectContext) -> TrackerCategoryCD? {
        let categoryFetchRequest: NSFetchRequest<TrackerCategoryCD> = TrackerCategoryCD.fetchRequest()
        categoryFetchRequest.predicate = NSPredicate(format: "category == %@", name)
        
        do {
            let categories = try context.fetch(categoryFetchRequest)
            return categories.first
        } catch {
            print("Ошибка при поиске категории: \(error)")
            return nil
        }
    }
    
    func createCategory(name: String, context: NSManagedObjectContext) -> TrackerCategoryCD {
        let newCategory = TrackerCategoryCD(context: context)
        newCategory.category = name
        return newCategory
    }
}
