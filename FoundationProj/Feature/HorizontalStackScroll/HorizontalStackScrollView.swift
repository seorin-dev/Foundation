//
//  HorizontalStackScrollView.swift
//  FoundationProj
//
//  Created by baedy on 2020/06/16.
//  Copyright (c) 2020 baedy. All rights reserved.
//

import UIKit
import SnapKit
import Then
import RxSwift
import RxCocoa

class HorizontalStackScrollView: UIBasePreviewType {
    
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
    lazy var label = UILabel().then {
        $0.text = "HorizontalStackScroll View"
        $0.textColor = .red
    }
    
    let hssView = HorizontalStackView()
    let container = UIView()
    
    // MARK: - Outlets
    
    // MARK: - Methods
    func setupLayout() {
        self.addSubview(container)
        
        container.snp.makeConstraints{
            $0.top.equalToSafeAreaAuto(self)
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(50)
        }
        
        container.addSubview(hssView)        
    }
    
    func setupDI(observable: Observable<[Model]>) {
        // model Dependency Injection
    }
}


// MARK: - PreView
#if canImport(SwiftUI) && DEBUG
import SwiftUI

@available(iOS 13.0, *)
struct HorizontalStackScroll_Previews: PreviewProvider {
    static var previews: some View {
        //        Group {
        //            ForEach(UIView.previceSupportDevices, id: \.self) { deviceName in
        //                DebugPreviewView {
        //                    return HorizontalStackScrollView()
        //                }.previewDevice(PreviewDevice(rawValue: deviceName))
        //                    .previewDisplayName(deviceName)
        //                    .previewLayout(.sizeThatFits)
        //            }
        //        }        
        Group {
            DebugPreviewView {
                let view = HorizontalStackScrollView()
                //                .then {
                //                    $0.setupDI(observable: Observable.just([]))
                //                }
                return view
            }
        }
    }
}
#endif
