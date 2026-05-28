//
//  UITextField+Padding.swift
//  Tracker
//
//  Created by Сергей Петров on 28.05.2026.
//

import UIKit

extension UITextField {
    func setLeftPadding(_ amount: CGFloat) {
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: amount, height: frame.height))
        leftView = paddingView
        leftViewMode = .always
    }
}
