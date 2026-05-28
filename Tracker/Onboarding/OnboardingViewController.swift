//
//  OnboardingViewController.swift
//  Tracker
//
//  Created by Сергей Петров on 28.05.2026.
//

import UIKit

final class OnboardingViewController: UIPageViewController {
    
    var onFinish: (() -> Void)?
    
    private let pages: [OnboardingPage] = [
        OnboardingPage(
            backgroundImage: UIImage(resource: .onboardingBlue),
            title: "Отслеживайте только\nто, что хотите",
            buttonTitle: "Вот это технологии!"
        ),
        OnboardingPage(
            backgroundImage: UIImage(resource: .onboardingRed),
            title: "Даже если это\nне литры воды и йога",
            buttonTitle: "Вот это технологии!"
        )
    ]
    
    private lazy var controllers: [OnboardingContentViewController] = {
        pages.map { page in
            let viewController = OnboardingContentViewController()
            viewController.page = page
            viewController.onButtonTap = { [weak self] in
                self?.finishOnboarding()
            }
            return viewController
        }
    }()
    
    private lazy var pageControl: UIPageControl = {
        let pageControl = UIPageControl()
        pageControl.numberOfPages = controllers.count
        pageControl.currentPage = 0
        pageControl.currentPageIndicatorTintColor = .black
        pageControl.pageIndicatorTintColor = .lightGray
        pageControl.translatesAutoresizingMaskIntoConstraints = false
        return pageControl
    }()
    
    init() {
        super.init(
            transitionStyle: .scroll,
            navigationOrientation: .horizontal,
            options: nil
        )
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        nil
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        dataSource = self
        delegate = self
        
        if let first = controllers.first {
            setViewControllers([first], direction: .forward, animated: true)
        }
        
        setupPageControl()
    }
    
    private func setupPageControl() {
        view.addSubview(pageControl)
        
        NSLayoutConstraint.activate([
            pageControl.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -130),
            pageControl.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
    }
    
    private func finishOnboarding() {
        onFinish?()
    }
}

extension OnboardingViewController: UIPageViewControllerDataSource {
    
    func pageViewController(
        _ pageViewController: UIPageViewController,
        viewControllerBefore viewController: UIViewController
    ) -> UIViewController? {
        guard let viewController = viewController as? OnboardingContentViewController,
              let index = controllers.firstIndex(of: viewController) else {
            return nil
        }
        
        let previousIndex = index - 1
        guard previousIndex >= 0 else { return nil }
        
        return controllers[previousIndex]
    }
    
    func pageViewController(
        _ pageViewController: UIPageViewController,
        viewControllerAfter viewController: UIViewController
    ) -> UIViewController? {
        guard let viewController = viewController as? OnboardingContentViewController,
              let index = controllers.firstIndex(of: viewController) else {
            return nil
        }
        
        let nextIndex = index + 1
        guard nextIndex < controllers.count else { return nil }
        
        return controllers[nextIndex]
    }
}

extension OnboardingViewController: UIPageViewControllerDelegate {
    
    func pageViewController(
        _ pageViewController: UIPageViewController,
        didFinishAnimating finished: Bool,
        previousViewControllers: [UIViewController],
        transitionCompleted completed: Bool
    ) {
        guard completed,
              let currentViewController = viewControllers?.first as? OnboardingContentViewController,
              let index = controllers.firstIndex(of: currentViewController) else {
            return
        }
        
        pageControl.currentPage = index
    }
}
