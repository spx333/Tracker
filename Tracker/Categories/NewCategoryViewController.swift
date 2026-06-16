//
//  NewCategoryViewController.swift
//  Tracker
//
//  Created by Сергей Петров on 29.05.2026.
//

import UIKit

final class NewCategoryViewController: UIViewController {
    
    var onCategoryCreated: (() -> Void)?
    
    private let viewModel: NewCategoryViewModel
    
    private let textField: UITextField = {
        let textField = UITextField()
        textField.placeholder = NSLocalizedString("new_category_placeholder", comment: "Placeholder for category name")
        textField.backgroundColor = UIColor(white: 0.95, alpha: 1.0)
        textField.layer.cornerRadius = 16
        textField.font = .systemFont(ofSize: 17, weight: .regular)
        textField.clearButtonMode = .whileEditing
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.setLeftPadding(16)
        return textField
    }()
    
    private let doneButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle(NSLocalizedString("done_button", comment: "Done button title"), for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .systemGray3
        button.layer.cornerRadius = 16
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        button.isEnabled = false
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    init(viewModel: NewCategoryViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        nil
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        title = NSLocalizedString("new_category_title", comment: "New category screen title")
        
        setupViews()
        setupConstraints()
        setupActions()
        bindViewModel()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    private func setupViews() {
        view.addSubview(textField)
        view.addSubview(doneButton)
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
        viewModel.onButtonStateChanged = { [weak self] isEnabled in
            self?.doneButton.isEnabled = isEnabled
            self?.doneButton.backgroundColor = isEnabled ? .black : .systemGray3
        }
        
        viewModel.onCategoryCreated = { [weak self] in
            self?.onCategoryCreated?()
            self?.navigationController?.popViewController(animated: true)
        }
    }
    
    @objc private func textDidChange() {
        viewModel.updateCategoryTitle(textField.text)
    }
    
    @objc private func doneButtonTapped() {
        viewModel.createCategory()
    }
}
