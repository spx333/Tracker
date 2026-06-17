//
//  EditCategoryViewModel.swift
//  Tracker
//
//  Created by Сергей Петров on 17.06.2026.
//

import Foundation

final class EditCategoryViewModel {
    private let categoryStore: TrackerCategoryStore
    private let oldTitle: String

    var onStateChanged: ((Bool) -> Void)?

    private(set) var currentText: String {
        didSet {
            onStateChanged?(isSaveButtonEnabled)
        }
    }

    var isSaveButtonEnabled: Bool {
        let trimmedText = currentText.trimmingCharacters(in: .whitespacesAndNewlines)
        return !trimmedText.isEmpty && trimmedText != oldTitle
    }

    init(categoryStore: TrackerCategoryStore, oldTitle: String) {
        self.categoryStore = categoryStore
        self.oldTitle = oldTitle
        self.currentText = oldTitle
    }

    func updateText(_ text: String) {
        currentText = text
    }

    func save() throws {
        let newTitle = currentText.trimmingCharacters(in: .whitespacesAndNewlines)
        try categoryStore.updateCategoryTitle(from: oldTitle, to: newTitle)
    }

    func initialTitle() -> String {
        oldTitle
    }
}
