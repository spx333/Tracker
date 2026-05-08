//
//  CreateHabitViewController.swift
//  Tracker
//
//  Created by Сергей Петров on 01.05.2026.
//

import UIKit

final class CreateHabitViewController: UIViewController, UITextFieldDelegate {

    var onCreate: ((Tracker, String) -> Void)?

    private var selectedCategoryTitle: String = "Важное"
    private var selectedSchedule: [Weekday] = []

    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Новая привычка"
        label.font = .systemFont(ofSize: 16, weight: .medium)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private lazy var nameTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Введите название трекера"
        textField.backgroundColor = UIColor.secondarySystemBackground
        textField.layer.cornerRadius = 16
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: 1))
        textField.leftViewMode = .always
        return textField
    }()

    private let optionsContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.secondarySystemBackground
        view.layer.cornerRadius = 16
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private let categoryButton = UIButton(type: .system)
    private let scheduleButton = UIButton(type: .system)
    private let separatorView: UIView = {
        let view = UIView()
        view.backgroundColor = .separator
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private let cancelButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Отменить", for: .normal)
        button.setTitleColor(UIColor(resource: .trackerRed), for: .normal)
        button.layer.cornerRadius = 16
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor(resource: .trackerRed).cgColor
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    private let createButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Создать", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .systemGray3
        button.layer.cornerRadius = 16
        button.translatesAutoresizingMaskIntoConstraints = false
        button.isEnabled = false
        return button
    }()
    
    private let errorLabel: UILabel = {
        let label = UILabel()
        label.text = "Ограничение 38 символов"
        label.font = .systemFont(ofSize: 17, weight: .regular)
        label.textColor = UIColor(resource: .trackerRed)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        label.isHidden = true
        return label
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBar()
        setupUI()
        setupActions()
        updateCreateButtonState()
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
        tapGesture.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGesture)
    }

    private func setupNavigationBar() {
        navigationController?.navigationBar.isHidden = true
    }

    private func setupUI() {
        view.backgroundColor = .systemBackground

        categoryButton.translatesAutoresizingMaskIntoConstraints = false
        scheduleButton.translatesAutoresizingMaskIntoConstraints = false

        categoryButton.setTitle("Категория", for: .normal)
        categoryButton.setTitleColor(.label, for: .normal)
        categoryButton.contentHorizontalAlignment = .left

        scheduleButton.setTitle("Расписание", for: .normal)
        scheduleButton.setTitleColor(.label, for: .normal)
        scheduleButton.contentHorizontalAlignment = .left

        let categoryChevron = UIImageView(image: UIImage(systemName: "chevron.right"))
        categoryChevron.tintColor = .systemGray3
        categoryChevron.translatesAutoresizingMaskIntoConstraints = false

        let scheduleChevron = UIImageView(image: UIImage(systemName: "chevron.right"))
        scheduleChevron.tintColor = .systemGray3
        scheduleChevron.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(titleLabel)
        view.addSubview(nameTextField)
        view.addSubview(optionsContainerView)
        view.addSubview(cancelButton)
        view.addSubview(createButton)
        view.addSubview(errorLabel)

        optionsContainerView.addSubview(categoryButton)
        optionsContainerView.addSubview(scheduleButton)
        optionsContainerView.addSubview(separatorView)
        optionsContainerView.addSubview(categoryChevron)
        optionsContainerView.addSubview(scheduleChevron)

        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 24),
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),

            nameTextField.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 38),
            nameTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            nameTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            nameTextField.heightAnchor.constraint(equalToConstant: 75),
            
            errorLabel.topAnchor.constraint(equalTo: nameTextField.bottomAnchor, constant: 8),
            errorLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),

            optionsContainerView.topAnchor.constraint(equalTo: errorLabel.bottomAnchor, constant: 32),
            optionsContainerView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            optionsContainerView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            optionsContainerView.heightAnchor.constraint(equalToConstant: 150),

            categoryButton.topAnchor.constraint(equalTo: optionsContainerView.topAnchor),
            categoryButton.leadingAnchor.constraint(equalTo: optionsContainerView.leadingAnchor, constant: 16),
            categoryButton.trailingAnchor.constraint(equalTo: optionsContainerView.trailingAnchor, constant: -50),
            categoryButton.heightAnchor.constraint(equalToConstant: 75),

            separatorView.topAnchor.constraint(equalTo: categoryButton.bottomAnchor),
            separatorView.leadingAnchor.constraint(equalTo: optionsContainerView.leadingAnchor, constant: 16),
            separatorView.trailingAnchor.constraint(equalTo: optionsContainerView.trailingAnchor, constant: -16),
            separatorView.heightAnchor.constraint(equalToConstant: 0.5),

            scheduleButton.topAnchor.constraint(equalTo: separatorView.bottomAnchor),
            scheduleButton.leadingAnchor.constraint(equalTo: optionsContainerView.leadingAnchor, constant: 16),
            scheduleButton.trailingAnchor.constraint(equalTo: optionsContainerView.trailingAnchor, constant: -50),
            scheduleButton.heightAnchor.constraint(equalToConstant: 74),

            categoryChevron.centerYAnchor.constraint(equalTo: categoryButton.centerYAnchor),
            categoryChevron.trailingAnchor.constraint(equalTo: optionsContainerView.trailingAnchor, constant: -16),

            scheduleChevron.centerYAnchor.constraint(equalTo: scheduleButton.centerYAnchor),
            scheduleChevron.trailingAnchor.constraint(equalTo: optionsContainerView.trailingAnchor, constant: -16),

            cancelButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            cancelButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            cancelButton.heightAnchor.constraint(equalToConstant: 60),
            cancelButton.widthAnchor.constraint(equalToConstant: 166),

            createButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            createButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            createButton.heightAnchor.constraint(equalToConstant: 60),
            createButton.widthAnchor.constraint(equalToConstant: 166)
        ])
    }

    private func setupActions() {
        cancelButton.addTarget(self, action: #selector(cancelTapped), for: .touchUpInside)
        createButton.addTarget(self, action: #selector(createTapped), for: .touchUpInside)
        scheduleButton.addTarget(self, action: #selector(scheduleTapped), for: .touchUpInside)
        nameTextField.addTarget(self, action: #selector(textDidChange), for: .editingChanged)
        nameTextField.delegate = self
    }

    @objc private func cancelTapped() {
        dismiss(animated: true)
    }

    @objc private func createTapped() {
        guard let name = nameTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines),
              !name.isEmpty,
              !selectedSchedule.isEmpty else { return }

        let tracker = Tracker(
            id: UUID(),
            name: name,
            color: .systemGreen,
            emoji: "🙂",
            schedule: selectedSchedule
        )

        onCreate?(tracker, selectedCategoryTitle)
        dismiss(animated: true)
    }

    @objc private func scheduleTapped() {
        let scheduleViewController = ScheduleViewController(selectedWeekdays: selectedSchedule)
        scheduleViewController.onDone = { [weak self] weekdays in
            self?.selectedSchedule = weekdays
            self?.updateScheduleButtonTitle()
            self?.updateCreateButtonState()
        }
        navigationController?.pushViewController(scheduleViewController, animated: true)
    }

    @objc private func textDidChange() {
        let textCount = nameTextField.text?.count ?? 0
        errorLabel.isHidden = textCount <= 38
        updateCreateButtonState()
    }
    
    @objc private func hideKeyboard() {
        view.endEditing(true)
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard let currentText = textField.text,
              let textRange = Range(range, in: currentText) else {
            return true
        }

        let updatedText = currentText.replacingCharacters(in: textRange, with: string)
        let isValid = updatedText.count <= 38

        errorLabel.isHidden = isValid

        return isValid
    }

    private func updateCreateButtonState() {
        let hasName = !(nameTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ?? true)
        let hasSchedule = !selectedSchedule.isEmpty
        let isEnabled = hasName && hasSchedule

        createButton.isEnabled = isEnabled
        createButton.backgroundColor = isEnabled ? .black : .systemGray3
    }

    private func updateScheduleButtonTitle() {
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 2

        let title = NSMutableAttributedString(
            string: "Расписание",
            attributes: [
                .font: UIFont.systemFont(ofSize: 17, weight: .regular),
                .foregroundColor: UIColor.label,
                .paragraphStyle: paragraphStyle
            ]
        )

        if !selectedSchedule.isEmpty {
            let subtitleText: String

            if selectedSchedule.count == Weekday.allCases.count {
                subtitleText = "Каждый день"
            } else {
                subtitleText = selectedSchedule
                    .sorted { $0.rawValue < $1.rawValue }
                    .map { $0.shortName }
                    .joined(separator: ", ")
            }

            let subtitle = NSAttributedString(
                string: "\n\(subtitleText)",
                attributes: [
                    .font: UIFont.systemFont(ofSize: 17, weight: .regular),
                    .foregroundColor: UIColor.systemGray,
                    .paragraphStyle: paragraphStyle
                ]
            )

            title.append(subtitle)
        }

        scheduleButton.setAttributedTitle(title, for: .normal)
        scheduleButton.titleLabel?.numberOfLines = 2
    }
}
