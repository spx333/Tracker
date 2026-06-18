//
//  OnboardingContentViewController.swift
//  Tracker
//
//  Created by Сергей Петров on 28.05.2026.
//

import UIKit

final class OnboardingContentViewController: UIViewController {
    
    var page: OnboardingPage?
    var onButtonTap: (() -> Void)?
    
    private let backgroundImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 32, weight: .bold)
        label.textColor = .black
        label.textAlignment = .center
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let actionButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle(NSLocalizedString("onboarding_button", comment: "Onboarding continue button"), for: .normal)
        button.backgroundColor = UIColor(resource: .trackerBlack)
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 16
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        configure()
    }
    
    private func setupUI() {
        view.addSubview(backgroundImageView)
        view.addSubview(titleLabel)
        view.addSubview(actionButton)
        
        NSLayoutConstraint.activate([
            backgroundImageView.topAnchor.constraint(equalTo: view.topAnchor),
            backgroundImageView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            backgroundImageView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            backgroundImageView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            actionButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            actionButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            actionButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -50),
            actionButton.heightAnchor.constraint(equalToConstant: 60),
            
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            titleLabel.bottomAnchor.constraint(equalTo: actionButton.topAnchor, constant: -160)
        ])
        
        actionButton.addTarget(self, action: #selector(buttonTapped), for: .touchUpInside)
    }
    
    private func configure() {
        guard let page else { return }
        backgroundImageView.image = page.backgroundImage
        titleLabel.text = page.title
        actionButton.setTitle(page.buttonTitle, for: .normal)
    }
    
    @objc private func buttonTapped() {
        onButtonTap?()
    }
}
