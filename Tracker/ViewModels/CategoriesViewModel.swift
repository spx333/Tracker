//
//  CategoriesViewModel.swift
//  Tracker
//
//  Created by Сергей Петров on 29.05.2026.
//

import Foundation

final class CategoriesViewModel: NSObject {
    
    var onCategoriesChanged: (() -> Void)?
    var onPlaceholderVisibilityChanged: ((Bool) -> Void)?
    var onCategorySelected: ((String) -> Void)?
    
    let categoryStore: TrackerCategoryStore
    private var categories: [TrackerCategory] = []
    private(set) var selectedCategoryTitle: String?
    
    init(categoryStore: TrackerCategoryStore, selectedCategoryTitle: String? = nil) {
        self.categoryStore = categoryStore
        self.selectedCategoryTitle = selectedCategoryTitle
        super.init()
        self.categoryStore.delegate = self
    }
    
    func loadCategories() {
        categories = categoryStore.fetchCategories()
        onCategoriesChanged?()
        onPlaceholderVisibilityChanged?(categories.isEmpty)
    }
    
    func numberOfRows() -> Int {
        categories.count
    }
    
    func titleForCategory(at index: Int) -> String {
        categories[index].title
    }
    
    func isCategorySelected(at index: Int) -> Bool {
        categories[index].title == selectedCategoryTitle
    }
    
    func selectCategory(at index: Int) {
        selectedCategoryTitle = categories[index].title
        onCategoriesChanged?()
        
        if let selectedCategoryTitle {
            onCategorySelected?(selectedCategoryTitle)
        }
    }
}

extension CategoriesViewModel: TrackerCategoryStoreDelegate {
    func storeDidUpdateCategories() {
        loadCategories()
    }
}
