//
//  Snapkit+.swift
//  FoundationProj
//
//  Created by baedy on 2020/05/27.
//  Copyright © 2020 baedy. All rights reserved.
//

import SnapKit
import UIKit

extension ConstraintMakerRelatable {
    @discardableResult
    public func equalToSafeAreaAuto(_ view: UIView, _ file: String = #file, _ line: UInt = #line) -> ConstraintMakerEditable {
        if #available(iOS 11.0, *) {
            return self.equalTo(view.safeAreaLayoutGuide, file, line)
        }
        return self.equalToSuperview()
    }
}
