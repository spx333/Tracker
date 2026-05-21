//
//  UIViewController+Keyboard.swift
//  Tracker
//
//  Created by Сергей Петров on 14.05.2026.
//

import UIKit

extension UIViewController {

    func setupTapToDismissKeyboard() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboardByTap))
        tapGesture.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGesture)
    }
    
    @objc private func dismissKeyboardByTap() {
        view.endEditing(true)
    }
}
