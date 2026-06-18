//
//  TrackersViewController.swift
//  Tracker
//
//  Created by Сергей Петров on 24.04.2026.
//

import UIKit

final class TrackersViewController: UIViewController {
    
    private let trackerStore: TrackerStore
    private let trackerCategoryStore: TrackerCategoryStore
    private let trackerRecordStore: TrackerRecordStore
    
    private let analyticsService: AnalyticsServiceProtocol = AnalyticsService()
    
    private var visibleCategories: [TrackerCategory] = []
    private var searchText: String = ""
    
    var categories: [TrackerCategory] = []
    var completedTrackers: [TrackerRecord] = []
    private var currentDate: Date = Date()
    
    private var selectedFilter: TrackerFilter = .all
    
    private let searchBar: UISearchBar = {
        let searchBar = UISearchBar()
        searchBar.translatesAutoresizingMaskIntoConstraints = false
        searchBar.placeholder = NSLocalizedString("search_placeholder", comment: "Search bar placeholder")
        searchBar.searchBarStyle = .minimal
        
        if #available(iOS 13.0, *) {
            searchBar.searchTextField.backgroundColor = .trackerBackground
            searchBar.searchTextField.clipsToBounds = true
        }
        
        return searchBar
    }()
    
    private let placeholderImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(resource: .star)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let placeholderLabel: UILabel = {
        let label = UILabel()
        label.text = NSLocalizedString("trackers_placeholder", comment: "Empty trackers placeholder")
        label.font = .systemFont(ofSize: 12, weight: .medium)
        label.textColor = .label
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var plusButtonView: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "plus"), for: .normal)
        button.tintColor = .label
        button.frame = CGRect(x: 0, y: 0, width: 24, height: 24)
        button.addTarget(self, action: #selector(addTrackerButtonTapped), for: .touchUpInside)
        return button
    }()
    
    private let datePicker: UIDatePicker = {
        let picker = UIDatePicker()
        picker.datePickerMode = .date
        picker.preferredDatePickerStyle = .compact
        picker.locale = Locale(identifier: "ru_RU")
        picker.tintColor = .trackerBlue
        return picker
    }()
    
    private let collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.backgroundColor = .trackerWhite
        return collectionView
    }()
    
    private lazy var filtersButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle(NSLocalizedString("filters_button", comment: "Filters button title"), for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = UIColor.systemBlue
        button.layer.cornerRadius = 16
        button.translatesAutoresizingMaskIntoConstraints = false
        button.contentEdgeInsets = UIEdgeInsets(top: 12, left: 16, bottom: 12, right: 16)
        button.addTarget(self, action: #selector(filtersButtonTapped), for: .touchUpInside)
        return button
    }()
    
    init(
        trackerStore: TrackerStore,
        trackerCategoryStore: TrackerCategoryStore,
        trackerRecordStore: TrackerRecordStore
    ) {
        self.trackerStore = trackerStore
        self.trackerCategoryStore = trackerCategoryStore
        self.trackerRecordStore = trackerRecordStore
        super.init(nibName: nil, bundle: nil)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        nil
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        trackerStore.delegate = self
        trackerCategoryStore.delegate = self
        trackerRecordStore.delegate = self
        
        setupUI()
        setupNavigationBar()
        
        setupTapToDismissKeyboard()
        
        loadData()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        analyticsService.report(event: .open, screen: .main, item: nil)
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        analyticsService.report(event: .close, screen: .main, item: nil)
    }
    
    private func loadData() {
        categories = trackerCategoryStore.fetchCategories()
        completedTrackers = trackerRecordStore.fetchRecords()
        applyFilters()
    }
    
    private func setupUI() {
        view.backgroundColor = .trackerWhite
        
        view.addSubview(searchBar)
        view.addSubview(placeholderImageView)
        view.addSubview(placeholderLabel)
        view.addSubview(collectionView)
        view.addSubview(filtersButton)
        
        NSLayoutConstraint.activate([
            
            collectionView.topAnchor.constraint(equalTo: searchBar.bottomAnchor, constant: 16),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            searchBar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            searchBar.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            searchBar.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            
            placeholderImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            placeholderImageView.centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor),
            
            placeholderLabel.topAnchor.constraint(equalTo: placeholderImageView.bottomAnchor, constant: 8),
            placeholderLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            filtersButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            filtersButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            filtersButton.heightAnchor.constraint(equalToConstant: 50)
        ])
        
        searchBar.delegate = self
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(TrackerCell.self, forCellWithReuseIdentifier: TrackerCell.reuseIdentifier)
        
        collectionView.register(
             CategoryHeaderView.self,
             forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
             withReuseIdentifier: CategoryHeaderView.reuseIdentifier
         )
        
        collectionView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 90, right: 0)
        collectionView.scrollIndicatorInsets = UIEdgeInsets(top: 0, left: 0, bottom: 90, right: 0)
    }
    
    private func setupNavigationBar() {
        
        let barButtonItem = UIBarButtonItem(customView: datePicker)
        
        if #available(iOS 26.0, *) {
            barButtonItem.hidesSharedBackground = true
        }
        
        navigationItem.title = NSLocalizedString("trackers_title", comment: "Trackers screen title")
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: plusButtonView)
        navigationItem.rightBarButtonItem = barButtonItem
        navigationController?.navigationBar.prefersLargeTitles = true
        
        datePicker.addTarget(self, action: #selector(dateChanged), for: .valueChanged)
    }
    
    private func isTrackerCompleted(_ tracker: Tracker, on date: Date) -> Bool {
        let normalizedDate = Calendar.current.startOfDay(for: date)
        
        return completedTrackers.contains {
            $0.trackerID == tracker.id &&
            Calendar.current.isDate($0.date, inSameDayAs: normalizedDate)
        }
    }

    private func completedDaysCount(for tracker: Tracker) -> Int {
        completedTrackers.filter { $0.trackerID == tracker.id }.count
    }

    private func isFutureDate(_ date: Date) -> Bool {
        Calendar.current.startOfDay(for: date) > Calendar.current.startOfDay(for: Date())
    }

    private func toggleTrackerCompletion(_ tracker: Tracker) {
        guard !isFutureDate(currentDate) else { return }
        
        let normalizedDate = Calendar.current.startOfDay(for: currentDate)
        
        if isTrackerCompleted(tracker, on: normalizedDate) {
            do {
                try trackerRecordStore.deleteRecord(trackerID: tracker.id, date: normalizedDate)
            } catch {
                print("Failed to delete record: \(error)")
            }
        } else {
            let record = TrackerRecord(trackerID: tracker.id, date: normalizedDate)
            
            do {
                try trackerRecordStore.addRecord(record)
            } catch {
                print("Failed to add record: \(error)")
            }
        }
    }
    
    private func updateVisibleState() {
        let isEmpty = visibleCategories.isEmpty
        
        let hasTrackersForDate = hasTrackersForCurrentDate()
        let shouldShowNothingFound = !searchText.isEmpty || selectedFilter == .completed || selectedFilter == .notCompleted

        collectionView.isHidden = isEmpty
        
        placeholderImageView.isHidden = !isEmpty
        placeholderLabel.isHidden = !isEmpty
        
        filtersButton.isHidden = !hasTrackersForDate

        guard isEmpty else { return }

        if hasTrackersForDate && shouldShowNothingFound {
            placeholderImageView.image = UIImage(resource: .notFound)
            placeholderLabel.text = NSLocalizedString("nothing_found_placeholder", comment: "Nothing found placeholder")
        } else {
            placeholderImageView.image = UIImage(resource: .star)
            placeholderLabel.text = NSLocalizedString("trackers_placeholder", comment: "Empty trackers placeholder")
        }
    }
    
    @objc private func filtersButtonTapped() {
        analyticsService.report(event: .click, screen: .main, item: .filter)
        
        let filtersViewController = FiltersViewController(selectedFilter: selectedFilter)

        filtersViewController.onFilterSelected = { [weak self] filter in
            guard let self else { return }

            switch filter {
            case .today:
                self.selectedFilter = .today
                self.currentDate = Date()
                self.datePicker.date = Date()
            case .all:
                self.selectedFilter = .all
            case .completed:
                self.selectedFilter = .completed
            case .notCompleted:
                self.selectedFilter = .notCompleted
            }

            self.applyFilters()
        }

        present(filtersViewController, animated: true)
    }
    
    private func hasTrackersForCurrentDate() -> Bool {
        let selectedWeekday = currentDate.trackerWeekday

        return categories.contains { category in
            category.trackers.contains { tracker in
                tracker.schedule.contains(selectedWeekday)
            }
        }
    }
    
    private func applyFilters() {
        let selectedWeekday = currentDate.trackerWeekday
        let normalizedSearchText = searchText.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        
        visibleCategories = categories.compactMap { category in
            let filteredTrackers = category.trackers.filter { tracker in
                let matchesWeekday = tracker.schedule.contains(selectedWeekday)
                
                let matchesSearchText: Bool
                if normalizedSearchText.isEmpty {
                    matchesSearchText = true
                } else {
                    matchesSearchText = tracker.name.lowercased().contains(normalizedSearchText)
                }
                
                let isCompleted = isTrackerCompleted(tracker, on: currentDate)

                let matchesFilter: Bool
                switch selectedFilter {
                case .all, .today:
                    matchesFilter = true
                case .completed:
                    matchesFilter = isCompleted
                case .notCompleted:
                    matchesFilter = !isCompleted
                }

                return matchesWeekday && matchesSearchText && matchesFilter
            }
            
            if filteredTrackers.isEmpty {
                return nil
            } else {
                return TrackerCategory(title: category.title, trackers: filteredTrackers)
            }
        }
        
        collectionView.reloadData()
        updateVisibleState()
    }
    
    @objc private func addTrackerButtonTapped() {
        analyticsService.report(event: .click, screen: .main, item: .addTrack)
        
        let createHabitViewController = CreateHabitViewController()
        
        createHabitViewController.onCreate = { [weak self] tracker, categoryTitle in
            guard let self else { return }
            
            do {
                try self.trackerStore.addTracker(tracker, categoryTitle: categoryTitle)
            } catch {
                print("Failed to save tracker: \(error)")
            }
        }
        
        let navigationController = UINavigationController(rootViewController: createHabitViewController)
        navigationController.modalPresentationStyle = .fullScreen
        present(navigationController, animated: true)
    }
    
    private func deleteTracker(_ tracker: Tracker) {
        do {
            try trackerStore.deleteTracker(with: tracker.id)
        } catch {
            print("Failed to delete tracker: \(error)")
        }
    }
    
    private func editTracker(_ tracker: Tracker, categoryTitle: String) {
        let completedDaysCount = completedTrackers.filter { $0.trackerID == tracker.id }.count
        
        let editViewController = CreateHabitViewController(
            trackerToEdit: tracker,
            categoryTitle: categoryTitle,
            completedDaysCount: completedDaysCount
        )

        editViewController.onUpdate = { [weak self] updatedTracker, updatedCategoryTitle in
            guard let self else { return }

            do {
                try self.trackerStore.updateTracker(
                    with: tracker.id,
                    newTracker: updatedTracker,
                    categoryTitle: updatedCategoryTitle
                )
            } catch {
                print("Failed to update tracker: \(error)")
            }
        }

        let navigationController = UINavigationController(rootViewController: editViewController)
        navigationController.modalPresentationStyle = .fullScreen
        present(navigationController, animated: true)
    }
    
    private func presentDeleteConfirmation(for tracker: Tracker) {
        let alert = UIAlertController(
            title: nil,
            message: NSLocalizedString("delete_tracker_confirmation", comment: "Delete tracker confirmation message"),
            preferredStyle: .actionSheet
        )

        let deleteAction = UIAlertAction(
            title: NSLocalizedString("delete_action", comment: "Delete action title"),
            style: .destructive
        ) { [weak self] _ in
            self?.deleteTracker(tracker)
        }

        let cancelAction = UIAlertAction(
            title: NSLocalizedString("cancel_button", comment: "Cancel button title"),
            style: .cancel
        )

        alert.addAction(deleteAction)
        alert.addAction(cancelAction)

        if let popover = alert.popoverPresentationController {
            popover.sourceView = view
            popover.sourceRect = CGRect(
                x: view.bounds.midX,
                y: view.bounds.midY,
                width: 0,
                height: 0
            )
            popover.permittedArrowDirections = []
        }

        present(alert, animated: true)
    }
    
    @objc private func dateChanged() {
        currentDate = datePicker.date
        applyFilters()
    }
}

extension TrackersViewController: UICollectionViewDelegate {
    func collectionView(
        _ collectionView: UICollectionView,
        contextMenuConfigurationForItemAt indexPath: IndexPath,
        point: CGPoint
    ) -> UIContextMenuConfiguration? {
        let tracker = visibleCategories[indexPath.section].trackers[indexPath.item]
        let categoryTitle = visibleCategories[indexPath.section].title

        return UIContextMenuConfiguration(
            identifier: indexPath as NSIndexPath,
            previewProvider: nil
        ) { [weak self] _ in
            guard let self else { return UIMenu() }

            let editAction = UIAction(
                title: NSLocalizedString("edit_action", comment: "Edit action title")
            ) { _ in
                self.analyticsService.report(event: .click, screen: .main, item: .edit)
                self.editTracker(tracker, categoryTitle: categoryTitle)
            }

            let deleteAction = UIAction(
                title: NSLocalizedString("delete_action", comment: "Delete action title"),
                attributes: .destructive
            ) { [weak self] _ in
                self?.analyticsService.report(event: .click, screen: .main, item: .delete)
                self?.presentDeleteConfirmation(for: tracker)
            }

            return UIMenu(title: "", children: [editAction, deleteAction])
        }
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        previewForHighlightingContextMenuWithConfiguration configuration: UIContextMenuConfiguration
    ) -> UITargetedPreview? {
        makeContextMenuPreview(from: collectionView, configuration: configuration)
    }

    func collectionView(
        _ collectionView: UICollectionView,
        previewForDismissingContextMenuWithConfiguration configuration: UIContextMenuConfiguration
    ) -> UITargetedPreview? {
        makeContextMenuPreview(from: collectionView, configuration: configuration)
    }

    private func makeContextMenuPreview(
        from collectionView: UICollectionView,
        configuration: UIContextMenuConfiguration
    ) -> UITargetedPreview? {
        guard
            let identifier = configuration.identifier as? NSIndexPath,
            let cell = collectionView.cellForItem(at: identifier as IndexPath) as? TrackerCell
        else {
            return nil
        }

        let previewView = cell.contextMenuPreviewView

        let parameters = UIPreviewParameters()
        parameters.backgroundColor = .clear
        parameters.visiblePath = UIBezierPath(
            roundedRect: previewView.bounds,
            cornerRadius: 16
        )

        return UITargetedPreview(
            view: previewView,
            parameters: parameters
        )
    }
}

extension TrackersViewController: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        visibleCategories.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        visibleCategories[section].trackers.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let tracker = visibleCategories[indexPath.section].trackers[indexPath.item]
        
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: TrackerCell.reuseIdentifier,
            for: indexPath
        ) as? TrackerCell else {
            return UICollectionViewCell()
        }
        
        let completedDays = completedDaysCount(for: tracker)
        let isCompleted = isTrackerCompleted(tracker, on: currentDate)
        
        cell.configure(with: tracker, completedDays: completedDays, isCompleted: isCompleted)
        cell.onDoneButtonTap = { [weak self] in
            self?.analyticsService.report(event: .click, screen: .main, item: .track)
            self?.toggleTrackerCompletion(tracker)
        }
        
        return cell
    }
    
    func collectionView(
         _ collectionView: UICollectionView,
         viewForSupplementaryElementOfKind kind: String,
         at indexPath: IndexPath
     ) -> UICollectionReusableView {
         guard kind == UICollectionView.elementKindSectionHeader else {
             return UICollectionReusableView()
         }

         guard let header = collectionView.dequeueReusableSupplementaryView(
             ofKind: kind,
             withReuseIdentifier: CategoryHeaderView.reuseIdentifier,
             for: indexPath
         ) as? CategoryHeaderView else {
             return UICollectionReusableView()
         }

         let title = visibleCategories[indexPath.section].title
         header.configure(with: title)

         return header
     }
}

extension TrackersViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        let spacing: CGFloat = 9
        let cellsPerRow: CGFloat = 2
        let totalSpacing = (cellsPerRow - 1) * spacing
        let width = (collectionView.bounds.width - totalSpacing) / cellsPerRow
        return CGSize(width: width, height: 148)
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        9
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        16
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        referenceSizeForHeaderInSection section: Int
    ) -> CGSize {
        CGSize(width: collectionView.bounds.width - 32, height: 46)
    }
}

extension TrackersViewController: TrackerStoreDelegate {
    func storeDidUpdateTrackers() {
        loadData()
    }
}

extension TrackersViewController: TrackerCategoryStoreDelegate {
    func storeDidUpdateCategories() {
        loadData()
    }
}

extension TrackersViewController: TrackerRecordStoreDelegate {
    func storeDidUpdateRecords() {
        loadData()
    }
}

extension TrackersViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        self.searchText = searchText
        applyFilters()
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        self.searchText = ""
        applyFilters()
    }
}
