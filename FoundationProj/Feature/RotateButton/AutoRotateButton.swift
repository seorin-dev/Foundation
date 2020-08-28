//
//  AutoRotateButton.swift
//  FoundationProj
//
//  Created by baedy on 2020/07/12.
//  Copyright © 2020 baedy. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class AutoRotateButton: UIButton {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupDIRotate(observable: Observable<UIDeviceOrientation>){
        observable.subscribe(onNext: self.rotate(withOrientation:)).disposed(by: rx.disposeBag)
    }
    
    func rotate(withOrientation orientation: UIDeviceOrientation){
        var angle: Double?
        
        switch orientation {
        case .portrait:
            angle = 0
            break
        case .landscapeRight:
            angle = Double.pi / 2
            break
        default:
            break
        }
        
        if let angle = angle {
            let transform = CGAffineTransform(rotationAngle: CGFloat(angle))
            UIView.animate(withDuration: 0.3, animations: {
                self.transform = transform
            })
        }
    }
}
