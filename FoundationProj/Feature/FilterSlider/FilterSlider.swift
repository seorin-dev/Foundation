//
//  FilterSlider.swift
//  FoundationProj
//
//  Created by baedy on 2020/08/19.
//  Copyright © 2020 baedy. All rights reserved.
//

import UIKit
import Then
import SnapKit


protocol FilterSliderDelegate: class {
    func filterSliderSeek(_ slider: FilterSlider, seekValue: Int)
}

class FilterSlider: UIControl {
    
    weak var delegate: FilterSliderDelegate?
    
    // MARK: - init
    override init(frame: CGRect) {
        super.init(frame: frame)
        trackLayer.filterSlider = self
        layer.addSublayer(trackLayer)
        
        defaultThumbLayer.filterSlider = self
        layer.addSublayer(defaultThumbLayer)
        
        playerThumbLayer.filterSlider = self
        layer.addSublayer(playerThumbLayer)
        
        self.addSubview(currentValueLabel)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    var minimumValue = 0
    var maximumValue = 100
    
    var previousLocation = CGPoint()
    /// ThumbValue
    var currentValue = 0 {
        didSet{
            self.currentValueLabel.text = "\(self.currentValue)"
            self.animateLayer()
        }
    }
    var defaultValue = 50 {
        didSet{
            self.currentValue = defaultValue
        }
    }
    
    var trackLayerHeight: CGFloat = 3
    
    var thumbWidth: CGFloat {
        return 30.0
    }
    
    var defaultWidth: CGFloat {
        return 9.0
    }
    
    var trackTintColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1) ~ 80%
    var trackLowerColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
    
    var currentValueLabel = UILabel().then{
        $0.layer.shadowOffset = CGSize(width: 0, height: 1)
        $0.layer.shadowColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
        $0.layer.shadowOpacity = 0.3
        $0.layer.shadowRadius = 2
        $0.textColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        $0.textAlignment = .center
        $0.font = UIFont.boldSystemFont(ofSize: 15)
    }
    
    lazy var trackLayer = FilterSliderTrackLayer().then{
        $0.cornerRadius = 2
        $0.shadowColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1).cgColor
        $0.shadowOpacity = 0.2
        $0.shadowRadius = 5
        $0.borderColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 0.3).cgColor
        $0.borderWidth = 1.0
    }
    
    lazy var defaultThumbLayer = FilterSliderThumbLayer().then{
        $0.backgroundColor = #colorLiteral(red: 0.9529411765, green: 0.9529411765, blue: 0.9529411765, alpha: 1).cgColor
        $0.shadowColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1).cgColor
        $0.shadowRadius = 5
        $0.shadowOpacity = 0.2
        $0.contentsGravity = .resizeAspectFill
        $0.isGeometryFlipped = true
        $0.cornerRadius = defaultWidth / 2
    }
    
    let playerThumbLayer = FilterSliderThumbLayer().then{
        $0.contents = #imageLiteral(resourceName: "btnFilterHandlerCamera").cgImage
        $0.contentsGravity = .resizeAspectFill
        $0.isGeometryFlipped = true
    }
    
    func positionForValue(value: Double) -> Double {
        return Double(bounds.width) * (value - Double(minimumValue)) / Double(maximumValue - minimumValue)
    }
    
    func boundValue(value: Int, toLowerValue lowerValue: Int, upperValue: Int) -> Int {
        return min(max(value, lowerValue), upperValue)
    }
    
    override var frame: CGRect {
        /// 해당 뷰의 기본 사이즈 - (n, 52)
        didSet {
            animateLayer()
        }
    }
        
    override func layoutSublayers(of layer: CALayer) {
        super.layoutSublayers(of: layer)
        updateLayerFrames()
    }
    
    func updateLayerFrames() {
        
        trackLayer.frame = CGRect(x: 0,
                                  y: bounds.height - thumbWidth / 2 - trackLayerHeight / 2,
                                  width: bounds.width,
                                  height: trackLayerHeight)
        
        let playerThumbCenter = CGFloat(positionForValue(value: Double(currentValue)))
        
        playerThumbLayer.frame = CGRect(x: playerThumbCenter - thumbWidth / 2.0,
                                        y: bounds.height - thumbWidth,
                                        width: thumbWidth,
                                        height: thumbWidth)
        
        currentValueLabel.frame = CGRect(x: playerThumbCenter - thumbWidth / 2.0,
                                         y: 0,
                                         width: thumbWidth,
                                         height: 22.0)
        
        let defaultThumblocate = CGFloat(positionForValue(value: Double(defaultValue)))
        
        defaultThumbLayer.frame = CGRect(x: defaultThumblocate - defaultWidth / 2.0,
                                         y: bounds.height - thumbWidth / 2 - defaultWidth / 2,
                                         width: defaultWidth,
                                         height: defaultWidth)

        trackLayer.setNeedsDisplay()
    }
    
    override func beginTracking(_ touch: UITouch, with event: UIEvent?) -> Bool {
        previousLocation = touch.location(in: self)
        
        // Hit test the thumb layers
        if playerThumbLayer.frame.insetBy(dx: -20, dy: -20).contains(previousLocation) {
            playerThumbLayer.highlighted = true
        }
        
        return playerThumbLayer.highlighted
    }
    
    override func continueTracking(_ touch: UITouch, with event: UIEvent?) -> Bool {
        let location = touch.location(in: self)
        
        // 1. Determine by how much the user has dragged
        let deltaLocation = Double(location.x - previousLocation.x)
        let deltaValue = Double(maximumValue - minimumValue) * deltaLocation / Double(bounds.width - thumbWidth)
        
        // 2. Update the values
        if playerThumbLayer.highlighted {
            currentValue += Int(round(deltaValue))
            currentValue = boundValue(value: currentValue, toLowerValue: minimumValue, upperValue: maximumValue)
            
        }
        
        if !previousLocation.offsetCompare(with: location, tolerance: 4) {
            Log.d("previous : \(previousLocation), current : \(location)")
            delegate?.filterSliderSeek(self, seekValue: currentValue)
        }
        
        previousLocation = location
        
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
        playerThumbLayer.highlighted = false
        
        delegate?.filterSliderSeek(self, seekValue: currentValue)
     
    }
}

class FilterSliderThumbLayer: CALayer {
    var highlighted = false
    weak var filterSlider: FilterSlider?
}

class FilterSliderTrackLayer: CALayer {
    weak var filterSlider: FilterSlider?
        
    override func draw(in ctx: CGContext) {
        
        if let slider = filterSlider {
            // Clip
            let path = UIBezierPath(roundedRect: bounds, cornerRadius: 2)
            ctx.addPath(path.cgPath)
            
            // Fill the track
            ctx.setFillColor(slider.trackTintColor.cgColor)
            ctx.fillPath()
            
            // Fill the lower track
            ctx.setFillColor(slider.trackLowerColor.cgColor)
            let lowerValuePosition = CGFloat(slider.positionForValue(value: Double(slider.currentValue)))
            let rect = CGRect(x: 0.0, y: 0.0, width: lowerValuePosition, height: bounds.height)
            let lowerPath = UIBezierPath(roundedRect: rect, cornerRadius: 2)
            ctx.addPath(lowerPath.cgPath)
            ctx.fillPath()
            
        }
    }
}


extension CGPoint {
    func offsetCompare(with point: CGPoint, tolerance : CGFloat) -> Bool{
        (abs(self.x - point.x) < tolerance) && (abs(self.y - point.y) < tolerance)
    }
}
