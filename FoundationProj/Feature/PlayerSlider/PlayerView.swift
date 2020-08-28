//
//  PlayerView.swift
//  FoundationProj
//
//  Created by baedy on 2020/07/15.
//  Copyright (c) 2020 baedy. All rights reserved.
//

import UIKit
import SnapKit
import Then
import RxSwift
import RxCocoa

class PlayerView: UIBasePreviewType {
    
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
    lazy var sliderContainerView = PlayerSliderView().then{
        $0.backgroundColor = .purple ~ 50%
    }
//
//    /// 뒤로가기 버튼
//    lazy var exitButton = AutoRotateButton().then {
//        $0.arImageSet(imageName: "icCameraBack")
//    }

    lazy var bottomView = UIView().then{
        $0.backgroundColor = #colorLiteral(red: 0.5843137503, green: 0.8235294223, blue: 0.4196078479, alpha: 1)
    }
    
    lazy var stackView = UIStackView().then{
        $0.axis = .horizontal
        $0.distribution = .fillProportionally
        $0.alignment = .center
        $0.spacing = 10
    }
    
    lazy var currentSlider = UISlider().then{
        $0.backgroundColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        $0.tintColor = #colorLiteral(red: 0.8549019694, green: 0.250980407, blue: 0.4784313738, alpha: 1)
        $0.maximumValue = 1
        $0.minimumValue = 0
        $0.isContinuous = true
        $0.rx.value.map{ Double($0) }
            .subscribe(onNext: self.sliderCurrentValueChange(current:))
            .disposed(by: rx.disposeBag)
    }
    
    lazy var playButton = UIButton().then{
        $0.setTitle("type play", for: .normal)
        $0.rx.tap.map{ SliderType.play }
            .subscribe(onNext: self.sliderTypeChange(type:))
            .disposed(by: rx.disposeBag)
    }
    
    lazy var rangeButton = UIButton().then{
        $0.setTitle("type range", for: .normal)
        $0.rx.tap.map{ SliderType.range }
            .subscribe(onNext: self.sliderTypeChange(type:))
            .disposed(by: rx.disposeBag)
    }
    
    lazy var smallButton = UIButton().then{
        $0.setTitle("type small", for: .normal)
        $0.rx.tap.map{ SliderType.small }
            .subscribe(onNext: self.sliderTypeChange(type:))
            .disposed(by: rx.disposeBag)
    }
    
    // MARK: - Outlets
    
    // MARK: - Methods
    func setupLayout() {
        self.backgroundColor = #colorLiteral(red: 0.501960814, green: 0.501960814, blue: 0.501960814, alpha: 1)
        self.addSubviews([sliderContainerView, stackView, currentSlider, bottomView])
        stackView.addArrangedSubviews([playButton, rangeButton, smallButton])
        
//        exitButton.snp.makeConstraints {
//            $0.top.equalToSuperview().offset(51)
//            $0.leading.equalToSuperview().offset(15)
//            $0.width.height.equalTo(42)
//        }
        
        sliderContainerView.snp.makeConstraints{
            $0.height.equalTo(38)
            $0.width.equalToSuperview().offset(-100)
            $0.centerX.equalToSuperview()
            $0.bottom.equalToSuperview().offset(-161)
        }
        
        currentSlider.snp.makeConstraints{
            $0.height.equalTo(10)
            $0.width.equalToSuperview().offset(-80)
            $0.centerX.equalToSuperview()
            $0.centerY.equalToSuperview()
        }
        
        stackView.snp.makeConstraints{
            $0.height.equalTo(40)
            $0.width.equalToSuperview().offset(-120)
            $0.top.equalToSuperview().offset(100)
            $0.centerX.equalToSuperview()
        }
        
        bottomView.snp.makeConstraints{
            $0.leading.trailing.bottom.equalToSuperview()
            $0.height.equalTo(144)
        }
    }
    
    func sliderTypeChange(type: SliderType){
        self.sliderContainerView.setupSlider(type: type)
    }
    
    func sliderCurrentValueChange(current: Double){
        self.sliderContainerView.sliderView.setCurrentValue(current: current)
    }
    
    func setupDI(observable: Observable<UIDeviceOrientation>){
        observable.subscribe(onNext: rotateView(orientation: )).disposed(by: rx.disposeBag)
    }
    
    func rotateView(orientation: UIDeviceOrientation){

        /// xs, 11 pro (true) / 11, 11max (false)
        let is375 = UIApplication.shared.keyWindowInConnectedScenes?.frame.width == 375
        
        if orientation.isLandscape{
            // width 531
            sliderContainerView.snp.updateConstraints{
                $0.width.equalToSuperview().offset(172 + (is375 ? -16 : 30))
                // 얘가 바닥으로부터의 높이 지정 bottom 0의 경우 (-187.5)가 기본 값
                $0.centerX.equalToSuperview().offset(-189 + 17 + (is375 ? 16.5 : 0))
                // 얘가 leading 기본값 -593
                $0.bottom.equalToSuperview().offset(-585 + 117 + (is375 ?  54.5 : 15))
            }
            UIView.animate(withDuration: 0.3, animations: {

                self.sliderContainerView.transform = CGAffineTransform(rotationAngle: CGFloat(Double.pi) / 2)
                self.layoutIfNeeded()
            })
        }else if orientation.isPortrait{
            sliderContainerView.snp.updateConstraints{
                $0.width.equalToSuperview().offset(-30)
                $0.centerX.equalToSuperview()
                $0.bottom.equalToSuperview().offset(-161)
            }
            UIView.animate(withDuration: 0.3, animations: {
                self.sliderContainerView.transform = CGAffineTransform(rotationAngle: 0)
                self.layoutIfNeeded()
            })
        }
    }
    
    func setupDI(observable: Observable<[Model]>) {
        // model Dependency Injection
    }
}


// MARK: - PreView
#if canImport(SwiftUI) && DEBUG
import SwiftUI

@available(iOS 13.0, *)
struct Player_Previews: PreviewProvider {
    static var previews: some View {
        //        Group {
        //            ForEach(UIView.previceSupportDevices, id: \.self) { deviceName in
        //                DebugPreviewView {
        //                    return PlayerView()
        //                }.previewDevice(PreviewDevice(rawValue: deviceName))
        //                    .previewDisplayName(deviceName)
        //                    .previewLayout(.sizeThatFits)
        //            }
        //        }        
        Group {
            DebugPreviewView {
                let view = PlayerView()
                //                .then {
                //                    $0.setupDI(observable: Observable.just([]))
                //                }
                return view
            }
        }
    }
}
#endif
