//
//  CategoriesViewController.swift
//  Tracker
//
//  Created by Сергей Петров on 29.05.2026.
//

import UIKit

final class CategoriesViewController: UIViewController {
    
    var onCategorySelected: ((String) -> Void)?
    
    private let viewModel: CategoriesViewModel
    private var tableViewHeightConstraint: NSLayoutConstraint?
    
    private let tableView: UITableView = {
        let tableView = UITableView()
        tableView.register(CategoryTableViewCell.self, forCellReuseIdentifier: CategoryTableViewCell.reuseIdentifier)
        tableView.separatorStyle = .none
        tableView.backgroundColor = UIColor(resource: .trackerBackground)
        tableView.layer.cornerRadius = 16
        tableView.layer.masksToBounds = true
        tableView.isScrollEnabled = false
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }()
    
    private let placeholderImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(resource: .star)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let placeholderLabel: UILabel = {
        let label = UILabel()
        label.text = NSLocalizedString("categories_placeholder", comment: "Empty categories placeholder")
        label.font = .systemFont(ofSize: 12, weight: .medium)
        label.textColor = .black
        label.numberOfLines = 2
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let addCategoryButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle(NSLocalizedString("add_category_button", comment: "Add category button"), for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .black
        button.layer.cornerRadius = 16
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    init(viewModel: CategoriesViewModel) {
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
        title = NSLocalizedString("categories_title", comment: "Categories screen title")
        
        setupViews()
        setupConstraints()
        setupTableView()
        bindViewModel()
        setupActions()
        
        viewModel.loadCategories()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    private func setupViews() {
        view.addSubview(tableView)
        view.addSubview(placeholderImageView)
        view.addSubview(placeholderLabel)
        view.addSubview(addCategoryButton)
    }
    
    private func setupConstraints() {
        tableViewHeightConstraint = tableView.heightAnchor.constraint(equalToConstant: 0)
        
        NSLayoutConstraint.activate([
            addCategoryButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            addCategoryButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            addCategoryButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            addCategoryButton.heightAnchor.constraint(equalToConstant: 60),
            
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 24),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            tableViewHeightConstraint!,
            
            placeholderImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            placeholderImageView.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -40),
            placeholderImageView.widthAnchor.constraint(equalToConstant: 80),
            placeholderImageView.heightAnchor.constraint(equalToConstant: 80),
            
            placeholderLabel.topAnchor.constraint(equalTo: placeholderImageView.bottomAnchor, constant: 8),
            placeholderLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
    }
    
    private func updateTableViewHeight() {
        let rowHeight: CGFloat = 75
        let totalHeight = CGFloat(viewModel.numberOfRows()) * rowHeight
        tableViewHeightConstraint?.constant = totalHeight
        view.layoutIfNeeded()
    }
    
    private func setupTableView() {
        tableView.dataSource = self
        tableView.delegate = self
    }
    
    private func bindViewModel() {
        viewModel.onCategoriesChanged = { [weak self] in
            self?.tableView.reloadData()
            self?.updateTableViewHeight()
        }
        
        viewModel.onPlaceholderVisibilityChanged = { [weak self] isEmpty in
            self?.placeholderImageView.isHidden = !isEmpty
            self?.placeholderLabel.isHidden = !isEmpty
            self?.tableView.isHidden = isEmpty
        }
        
        viewModel.onCategorySelected = { [weak self] selectedTitle in
            self?.onCategorySelected?(selectedTitle)
            self?.navigationController?.popViewController(animated: true)
        }
    }
    
    private func setupActions() {
        addCategoryButton.addTarget(self, action: #selector(addCategoryButtonTapped), for: .touchUpInside)
    }
    
    @objc private func addCategoryButtonTapped() {
        let newCategoryViewModel = NewCategoryViewModel(categoryStore: viewModel.categoryStore)
        let newCategoryViewController = NewCategoryViewController(viewModel: newCategoryViewModel)
        
        newCategoryViewController.onCategoryCreated = { [weak self] in
            self?.viewModel.loadCategories()
        }
        
        navigationController?.pushViewController(newCategoryViewController, animated: true)
    }
    
    private func editCategory(_ oldTitle: String) {
        let viewModel = EditCategoryViewModel(
            categoryStore: viewModel.categoryStore,
            oldTitle: oldTitle
        )
        let viewController = EditCategoryViewController(viewModel: viewModel)

        viewController.onCategoryUpdated = { [weak self] in
            self?.viewModel.loadCategories()
        }

        navigationController?.pushViewController(viewController, animated: true)
    }
    
    private func deleteCategory(_ title: String) {
        do {
            let canDelete = try viewModel.categoryStore.canDeleteCategory(with: title)
            
            if canDelete {
                try viewModel.categoryStore.deleteCategory(with: title)
                viewModel.loadCategories()
            } else {
                presentCannotDeleteCategoryAlert()
            }
        } catch {
            print("Failed to delete category: \(error)")
        }
    }
    
    private func presentCannotDeleteCategoryAlert() {
        let alert = UIAlertController(
            title: NSLocalizedString("category_delete_not_empty_title", comment: "Non-empty category delete alert title"),
            message: NSLocalizedString("category_delete_not_empty_message", comment: "Non-empty category delete alert message"),
            preferredStyle: .alert
        )
        
        let okAction = UIAlertAction(
            title: NSLocalizedString("ok_action", comment: "OK action title"),
            style: .default
        )
        alert.addAction(okAction)
        
        present(alert, animated: true)
    }
}

extension CategoriesViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel.numberOfRows()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: CategoryTableViewCell.reuseIdentifier,
            for: indexPath
        ) as? CategoryTableViewCell else {
            return UITableViewCell()
        }
        
        let title = viewModel.titleForCategory(at: indexPath.row)
        let isSelected = viewModel.isCategorySelected(at: indexPath.row)
        
        cell.configure(title: title, isSelected: isSelected)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        viewModel.selectCategory(at: indexPath.row)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        75
    }
    
    func tableView(
        _ tableView: UITableView,
        contextMenuConfigurationForRowAt indexPath: IndexPath,
        point: CGPoint
    ) -> UIContextMenuConfiguration? {
        let categoryTitle = viewModel.titleForCategory(at: indexPath.row)
        
        return UIContextMenuConfiguration(identifier: nil, previewProvider: nil) { [weak self] _ in
            guard let self else { return UIMenu() }
            
            let editAction = UIAction(
                title: NSLocalizedString("edit_action", comment: "Edit action title")
            ) { _ in
                self.editCategory(categoryTitle)
            }
            
            let deleteAction = UIAction(
                title: NSLocalizedString("delete_action", comment: "Delete action title"),
                attributes: .destructive
            ) { _ in
                self.deleteCategory(categoryTitle)
            }
            
            return UIMenu(title: "", children: [editAction, deleteAction])
        }
    }
}
