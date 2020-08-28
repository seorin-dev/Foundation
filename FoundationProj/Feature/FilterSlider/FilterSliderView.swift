//
//  FilterSliderView.swift
//  FoundationProj
//
//  Created by baedy on 2020/08/19.
//  Copyright (c) 2020 baedy. All rights reserved.
//

import UIKit
import SnapKit
import Then
import RxSwift
import RxCocoa

class FilterSliderView: UIBasePreviewType {
    
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
    lazy var filterSlider = FilterSlider().then{
        $0.defaultValue = 50
        $0.delegate = self
    }
    
    lazy var defaultChangeButton = UIButton().then{
        $0.setTitle("랜덤 디폴트 체인지", for: .normal)
        $0.rx.tap.compactMap{
            (0...100).randomElement()
        }.subscribe(onNext: { [weak self] value in
            self?.filterSlider.defaultValue = value
        }).disposed(by: rx.disposeBag)
    }
    
    // MARK: - Outlets
    
    // MARK: - Methods
    func setupLayout() {
        self.backgroundColor = #colorLiteral(red: 0.501960814, green: 0.501960814, blue: 0.501960814, alpha: 1)
        self.addSubview(filterSlider)
        filterSlider.snp.makeConstraints { (make) in
            make.centerY.equalToSuperview()
            make.leading.equalToSuperview().offset(20)
            make.trailing.equalToSuperview().offset(-20)
            make.height.equalTo(52)
        }
        
        self.addSubview(defaultChangeButton)
        
        defaultChangeButton.snp.makeConstraints{
            $0.top.equalToSuperview().offset(100)
            $0.height.equalTo(50)
            $0.width.equalTo(200)
            $0.centerX.equalToSuperview()
        }
    }
    
    func setupDI(observable: Observable<[Model]>) {
        // model Dependency Injection
    }
}

extension FilterSliderView: FilterSliderDelegate {
    func filterSliderSeek(_ slider: FilterSlider, seekValue: Int) {
        Log.d("current Value : \(seekValue)")
    }
}


// MARK: - PreView
#if canImport(SwiftUI) && DEBUG
import SwiftUI

@available(iOS 13.0, *)
struct FilterSlider_Previews: PreviewProvider {
    static var previews: some View {
        //        Group {
        //            ForEach(UIView.previceSupportDevices, id: \.self) { deviceName in
        //                DebugPreviewView {
        //                    return FilterSliderView()
        //                }.previewDevice(PreviewDevice(rawValue: deviceName))
        //                    .previewDisplayName(deviceName)
        //                    .previewLayout(.sizeThatFits)
        //            }
        //        }        
        Group {
            DebugPreviewView {
                let view = FilterSliderView()
                //                .then {
                //                    $0.setupDI(observable: Observable.just([]))
                //                }
                return view
            }
        }
    }
}
#endif
