//
//  ZoomingView.swift
//  FoundationProj
//
//  Created by baedy on 2020/05/12.
//  Copyright (c) 2020 baedy. All rights reserved.
//

import UIKit
import SnapKit
import Then
import RxSwift
import RxCocoa
import NSObject_Rx

class ZoomingView<T>: UIBasePreviewType {
    
    // MARK: - Model type implemente
    typealias Model = UIImage
    typealias Trigger = ZoomingViewModel<T>.ActionTrigger
    
    // MARK: - init
    override init(frame:     CGRect) {
        super.init(frame: frame)
        setupLayout()
        actionBind()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - View
    
    let backButton = UIButton().then{
        $0.backgroundColor = .blue
        $0.setTitle("닫기", for: .normal)
    }
    
    lazy var imageSlider = ImageSlider().then{
        $0.backgroundColor = .clear
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.collectionView.register(ZoomImageCell<T>.self, forCellWithReuseIdentifier: ZoomImageCell<T>.reuseIdentifier)
    }
    
    // MARK: - Outlets
    let actionTrigger = PublishRelay<ZoomingViewModel<T>.ActionTrigger>()
    
    // MARK: - Methods
    func setupLayout() {
        self.addSubview(imageSlider)
        imageSlider.snp.makeConstraints{
            $0.top.leading.trailing.bottom.equalToSuperview()
        }
        
        self.addSubview(backButton)
        backButton.snp.makeConstraints {
            $0.width.equalTo(45)
            $0.height.equalTo(30)
            $0.top.leading.equalToSafeAreaAuto(self).offset(15)
        }
        
       
    }
    
    func actionBind(){
        backButton.rx.tap.map{
            Trigger.close
        }.bind(to: self.actionTrigger).disposed(by: rx.disposeBag)
    }
    
    func setupDI<T>(generic: Observable<[T]>) -> Self {
        generic.asObservable()
            .bind(to: imageSlider.collectionView.rx.items(cellIdentifier: ZoomImageCell<T>.reuseIdentifier, cellType: ZoomImageCell<T>.self)){ index, item, cell in
                DispatchQueue.main.async {
                    cell.genericRelay.accept(item)
                }
        }.disposed(by: rx.disposeBag)
        
        return self
    }
    
    func setupDI<E>(generic: PublishRelay<E>) -> Self {
        if let generic = generic as? PublishRelay<Trigger>{
            self.actionTrigger.bind(to: generic).disposed(by: rx.disposeBag)
        }
        return self
    }
    
    func setupDI<E>(generic: BehaviorRelay<E>) -> Self{
        if let currentRelay = generic as? BehaviorRelay<Int>{
            let value = currentRelay.value
            imageSlider.current.bind(to: currentRelay).disposed(by: rx.disposeBag)
            
            imageSlider.current.accept(value)
        }
        return self
    }
}


// MARK: - PreView
#if canImport(SwiftUI) && DEBUG
import SwiftUI

@available(iOS 13.0, *)
struct Zooming_Previews: PreviewProvider {
    static var previews: some View {
        //        Group {
        //            ForEach(UIView.previceSupportDevices, id: \.self) { deviceName in
        //                DebugPreviewView {
        //                    return ZoomingView()
        //                }.previewDevice(PreviewDevice(rawValue: deviceName))
        //                    .previewDisplayName(deviceName)
        //                    .previewLayout(.sizeThatFits)
        //            }
        //        }        
        Group {
            DebugPreviewView {
                let view = ZoomingView<UIImage>()
                //                .then {
                //                    $0.setupDI(observable: Observable.just([]))
                //                }
                return view
            }
        }
    }
}
#endif
