//
//  EditCategoryViewController.swift
//  Tracker
//
//  Created by Сергей Петров on 17.06.2026.
//

import UIKit

final class EditCategoryViewController: UIViewController, UITextFieldDelegate {
    var onCategoryUpdated: (() -> Void)?

    private let viewModel: EditCategoryViewModel

    private let textField: UITextField = {
        let textField = UITextField()
        textField.backgroundColor = .secondarySystemBackground
        textField.layer.cornerRadius = 16
        textField.clearButtonMode = .whileEditing
        textField.font = .systemFont(ofSize: 17, weight: .regular)
        textField.translatesAutoresizingMaskIntoConstraints = false

        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: 75))
        textField.leftView = paddingView
        textField.leftViewMode = .always

        return textField
    }()

    private let doneButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle(NSLocalizedString("done_button", comment: "Done button"), for: .normal)
        button.setTitleColor(.systemBackground, for: .normal)
        button.backgroundColor = .systemGray3
        button.layer.cornerRadius = 16
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        button.isEnabled = false
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    init(viewModel: EditCategoryViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        nil
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupAppearance()

        setupViews()
        setupConstraints()
        setupActions()
        bindViewModel()

        configureInitialState()
    }
    
    private func configureInitialState() {
        let title = viewModel.initialTitle()
        textField.text = title
        viewModel.updateText(title)
    }
    
    private func setupAppearance() {
        view.backgroundColor = .systemBackground
        title = NSLocalizedString("edit_category_title", comment: "Edit category screen title")
    }

    private func setupViews() {
        view.addSubview(textField)
        view.addSubview(doneButton)
        textField.delegate = self
    }

    private func setupConstraints() {
        NSLayoutConstraint.activate([
            textField.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 24),
            textField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            textField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            textField.heightAnchor.constraint(equalToConstant: 75),

            doneButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            doneButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            doneButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            doneButton.heightAnchor.constraint(equalToConstant: 60)
        ])
    }

    private func setupActions() {
        textField.addTarget(self, action: #selector(textDidChange), for: .editingChanged)
        doneButton.addTarget(self, action: #selector(doneButtonTapped), for: .touchUpInside)
    }

    private func bindViewModel() {
        viewModel.onStateChanged = { [weak self] isEnabled in
            self?.doneButton.isEnabled = isEnabled
            self?.doneButton.backgroundColor = isEnabled ? .label : .systemGray3
        }
    }

    @objc private func textDidChange() {
        viewModel.updateText(textField.text ?? "")
    }

    @objc private func doneButtonTapped() {
        do {
            try viewModel.save()
            onCategoryUpdated?()
            navigationController?.popViewController(animated: true)
        } catch {
            print("Failed to update category: \(error)")
        }
    }
}
