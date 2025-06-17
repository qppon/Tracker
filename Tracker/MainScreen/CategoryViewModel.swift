//
//  CategoryViewModel.swift
//  Tracker
//
//  Created by Jojo Smith on 6/15/25.
//

import Foundation

typealias CategoryBinding<T> = (T) -> Void

protocol CategoryViewModelProtocol {
    var categoriesChanged: CategoryBinding<[String]>? { get set }
    
    func numberOfCategories() -> Int
    func getCategory(at indexPath: IndexPath) -> String?
    func deleteCategory(at indexPath: IndexPath)
    func createCategory(_ category: TrackerCategory)
    func updateCategory(category: TrackerCategory, newCategoryName: String)
}

final class CategoryViewModel: CategoryViewModelProtocol {
    var categoriesChanged: CategoryBinding<[String]>?
    
    private var categories: [String]
    
    private let categoryStore = TrackerCategoryStore.shared
    
    init() {
        let fetchedCategories = categoryStore.fetchCategories()
        categories = fetchedCategories.compactMap { $0.category }
    }
    
    func numberOfCategories() -> Int {
        categories.count
    }
    
    func getCategory(at indexPath: IndexPath) -> String? {
        categories[indexPath.row]
    }
    
    func deleteCategory(at indexPath: IndexPath) {
        let categoryName = categories.remove(at: indexPath.row)
        categoryStore.deleteCategory(categoryName: categoryName)
        categoriesChanged?(categories)
    }
    
    func createCategory(_ category: TrackerCategory) {
        categoryStore.saveCategory(category: category.category)
        categories.append(category.category)
        categoriesChanged?(categories)
    }
    
    func updateCategory(category: TrackerCategory, newCategoryName: String) {
        guard let categoryIndex = categories.firstIndex(of: category.category) else {
            print("Категория не найдена")
            return
        }
        categories[categoryIndex] = newCategoryName
        categoryStore.updateCategory(categoryName: category.category, newCategoryName: newCategoryName)
        categoriesChanged?(categories)
    }
}
