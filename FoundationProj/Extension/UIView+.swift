//
//  UIView+.swift
//  FoundationProj
//
//  Created by baedy on 2020/05/28.
//  Copyright © 2020 baedy. All rights reserved.
//

import UIKit

extension UIView {
    func deepCopy() -> UIView {
        let archive = NSKeyedArchiver.archivedData(withRootObject: self)
        return NSKeyedUnarchiver.unarchiveObject(with: archive) as! UIView
    }

    func addSubviews(_ views: [UIView]) {
        _ = views.map { self.addSubview($0) }
    }
}
