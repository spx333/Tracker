//
//  StatisticsViewController.swift
//  Tracker
//
//  Created by Сергей Петров on 24.04.2026.
//

import UIKit

final class StatisticsViewController: UIViewController {
    
    private let trackerRecordStore: TrackerRecordStore

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = NSLocalizedString("statistics_title", comment: "Statistics screen title")
        label.font = .systemFont(ofSize: 34, weight: .bold)
        label.textColor = .label
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let emptyImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(resource: .statisticsEmptyState)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()

    private let emptyLabel: UILabel = {
        let label = UILabel()
        label.text = NSLocalizedString("statistics_empty_placeholder", comment: "Empty statistics placeholder")
        label.font = .systemFont(ofSize: 12, weight: .medium)
        label.textColor = .label
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let statisticCardView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = 16
        view.layer.masksToBounds = true
        return view
    }()

    private let statisticContentView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .systemBackground
        view.layer.cornerRadius = 16
        return view
    }()

    private let valueLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 34, weight: .bold)
        label.textColor = .label
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let descriptionLabel: UILabel = {
        let label = UILabel()
        label.text = NSLocalizedString("statistics_completed_title", comment: "Completed trackers statistic title")
        label.font = .systemFont(ofSize: 12, weight: .medium)
        label.textColor = .label
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    init(trackerRecordStore: TrackerRecordStore) {
        self.trackerRecordStore = trackerRecordStore
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        nil
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        reloadStatistics()
    }

    private func setupUI() {
        view.backgroundColor = .trackerWhite
        
        view.addSubview(titleLabel)
        view.addSubview(emptyImageView)
        view.addSubview(emptyLabel)
        view.addSubview(statisticCardView)

        statisticCardView.addSubview(statisticContentView)
        statisticContentView.addSubview(valueLabel)
        statisticContentView.addSubview(descriptionLabel)

        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 44),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),

            emptyImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emptyImageView.widthAnchor.constraint(equalToConstant: 80),
            emptyImageView.heightAnchor.constraint(equalToConstant: 80),
            emptyImageView.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -20),

            emptyLabel.topAnchor.constraint(equalTo: emptyImageView.bottomAnchor, constant: 8),
            emptyLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),

            statisticCardView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 77),
            statisticCardView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            statisticCardView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            statisticCardView.heightAnchor.constraint(equalToConstant: 90),

            statisticContentView.topAnchor.constraint(equalTo: statisticCardView.topAnchor, constant: 1),
            statisticContentView.leadingAnchor.constraint(equalTo: statisticCardView.leadingAnchor, constant: 1),
            statisticContentView.trailingAnchor.constraint(equalTo: statisticCardView.trailingAnchor, constant: -1),
            statisticContentView.bottomAnchor.constraint(equalTo: statisticCardView.bottomAnchor, constant: -1),

            valueLabel.topAnchor.constraint(equalTo: statisticContentView.topAnchor, constant: 12),
            valueLabel.leadingAnchor.constraint(equalTo: statisticContentView.leadingAnchor, constant: 12),

            descriptionLabel.leadingAnchor.constraint(equalTo: statisticContentView.leadingAnchor, constant: 12),
            descriptionLabel.bottomAnchor.constraint(equalTo: statisticContentView.bottomAnchor, constant: -12)
        ])

        statisticCardView.backgroundColor = makeGradientColor()
    }

    private func reloadStatistics() {
        let completedCount = trackerRecordStore.fetchRecords().count
        valueLabel.text = "\(completedCount)"

        let isEmpty = completedCount == 0
        emptyImageView.isHidden = !isEmpty
        emptyLabel.isHidden = !isEmpty
        statisticCardView.isHidden = isEmpty
    }

    private func makeGradientColor() -> UIColor {
        UIColor(patternImage: gradientImage(size: CGSize(width: 343, height: 90)))
    }

    private func gradientImage(size: CGSize) -> UIImage {
        let renderer = UIGraphicsImageRenderer(size: size)

        return renderer.image { context in
            let colors = [
                UIColor.red.cgColor,
                UIColor.orange.cgColor,
                UIColor.blue.cgColor
            ] as CFArray

            let locations: [CGFloat] = [0.0, 0.5, 1.0]

            guard let gradient = CGGradient(
                colorsSpace: CGColorSpaceCreateDeviceRGB(),
                colors: colors,
                locations: locations
            ) else {
                return
            }

            context.cgContext.drawLinearGradient(
                gradient,
                start: CGPoint(x: 0, y: size.height / 2),
                end: CGPoint(x: size.width, y: size.height / 2),
                options: []
            )
        }
    }
} 
