//
//  RotateView.swift
//  FoundationProj
//
//  Created by baedy on 2020/07/12.
//  Copyright (c) 2020 baedy. All rights reserved.
//

import UIKit
import SnapKit
import Then
import RxSwift
import RxCocoa

class RotateView: UIBasePreviewType {
    
    // MARK: - Model type implemente
    typealias Model = Void
    
    // MARK: - init
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupLayout()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - View
    lazy var rotateButton1 = AutoRotateButton().then{
        $0.setImage(#imageLiteral(resourceName: "mr_btn_checkbox_on"), for: .normal)
        $0.setTitle("test", for: .normal)
        $0.setTitleColor(.black, for: .normal)
        $0.centerImageAndButton(10, imageOnTop: true)
    }
    
    // MARK: - DI
    
    // MARK: - Methods
    func setupLayout() {
        self.addSubview(rotateButton1)
        rotateButton1.snp.makeConstraints { (make) in
            make.center.equalToSuperview()
            
        }
    }
    
    func setupDI(observable: Observable<UIDeviceOrientation>){
        self.rotateButton1.setupDIRotate(observable: observable)
    }
    
    func setupDI(observable: Observable<[Model]>) {
        // model Dependency Injection
    }
}


// MARK: - PreView
#if canImport(SwiftUI) && DEBUG
import SwiftUI

@available(iOS 13.0, *)
struct Rotate_Previews: PreviewProvider {
    static var previews: some View {
        //        Group {
        //            ForEach(UIView.previceSupportDevices, id: \.self) { deviceName in
        //                DebugPreviewView {
        //                    return RotateView()
        //                }.previewDevice(PreviewDevice(rawValue: deviceName))
        //                    .previewDisplayName(deviceName)
        //                    .previewLayout(.sizeThatFits)
        //            }
        //        }        
        Group {
            DebugPreviewView {
                let view = RotateView()
                //                .then {
                //                    $0.setupDI(observable: Observable.just([]))
                //                }
                return view
            }
        }
    }
}
#endif
