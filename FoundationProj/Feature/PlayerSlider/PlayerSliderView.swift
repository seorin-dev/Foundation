//
//  PlayerSliderView.swift
//  FoundationProj
//
//  Created by baedy on 2020/07/15.
//  Copyright © 2020 baedy. All rights reserved.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa

class PlayerSliderView: UIView {
    
    let playButtonImageSet = (play: "icCameraPlay", stop: "icCameraStop")
    let speedButtonImageSet = (x1: "icCameraX1", x02: "icCameraX02", x05: "icCameraX05", x07: "icCameraX07")
    let repeatButtonImageSet = (off: "icCameraRepeatOff", on: "icCameraRepeatOn")
    
    lazy var buttons = [playButton, speedButton, repeatButton]
    
    lazy var playButton = UIButton().then{
        $0.arImageSet(imageName: self.playButtonImageSet.play)
        $0.arSelectedImageSet(imageName: self.playButtonImageSet.stop)
    }
    
    lazy var sliderView = RangeSlider()
        
    lazy var speedButton = UIButton().then{
        $0.arImageSet(imageName: self.speedButtonImageSet.x1)
    }
    lazy var repeatButton = UIButton().then{
        $0.arImageSet(imageName: self.repeatButtonImageSet.off)
        $0.arSelectedImageSet(imageName: self.repeatButtonImageSet.on)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setupLayout(){
        self.addSubviews([playButton, sliderView, speedButton, repeatButton])
        playButton.snp.makeConstraints{
            $0.leading.top.bottom.equalToSuperview()
            $0.width.height.equalTo(38)
        }
        
        sliderView.snp.makeConstraints{
            $0.leading.equalTo(playButton.snp.trailing).offset(10)
            $0.top.bottom.equalToSuperview()
        }
        
        speedButton.snp.makeConstraints{
            $0.leading.equalTo(sliderView.snp.trailing).offset(12)
            $0.top.bottom.equalToSuperview()
            $0.width.height.equalTo(38)
        }
        
        repeatButton.snp.makeConstraints{
            $0.leading.equalTo(speedButton.snp.trailing).offset(7)
            $0.top.bottom.trailing.equalToSuperview()
            $0.width.height.equalTo(38)
        }
    }
    
    func setupSlider(type: SliderType){
        self.sliderView.type = type
        
        if type != .small{
            self.buttons.forEach{
                $0.isHidden = false
            }
        }
        
        UIView.animate(withDuration: 0.3, animations: {[unowned self] in
            self.buttons.forEach{
                $0.alpha = (type == .small) ? 0 : 1
            }
        }, completion: {[unowned self] _ in
            self.buttons.forEach{
                $0.isHidden = (type == .small)
            }
        })
    }
}
