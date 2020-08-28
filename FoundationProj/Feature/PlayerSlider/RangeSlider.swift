//
//  RangeSlider.swift
//  FoundationProj
//
//  Created by baedy on 2020/07/15.
//  Copyright © 2020 baedy. All rights reserved.
//

import UIKit
import QuartzCore
import SnapKit

enum SliderType{
    case play
    case range
    case small
}

protocol RangeSliderDelegate: class {
    func rangeSliderSeek(_ rangeSlider: RangeSlider, seekValue: Double)
    func rangeSliderChangeRange(_ rangeSlider: RangeSlider, start: Double, end: Double)
    func rangeSliderTouchInSmall(_ rangeSlider: RangeSlider)
}

class RangeSlider: UIControl {
    
    weak var delegate: RangeSliderDelegate?
    
    var type: SliderType = .play{
        didSet{
            if type != .small{
                upperThumbLayer.isHidden = type == .play
                lowerThumbLayer.isHidden = type == .play
                playerThumbLayer.isHidden = type != .play
                
                /// 위치값 초기화
                lowerValue = currentValue
                upperValue = 1.0 
            }else{
                upperThumbLayer.isHidden = true
                lowerThumbLayer.isHidden = true
                playerThumbLayer.isHidden = true
            }
            UIView.animate(withDuration: 0.3, animations: {[unowned self] in
                self.animateLayer()
            })
            
        }
    }
    
    var minimumValue = 0.0
    var maximumValue = 1.0
    
    /// value range 0.0 ~ 1.0
    var currentValue = 0.0
    func setCurrentValue(current: Double){
        self.currentValue = current
        animateLayer()
    }
    
    var lowerValue = 0.0
    var upperValue = 1.0
    
    var trackLayerHeight: CGFloat = 3
    var smallTrackWidth: CGFloat = 70
    
    lazy var trackLayer = RangeSliderTrackLayer().then{
        $0.shadowColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1).cgColor
        $0.shadowOpacity = 0.2
        $0.shadowRadius = 5
        $0.borderColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 0.3).cgColor
        $0.borderWidth = 1.0
        $0.cornerRadius = self.trackLayerHeight / 2
    }
    
    let lowerThumbLayer = RangeSliderThumbLayer().then{
        $0.contents = #imageLiteral(resourceName: "btnRepeatHandlerA").cgImage
        $0.contentsGravity = .resizeAspectFill
        $0.isGeometryFlipped = true
    }
    
    let upperThumbLayer = RangeSliderThumbLayer().then{
        $0.contents = #imageLiteral(resourceName: "btnRepeatHandlerB").cgImage
        $0.contentsGravity = .resizeAspectFill
        $0.isGeometryFlipped = true
    }
    
    let playerThumbLayer = RangeSliderThumbLayer().then{
        $0.contents = #imageLiteral(resourceName: "btnPlayerHandlerCamera").cgImage
        $0.contentsGravity = .resizeAspectFill
        $0.isGeometryFlipped = true
    }

    var previousLocation = CGPoint()
    

    var trackTintColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1) ~ 80%
    var trackHighlightTintColor = #colorLiteral(red: 0.9529411765, green: 0.3529411765, blue: 0.4588235294, alpha: 1)
    var trackLowerColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
    
    var curvaceousness : CGFloat = 1.0
    
    var thumbWidth: CGFloat {
        return 30.0
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        trackLayer.rangeSlider = self
        layer.addSublayer(trackLayer)
        
        lowerThumbLayer.rangeSlider = self
        layer.addSublayer(lowerThumbLayer)
        
        upperThumbLayer.rangeSlider = self
        layer.addSublayer(upperThumbLayer)
        
        playerThumbLayer.rangeSlider = self
        layer.addSublayer(playerThumbLayer)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSublayers(of layer: CALayer) {
        super.layoutSublayers(of: layer)
        updateLayerFrames()
    }
    
    func updateLayerFrames() {
        
        trackLayer.frame = CGRect(x: 0, y: bounds.height / 2 - trackLayerHeight / 2, width: bounds.width, height: trackLayerHeight)
        
        
        switch type {
        case .play:
            let playerThumbCenter = CGFloat(positionForValue(value: currentValue, type: .play))
            
            playerThumbLayer.frame = CGRect(x: playerThumbCenter - thumbWidth / 2.0, y: bounds.height / 2 - thumbWidth / 2,
            width: thumbWidth, height: thumbWidth)
            
            break
        case .range:
            
            let lowerThumbCenter = CGFloat(positionForValue(value: lowerValue, type: .range))
            
            lowerThumbLayer.frame = CGRect(x: lowerThumbCenter - thumbWidth / 2.0, y: bounds.height / 2 - thumbWidth / 2,
                                           width: thumbWidth, height: thumbWidth)
            
            let upperThumbCenter = CGFloat(positionForValue(value: upperValue, type: . range))
            upperThumbLayer.frame = CGRect(x: upperThumbCenter - thumbWidth / 2.0, y: bounds.height / 2 - thumbWidth / 2,
                                           width: thumbWidth, height: thumbWidth)

            break
        case .small:
            trackLayer.frame = CGRect(x: smallWithStartPoint(), y: bounds.height / 2 - trackLayerHeight / 2, width: smallTrackWidth, height: trackLayerHeight)
            break
        }

        trackLayer.setNeedsDisplay()
    }
    
    func positionForValue(value: Double, type: SliderType) -> Double {
        switch type {
            
        case .play, .range:
            return Double(bounds.width) * (value - minimumValue) /
            (maximumValue - minimumValue) //+ Double(thumbWidth / 2.0)
        case .small:
            return Double(smallTrackWidth) * (value - minimumValue) /
            (maximumValue - minimumValue) //+ Double(thumbWidth / 2.0)
        }
    }
    
    func smallWithStartPoint() -> CGFloat{
        let currentOrientation = DeviceOrientationHelper.shared.currentOrientation
        
        let deviceCenter = UIApplication.shared.keyWindowInConnectedScenes?.frame ?? CGRect.zero
        
        let container = superview?.frame ?? CGRect.zero
        
        let currentX = container.origin.x + self.frame.origin.x
        let currentY = container.origin.y + self.frame.origin.x
                
        let mid = (currentOrientation.isPortrait ? deviceCenter.width / 2 - currentX : deviceCenter.height / 2 - currentY)
        
        return mid - (smallTrackWidth / 2)
    }
    
    override var frame: CGRect {
        didSet {
            animateLayer()
        }
    }
    
    override func beginTracking(_ touch: UITouch, with event: UIEvent?) -> Bool {
        if type == .small{
            delegate?.rangeSliderTouchInSmall(self)
            return false
        }
        
        previousLocation = touch.location(in: self)
        
        // Hit test the thumb layers
        if type == .range{
            if lowerThumbLayer.frame.insetBy(dx: -20, dy: -20).contains(previousLocation) {
                lowerThumbLayer.highlighted = true
            } else if upperThumbLayer.frame.insetBy(dx: -20, dy: -20).contains(previousLocation) {
                upperThumbLayer.highlighted = true
            }
        }else if type == .play{
            if playerThumbLayer.frame.insetBy(dx: -20, dy: -20).contains(previousLocation) {
                playerThumbLayer.highlighted = true
            }
        }
        
        return ((lowerThumbLayer.highlighted || upperThumbLayer.highlighted) && type == .range) || (playerThumbLayer.highlighted && type == .play)
    }
    
    func boundValue(value: Double, toLowerValue lowerValue: Double, upperValue: Double) -> Double {
        return min(max(value, lowerValue), upperValue)
    }
    
    override func continueTracking(_ touch: UITouch, with event: UIEvent?) -> Bool {
        let location = touch.location(in: self)
        
        // 1. Determine by how much the user has dragged
        let deltaLocation = Double(location.x - previousLocation.x)
        let deltaValue = (maximumValue - minimumValue) * deltaLocation / Double(bounds.width - thumbWidth)
        
        previousLocation = location
        
        // 2. Update the values
        
        if type == .range{
            if lowerThumbLayer.highlighted {
                lowerValue += deltaValue
                lowerValue = boundValue(value: lowerValue, toLowerValue: minimumValue, upperValue: upperValue)
            } else if upperThumbLayer.highlighted {
                upperValue += deltaValue
                upperValue = boundValue(value: upperValue, toLowerValue: lowerValue, upperValue: maximumValue)
            }
        }else if type == .play{
            if playerThumbLayer.highlighted {
                currentValue += deltaValue
                currentValue = boundValue(value: currentValue, toLowerValue: minimumValue, upperValue: maximumValue)
            }
        }
        animateLayer()
        return true
    }
    
    func animateLayer(){
        
        // 3. Update the UI
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        
        updateLayerFrames()
        
        CATransaction.commit()
        
    }
    
    override func endTracking(_ touch: UITouch?, with event: UIEvent?) {
        lowerThumbLayer.highlighted = false
        upperThumbLayer.highlighted = false
        playerThumbLayer.highlighted = false
        
        if type == .play {
            delegate?.rangeSliderSeek(self, seekValue: currentValue)
        }else if type == .range{
            delegate?.rangeSliderChangeRange(self, start: lowerValue, end: upperValue)
        }
    }
}

class RangeSliderThumbLayer: CALayer {
    var highlighted = false
    weak var rangeSlider: RangeSlider?
}

class RangeSliderTrackLayer: CALayer {
    weak var rangeSlider: RangeSlider?
        
    override func draw(in ctx: CGContext) {
        
        if let slider = rangeSlider {
            switch slider.type{
            case .range:
                // Clip
                let cornerRadius = bounds.height * slider.curvaceousness / 2.0
                let path = UIBezierPath(roundedRect: bounds, cornerRadius: cornerRadius)
                ctx.addPath(path.cgPath)
                
                // Fill the track
                ctx.setFillColor(slider.trackTintColor.cgColor)
                ctx.addPath(path.cgPath)
                ctx.fillPath()
                
                // Fill the lower track
                ctx.setFillColor(slider.trackLowerColor.cgColor)
                let lowerValuePosition =  CGFloat(slider.positionForValue(value: slider.lowerValue, type: .range))
                let rect = CGRect(x: 0.0, y: 0.0, width: lowerValuePosition, height: bounds.height)
                ctx.fill(rect)
                
                // Fill the highlighted range
                
                ctx.setFillColor(slider.trackHighlightTintColor.cgColor)
                let upperValuePosition = CGFloat(slider.positionForValue(value: slider.currentValue, type: .range))
                let upperRect = CGRect(x: lowerValuePosition, y: 0.0, width: upperValuePosition - lowerValuePosition, height: bounds.height)
                if upperValuePosition - lowerValuePosition > 0 {
                    ctx.fill(upperRect)
                }
            case .play:
                // Clip
                let path = UIBezierPath(roundedRect: bounds, cornerRadius: 2)
                ctx.addPath(path.cgPath)
                
                // Fill the track
                ctx.setFillColor(slider.trackTintColor.cgColor)
                ctx.fillPath()
                
                // Fill the lower track
                ctx.setFillColor(slider.trackLowerColor.cgColor)
                let lowerValuePosition =  CGFloat(slider.positionForValue(value: slider.currentValue, type: .play))
                let rect = CGRect(x: 0.0, y: 0.0, width: lowerValuePosition, height: bounds.height)
                let lowerPath = UIBezierPath(roundedRect: rect, cornerRadius: 2)
                ctx.addPath(lowerPath.cgPath)
                ctx.fillPath()
            case .small:
                let cornerRadius = bounds.height * slider.curvaceousness / 2.0
                
                let path = UIBezierPath(roundedRect: bounds, cornerRadius: cornerRadius)
                ctx.addPath(path.cgPath)
                
                // Fill the track
                ctx.setFillColor(slider.trackTintColor.cgColor)
                ctx.addPath(path.cgPath)
                ctx.fillPath()
                
                // Fill the lower track
                ctx.setFillColor(slider.trackLowerColor.cgColor)
                let lowerValuePosition =  CGFloat(slider.positionForValue(value: slider.currentValue, type: .small))
                let rect = CGRect(x: 0.0, y: 0.0, width: lowerValuePosition, height: bounds.height)
                ctx.fill(rect)
            }
            
        }
    }
}
