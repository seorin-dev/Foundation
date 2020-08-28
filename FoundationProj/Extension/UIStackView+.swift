//
//  UIStackView+.swift
//  FoundationProj
//
//  Created by baedy on 2020/07/16.
//  Copyright © 2020 baedy. All rights reserved.
//

import UIKit

extension UIStackView {
    func removeArrangedSubviewCompletely(_ subview: UIView) {
        removeArrangedSubview(subview)
        subview.removeFromSuperview()
    }

    func removeAllArrangedSubviewsCompletely() {
        for subview in arrangedSubviews.reversed() {
            removeArrangedSubviewCompletely(subview)
        }
    }

    func addArrangedSubviews(_ subviews: [UIView]) {
        for subview in subviews {
            addArrangedSubview(subview)
        }
    }
}
