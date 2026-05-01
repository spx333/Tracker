//
//  ScheduleViewController.swift
//  Tracker
//
//  Created by Сергей Петров on 01.05.2026.
//

import UIKit

final class ScheduleViewController: UIViewController {

    var onDone: (([Weekday]) -> Void)?

    private var selectedWeekdays: [Weekday]

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Расписание"
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
        tableView.backgroundColor = .secondarySystemBackground
        tableView.showsVerticalScrollIndicator = false
        return tableView
    }()

    private let doneButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Готово", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .black
        button.layer.cornerRadius = 16
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    private let weekdays: [Weekday] = [.monday, .tuesday, .wednesday, .thursday, .friday, .saturday, .sunday]

    init(selectedWeekdays: [Weekday]) {
        self.selectedWeekdays = selectedWeekdays
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupTable()
        setupActions()
    }

    private func setupUI() {
        view.backgroundColor = .systemBackground
        navigationController?.navigationBar.isHidden = true

        view.addSubview(titleLabel)
        view.addSubview(tableView)
        view.addSubview(doneButton)

        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 24),
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),

            tableView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 24),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            tableView.heightAnchor.constraint(equalToConstant: 7 * 75),

            doneButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            doneButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            doneButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            doneButton.heightAnchor.constraint(equalToConstant: 60)
        ])
    }

    private func setupTable() {
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "weekdayCell")
        tableView.rowHeight = 75
        tableView.tableFooterView = UIView()
    }

    private func setupActions() {
        doneButton.addTarget(self, action: #selector(doneTapped), for: .touchUpInside)
    }

    @objc private func doneTapped() {
        onDone?(selectedWeekdays.sorted { $0.rawValue < $1.rawValue })
        navigationController?.popViewController(animated: true)
    }
}

extension ScheduleViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        weekdays.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let weekday = weekdays[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "weekdayCell", for: indexPath)

        var content = cell.defaultContentConfiguration()
        content.text = weekday.fullName
        content.textProperties.font = .systemFont(ofSize: 17, weight: .regular)
        content.textProperties.color = .label
        cell.contentConfiguration = content

        cell.backgroundColor = .clear
        cell.selectionStyle = .none
        cell.preservesSuperviewLayoutMargins = false
        cell.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        cell.layoutMargins = .zero

        let switchView = UISwitch()
        switchView.isOn = selectedWeekdays.contains(weekday)
        switchView.tag = indexPath.row
        switchView.onTintColor = .systemBlue
        switchView.addTarget(self, action: #selector(switchChanged(_:)), for: .valueChanged)
        cell.accessoryView = switchView

        return cell
    }

    @objc private func switchChanged(_ sender: UISwitch) {
        let weekday = weekdays[sender.tag]

        if sender.isOn {
            if !selectedWeekdays.contains(weekday) {
                selectedWeekdays.append(weekday)
            }
        } else {
            selectedWeekdays.removeAll { $0 == weekday }
        }
    }
}
