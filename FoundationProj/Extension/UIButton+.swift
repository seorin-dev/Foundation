//
//  UIButton+.swift
//  FoundationProj
//
//  Created by baedy on 2020/07/12.
//  Copyright © 2020 baedy. All rights reserved.
//

import UIKit

extension UIButton{
    
    func centerImageAndButton(_ gap: CGFloat, imageOnTop: Bool) {
        guard let imageView = self.imageView,
            let titleLabel = self.titleLabel else { return }

        let sign: CGFloat = imageOnTop ? 1 : -1
        let imageSize = imageView.frame.size
        let titleSize = titleLabel.frame.size

        self.titleEdgeInsets = UIEdgeInsets(top: (imageSize.height + gap) * sign, left: -imageSize.width, bottom: 0, right: 0)

        self.imageEdgeInsets = UIEdgeInsets(top: -(titleSize.height + gap) * sign, left: 0, bottom: 0, right: -titleSize.width)
    }
    
    /// Nor, Pre, Dim matching
    func arImageSet(imageName: String) {
        self.setImage(#imageLiteral(resourceName: imageName + "Nor"), for: .normal)
        self.setImage(#imageLiteral(resourceName: imageName + "Pre"), for: .highlighted)
        self.setImage(#imageLiteral(resourceName: imageName + "Dim"), for: .disabled)
    }
    
    func arSelectedImageSet(imageName: String) {
        self.setImage(#imageLiteral(resourceName: imageName + "Nor"), for: [.selected])
        self.setImage(#imageLiteral(resourceName: imageName + "Pre"), for: [.selected, .highlighted])
        self.setImage(#imageLiteral(resourceName: imageName + "Dim"), for: [.selected, .disabled])
    }
}
