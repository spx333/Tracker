//
//  FiltersViewController.swift
//  Tracker
//
//  Created by Сергей Петров on 16.06.2026.
//

import UIKit

final class FiltersViewController: UIViewController {
    
    var onFilterSelected: ((TrackerFilter) -> Void)?
    
    private let selectedFilter: TrackerFilter
    
    private let options: [(title: String, filter: TrackerFilter)] = [
        (NSLocalizedString("all_trackers_filter", comment: ""), .all),
        (NSLocalizedString("today_trackers_filter", comment: ""), .today),
        (NSLocalizedString("completed_filter", comment: ""), .completed),
        (NSLocalizedString("not_completed_filter", comment: ""), .notCompleted)
    ]
    
    init(selectedFilter: TrackerFilter) {
        self.selectedFilter = selectedFilter
        super.init(nibName: nil, bundle: nil)
        modalPresentationStyle = .pageSheet
    }
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = NSLocalizedString("filters_title", comment: "Filters title")
        label.font = .systemFont(ofSize: 16, weight: .medium)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .plain)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.isScrollEnabled = false
        tableView.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        tableView.layer.cornerRadius = 16
        tableView.clipsToBounds = true
        tableView.backgroundColor = UIColor.secondarySystemBackground
        return tableView
    }()
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        nil
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .systemBackground
        view.addSubview(titleLabel)
        view.addSubview(tableView)
        
        tableView.rowHeight = 75
        tableView.tableFooterView = UIView()
        tableView.dataSource = self
        tableView.delegate = self
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 27),
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            tableView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 24),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            tableView.heightAnchor.constraint(equalToConstant: 300)
        ])
    }
}

extension FiltersViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        options.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .default, reuseIdentifier: nil)
        let option = options[indexPath.row]
        
        cell.textLabel?.text = option.title
        cell.selectionStyle = .none
        cell.backgroundColor = .secondarySystemBackground
        
        let shouldShowCheckmark: Bool
        switch option.filter {
        case .all, .today:
            shouldShowCheckmark = false
        case .completed, .notCompleted:
            shouldShowCheckmark = option.filter == selectedFilter
        }
        
        cell.accessoryType = shouldShowCheckmark ? .checkmark : .none
        cell.tintColor = .systemBlue
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let option = options[indexPath.row]
        onFilterSelected?(option.filter)
        dismiss(animated: true)
    }
}
