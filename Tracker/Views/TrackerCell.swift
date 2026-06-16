//
//  TrackerCell.swift
//  Tracker
//
//  Created by Сергей Петров on 30.04.2026.
//

import UIKit

final class TrackerCell: UICollectionViewCell {
    static let reuseIdentifier = "TrackerCell"
    
    private let cardView = UIView()
    private let emojiBackgroundView = UIView()
    private let emojiLabel = UILabel()
    private let titleLabel = UILabel()
    private let countLabel = UILabel()
    private let doneButton = UIButton(type: .system)
    
    var onDoneButtonTap: (() -> Void)?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupViews() {
        contentView.backgroundColor = .clear
        
        [cardView, emojiBackgroundView, emojiLabel, titleLabel, countLabel, doneButton].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
        
        cardView.layer.cornerRadius = 16
        cardView.clipsToBounds = true
        
        emojiBackgroundView.backgroundColor = UIColor.white.withAlphaComponent(0.3)
        emojiBackgroundView.layer.cornerRadius = 12
        emojiBackgroundView.clipsToBounds = true
        
        emojiLabel.font = .systemFont(ofSize: 16)
        emojiLabel.textAlignment = .center
        
        titleLabel.font = .systemFont(ofSize: 12, weight: .medium)
        titleLabel.textColor = .white
        titleLabel.numberOfLines = 2
        
        countLabel.font = .systemFont(ofSize: 12, weight: .medium)
        countLabel.textColor = .label
        
        doneButton.tintColor = .white
        doneButton.layer.cornerRadius = 17
        doneButton.clipsToBounds = true
        doneButton.addTarget(self, action: #selector(doneButtonTapped), for: .touchUpInside)
        
        contentView.addSubview(cardView)
        cardView.addSubview(emojiBackgroundView)
        emojiBackgroundView.addSubview(emojiLabel)
        cardView.addSubview(titleLabel)
        contentView.addSubview(countLabel)
        contentView.addSubview(doneButton)
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            cardView.topAnchor.constraint(equalTo: contentView.topAnchor),
            cardView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            cardView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            cardView.heightAnchor.constraint(equalToConstant: 90),
            
            emojiBackgroundView.topAnchor.constraint(equalTo: cardView.topAnchor, constant: 12),
            emojiBackgroundView.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 12),
            emojiBackgroundView.widthAnchor.constraint(equalToConstant: 24),
            emojiBackgroundView.heightAnchor.constraint(equalToConstant: 24),
            
            emojiLabel.centerXAnchor.constraint(equalTo: emojiBackgroundView.centerXAnchor),
            emojiLabel.centerYAnchor.constraint(equalTo: emojiBackgroundView.centerYAnchor),
            
            titleLabel.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 12),
            titleLabel.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -12),
            titleLabel.bottomAnchor.constraint(equalTo: cardView.bottomAnchor, constant: -12),
            
            countLabel.topAnchor.constraint(equalTo: cardView.bottomAnchor, constant: 16),
            countLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 12),
            
            doneButton.centerYAnchor.constraint(equalTo: countLabel.centerYAnchor),
            doneButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -12),
            doneButton.widthAnchor.constraint(equalToConstant: 34),
            doneButton.heightAnchor.constraint(equalToConstant: 34)
        ])
    }
    
    func configure(with tracker: Tracker, completedDays: Int, isCompleted: Bool) {
        cardView.backgroundColor = tracker.color
        emojiLabel.text = tracker.emoji
        titleLabel.text = tracker.name
        countLabel.text = daysString(for: completedDays)
        
        doneButton.backgroundColor = tracker.color
        doneButton.alpha = isCompleted ? 0.3 : 1.0
        
        let imageName = isCompleted ? "checkmark" : "plus"
        doneButton.setImage(UIImage(systemName: imageName), for: .normal)
    }
    
    private func daysString(for count: Int) -> String {
        String.localizedStringWithFormat(
             NSLocalizedString("days_count", comment: "Количество дней выполнения трекера"),
             count
         )
    }
    
    @objc private func doneButtonTapped() {
        onDoneButtonTap?()
    }
}
