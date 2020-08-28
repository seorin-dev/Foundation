//
//  ImageSliderCellPorotol.swift
//  FoundationProj
//
//  Created by baedy on 2020/05/28.
//  Copyright © 2020 baedy. All rights reserved.
//

import UIKit

protocol ImageSliderCell: class {
    var scrollView: UIScrollView { get }
    var shotImageView: UIImageView { get }
    var viewBounds: CGSize { get }
    var isImage: Bool! { get }
}

extension ImageSliderCell where Self: UIScrollViewDelegate{

    func updateZoomScaleForSize(_ matchingSize: CGSize?, _ scrollView: UIScrollView, _ containerSize: CGSize) {
        guard let imageSize = matchingSize else { return }
        let widthScale = containerSize.width / imageSize.width
        let heightScale = containerSize.height / imageSize.height
        let minScale = min(widthScale, heightScale)
        scrollView.minimumZoomScale = minScale

        scrollView.zoomScale = minScale

        scrollView.maximumZoomScale = minScale * 3
        
    }

    func updateConstraintsForSize(_ size: CGSize) {
        let yOffset = max(0, (size.height - shotImageView.frame.height) / 2)

        let xOffset = max(0, (size.width - shotImageView.frame.width) / 2)

        shotImageView.snp.remakeConstraints {
            $0.top.equalTo(scrollView.snp.top).offset(yOffset)
            $0.bottom.equalTo(scrollView.snp.bottom).offset(-yOffset)
            $0.leading.equalTo(scrollView.snp.leading).offset(xOffset)
            $0.trailing.equalTo(scrollView.snp.trailing).offset(-xOffset)
        }

        let contentHeight = yOffset * 2 + self.shotImageView.frame.height
        let contentWidth = xOffset * 2 + self.shotImageView.frame.width
        
        self.scrollView.contentSize = CGSize(width: contentWidth, height: contentHeight)
    }
    
}
