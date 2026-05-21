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
    
    var categories: [TrackerCategory] = []
    var completedTrackers: [TrackerRecord] = []
    private var currentDate: Date = Date()
    
    private let searchBar: UISearchBar = {
        let searchBar = UISearchBar()
        searchBar.translatesAutoresizingMaskIntoConstraints = false
        searchBar.placeholder = "Поиск"
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
        label.text = "Что будем отслеживать?"
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
    
    private var visibleCategories: [TrackerCategory] {
        let selectedWeekday = currentDate.trackerWeekday
        
        return categories.compactMap { category in
            let filteredTrackers = category.trackers.filter { tracker in
                tracker.schedule.contains(selectedWeekday)
            }
            
            if filteredTrackers.isEmpty {
                return nil
            } else {
                return TrackerCategory(title: category.title, trackers: filteredTrackers)
            }
        }
    }
    
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
    
    private func loadData() {
        categories = trackerCategoryStore.fetchCategories()
        completedTrackers = trackerRecordStore.fetchRecords()
        collectionView.reloadData()
        updateVisibleState()
    }
    
    private func setupUI() {
        view.backgroundColor = .trackerWhite
        
        view.addSubview(searchBar)
        view.addSubview(placeholderImageView)
        view.addSubview(placeholderLabel)
        view.addSubview(collectionView)
        
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
            placeholderLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor)
            

        ])

        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(TrackerCell.self, forCellWithReuseIdentifier: TrackerCell.reuseIdentifier)

    }
    
    private func setupNavigationBar() {
        
        let barButtonItem = UIBarButtonItem(customView: datePicker)
        
        if #available(iOS 26.0, *) {
            barButtonItem.hidesSharedBackground = true
        }
        
        navigationItem.title = "Трекеры"
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
        
        placeholderImageView.isHidden = !isEmpty
        placeholderLabel.isHidden = !isEmpty
        collectionView.isHidden = isEmpty
    }
    
    @objc private func addTrackerButtonTapped() {
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
    
    @objc private func dateChanged() {
        currentDate = datePicker.date
        collectionView.reloadData()
        updateVisibleState()
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
            self?.toggleTrackerCompletion(tracker)
        }
        
        return cell
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
