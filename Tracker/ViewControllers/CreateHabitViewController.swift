//
//  CreateHabitViewController.swift
//  Tracker
//
//  Created by Сергей Петров on 01.05.2026.
//

import UIKit

final class CreateHabitViewController: UIViewController, UITextFieldDelegate {
    
    private enum Constants {
        static let trackerNameMaxLength = 38
    }

    var onCreate: ((Tracker, String) -> Void)?

    private var optionsTopConstraint: NSLayoutConstraint?
    private var selectedCategoryTitle: String?
    private var selectedSchedule: [Weekday] = []
    private let emojis = MockData.emojis
    private let colors = MockData.colors
    
    private var selectedEmojiIndexPath: IndexPath?
    private var selectedColorIndexPath: IndexPath?

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
        textField.clearButtonMode = .whileEditing 
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
    
    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.headerReferenceSize = CGSize(width: view.bounds.width, height: 50)
        layout.minimumInteritemSpacing = 5
        layout.minimumLineSpacing = 5
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .systemBackground
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.dataSource = self
        collectionView.delegate = self
        
        collectionView.register(
            EmojiCollectionViewCell.self,
            forCellWithReuseIdentifier: EmojiCollectionViewCell.reuseIdentifier
        )
        collectionView.register(
            ColorCollectionViewCell.self,
            forCellWithReuseIdentifier: ColorCollectionViewCell.reuseIdentifier
        )
        collectionView.register(
            TrackerSectionHeaderView.self,
            forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
            withReuseIdentifier: TrackerSectionHeaderView.reuseIdentifier
        )
        
        return collectionView
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
        setupActions()
        
        updateCategoryButtonTitle()
        updateScheduleButtonTitle()
        updateCreateButtonState()
        updateErrorState(showError: false)
        
        setupTapToDismissKeyboard()
    }
    
    override func viewWillAppear(_ animated: Bool) {
         super.viewWillAppear(animated)
         navigationController?.setNavigationBarHidden(true, animated: animated)
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
        view.addSubview(errorLabel)
        view.addSubview(optionsContainerView)
        view.addSubview(collectionView)
        view.addSubview(cancelButton)
        view.addSubview(createButton)
        
        optionsContainerView.addSubview(categoryButton)
        optionsContainerView.addSubview(scheduleButton)
        optionsContainerView.addSubview(separatorView)
        optionsContainerView.addSubview(categoryChevron)
        optionsContainerView.addSubview(scheduleChevron)
        
        optionsTopConstraint = optionsContainerView.topAnchor.constraint(equalTo: nameTextField.bottomAnchor, constant: 24)
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 24),
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            nameTextField.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 38),
            nameTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            nameTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            nameTextField.heightAnchor.constraint(equalToConstant: 75),
            
            errorLabel.topAnchor.constraint(equalTo: nameTextField.bottomAnchor, constant: 8),
            errorLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            errorLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            errorLabel.heightAnchor.constraint(equalToConstant: 22),
            
            optionsTopConstraint!,
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
            
            collectionView.topAnchor.constraint(equalTo: optionsContainerView.bottomAnchor, constant: 16),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            
            cancelButton.trailingAnchor.constraint(equalTo: createButton.leadingAnchor, constant: -8),

            cancelButton.topAnchor.constraint(equalTo: collectionView.bottomAnchor, constant: 16),
            cancelButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            createButton.topAnchor.constraint(equalTo: collectionView.bottomAnchor, constant: 16),
            createButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),

            cancelButton.widthAnchor.constraint(equalToConstant: 166),
            cancelButton.heightAnchor.constraint(equalToConstant: 60),
            createButton.widthAnchor.constraint(equalToConstant: 166),
            createButton.heightAnchor.constraint(equalToConstant: 60),

            cancelButton.centerXAnchor.constraint(equalTo: view.centerXAnchor, constant: -87)
        ])
    }

    private func setupActions() {
        cancelButton.addTarget(self, action: #selector(cancelTapped), for: .touchUpInside)
        createButton.addTarget(self, action: #selector(createTapped), for: .touchUpInside)
        scheduleButton.addTarget(self, action: #selector(scheduleTapped), for: .touchUpInside)
        categoryButton.addTarget(self, action: #selector(categoryTapped), for: .touchUpInside)
        nameTextField.addTarget(self, action: #selector(textDidChange), for: .editingChanged)
        nameTextField.delegate = self
    }
    
    private func updateErrorState(showError: Bool) {
        errorLabel.isHidden = !showError
        optionsTopConstraint?.constant = showError ? 62 : 24
        
        UIView.animate(withDuration: 0.2) {
            self.view.layoutIfNeeded()
        }
    }

    @objc private func cancelTapped() {
        dismiss(animated: true)
    }
    
    @objc private func categoryTapped() {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        
        let context = appDelegate.coreDataStack.context
        let categoryStore = TrackerCategoryStore(context: context)
        let viewModel = CategoriesViewModel(
            categoryStore: categoryStore,
            selectedCategoryTitle: selectedCategoryTitle
        )
        let categoriesViewController = CategoriesViewController(viewModel: viewModel)
        
        categoriesViewController.onCategorySelected = { [weak self] selectedTitle in
            self?.selectedCategoryTitle = selectedTitle
            self?.updateCategoryButtonTitle()
            self?.updateCreateButtonState()
        }
        
        navigationController?.pushViewController(categoriesViewController, animated: true)
    }

    @objc private func createTapped() {
        guard let name = nameTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines),
              !name.isEmpty,
              let selectedCategoryTitle,
              !selectedSchedule.isEmpty,
              let selectedEmojiIndexPath,
              let selectedColorIndexPath else { return }

        let tracker = Tracker(
            id: UUID(),
            name: name,
            color: colors[selectedColorIndexPath.item],
            emoji: emojis[selectedEmojiIndexPath.item],
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
        updateCreateButtonState()
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String ) -> Bool {
        guard let currentText = textField.text,
              let textRange = Range(range, in: currentText) else {
            return true
        }
        
        let updatedText = currentText.replacingCharacters(in: textRange, with: string)
        let isValid = updatedText.count <= Constants.trackerNameMaxLength
        
        updateErrorState(showError: !isValid)
        
        return isValid
    }

    private func updateCreateButtonState() {
        let hasName = !(nameTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ?? true)
        let hasCategory = !(selectedCategoryTitle?.isEmpty ?? true)
        let hasSchedule = !selectedSchedule.isEmpty
        let hasEmoji = selectedEmojiIndexPath != nil
        let hasColor = selectedColorIndexPath != nil
        
        let isEnabled = hasName && hasCategory && hasSchedule && hasEmoji && hasColor
        
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
    
    private func updateCategoryButtonTitle() {
         let paragraphStyle = NSMutableParagraphStyle()
         paragraphStyle.lineSpacing = 2
         
         let title = NSMutableAttributedString(
             string: "Категория",
             attributes: [
                 .font: UIFont.systemFont(ofSize: 17, weight: .regular),
                 .foregroundColor: UIColor.label,
                 .paragraphStyle: paragraphStyle
             ]
         )
         
         if let selectedCategoryTitle, !selectedCategoryTitle.isEmpty {
             let subtitle = NSAttributedString(
                 string: "\n\(selectedCategoryTitle)",
                 attributes: [
                     .font: UIFont.systemFont(ofSize: 17, weight: .regular),
                     .foregroundColor: UIColor.systemGray,
                     .paragraphStyle: paragraphStyle
                 ]
             )
             title.append(subtitle)
         }
         
         categoryButton.setAttributedTitle(title, for: .normal)
         categoryButton.titleLabel?.numberOfLines = 2
     }
}

extension CreateHabitViewController: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        2
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        section == 0 ? emojis.count : colors.count
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {
        if indexPath.section == 0 {
            guard let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: EmojiCollectionViewCell.reuseIdentifier,
                for: indexPath
            ) as? EmojiCollectionViewCell else {
                return UICollectionViewCell()
            }
            
            cell.configure(
                with: emojis[indexPath.item],
                isChosen: indexPath == selectedEmojiIndexPath
            )
            return cell
        } else {
            guard let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: ColorCollectionViewCell.reuseIdentifier,
                for: indexPath
            ) as? ColorCollectionViewCell else {
                return UICollectionViewCell()
            }
            
            cell.configure(
                with: colors[indexPath.item],
                isChosen: indexPath == selectedColorIndexPath
            )
            return cell
        }
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        viewForSupplementaryElementOfKind kind: String,
        at indexPath: IndexPath
    ) -> UICollectionReusableView {
        guard kind == UICollectionView.elementKindSectionHeader,
              let header = collectionView.dequeueReusableSupplementaryView(
                ofKind: kind,
                withReuseIdentifier: TrackerSectionHeaderView.reuseIdentifier,
                for: indexPath
              ) as? TrackerSectionHeaderView else {
            return UICollectionReusableView()
        }
        
        header.configure(with: indexPath.section == 0 ? "Emoji" : "Цвет")
        return header
    }
}

extension CreateHabitViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if indexPath.section == 0 {
            let previous = selectedEmojiIndexPath
            selectedEmojiIndexPath = indexPath
            
            var itemsToReload = [indexPath]
            if let previous, previous != indexPath {
                itemsToReload.append(previous)
            }
            collectionView.reloadItems(at: itemsToReload)
        } else {
            let previous = selectedColorIndexPath
            selectedColorIndexPath = indexPath
            
            var itemsToReload = [indexPath]
            if let previous, previous != indexPath {
                itemsToReload.append(previous)
            }
            collectionView.reloadItems(at: itemsToReload)
        }
        
        updateCreateButtonState()
    }
}

extension CreateHabitViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        let itemsPerRow: CGFloat = 6
        let spacing: CGFloat = 5
        let totalSpacing = spacing * (itemsPerRow - 1)
        let availableWidth = collectionView.bounds.width - totalSpacing
        let itemWidth = floor(availableWidth / itemsPerRow)
        
        return CGSize(width: itemWidth, height: itemWidth)
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        insetForSectionAt section: Int
    ) -> UIEdgeInsets {
        UIEdgeInsets(top: 0, left: 0, bottom: 24, right: 0)
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        minimumLineSpacingForSectionAt section: Int
    ) -> CGFloat {
        5
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        minimumInteritemSpacingForSectionAt section: Int
    ) -> CGFloat {
        5
    }
}
