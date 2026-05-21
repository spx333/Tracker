//
//  EmojiCollectionViewCell.swift
//  Tracker
//
//  Created by Сергей Петров on 14.05.2026.
//

import UIKit

final class EmojiCollectionViewCell: UICollectionViewCell {
    static let reuseIdentifier = "EmojiCollectionViewCell"

    let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 32)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)

        contentView.layer.cornerRadius = 16
        contentView.clipsToBounds = true

        contentView.addSubview(titleLabel)

        NSLayoutConstraint.activate([
            titleLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            titleLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        ])
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(with emoji: String, isChosen: Bool) {
        titleLabel.text = emoji
        contentView.backgroundColor = isChosen ? UIColor.systemGray5 : .clear
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        contentView.backgroundColor = .clear
    }
}
