//
//  ColorCollectionViewCell.swift
//  Tracker
//
//  Created by Сергей Петров on 14.05.2026.
//

import UIKit

final class ColorCollectionViewCell: UICollectionViewCell {
    static let reuseIdentifier = "ColorCollectionViewCell"

    private let colorView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 8
        view.clipsToBounds = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)

        contentView.layer.cornerRadius = 8
        contentView.addSubview(colorView)

        NSLayoutConstraint.activate([
            colorView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 6),
            colorView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 6),
            colorView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -6),
            colorView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -6)
        ])
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(with color: UIColor, isChosen: Bool) {
        colorView.backgroundColor = color
        contentView.layer.borderWidth = isChosen ? 3 : 0
        contentView.layer.borderColor = isChosen
            ? color.withAlphaComponent(0.3).cgColor
            : UIColor.clear.cgColor
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        contentView.layer.borderWidth = 0
        contentView.layer.borderColor = UIColor.clear.cgColor
    }
}
