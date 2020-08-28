//
//  FollowButton.swift
//  FollowButton
//
//  Created by Louis Tur on 5/28/16.
//  Copyright © 2016 cat.thoughts. All rights reserved.
//

import UIKit
import SnapKit

/**
 - parameter currentState: The button's current state when pressed. Classes that conform to this protocal
 can check for `.Following` and `.NotFollowing`
 */
public protocol FollowButtonDelegate: class {
    func didPressFollowButton(currentState: FollowButtonState)
}

/**
 - note: `.Loading` state isn't used outside of this class. It is not meant to be checked.
 */
public enum FollowButtonState {
    case NotFollowing
    case Following
    case Loading
}

public struct FollowButtonColors {
    static let LightBlue: UIColor = #colorLiteral(red: 0.5215686275, green: 0.8705882353, blue: 1, alpha: 1)
    static let MediumBlue: UIColor = #colorLiteral(red: 0.4431372549, green: 0.6117647059, blue: 1, alpha: 1)
    static let OffWhite: UIColor = #colorLiteral(red: 0.9607843137, green: 0.9607843137, blue: 0.9607843137, alpha: 1)
    static let DarkText: UIColor = #colorLiteral(red: 0.3921568627, green: 0.3921568627, blue: 0.5882352941, alpha: 1)
}

/**
 - todo: 
 - Allow for custom FollowButtonOptions to be set
 */
public class FollowButton: UIView {
    
    // Parameter Struct
    private struct FollowButtonOptions {
        let labelText: String
        let labelTextColor: UIColor
        let labelBackgroundColor: UIColor
        let showSpinner: Bool
        let showLabel: Bool
    }
    
    private enum FollowButtonTransition {
        case FollowingToNotFollowing
        case NotFollowingToFollowing
    }
    
    // MARK: - Variables
    // ------------------------------------------------------------
    public var delegate: FollowButtonDelegate?
    
    private var minButtonWidth: CGFloat?
    private var minButtonHeight: CGFloat?
    private var checkHeightOnce = DispatchQueue.main
    private var adjustedWidthConstraints: (left: Constraint?, right: Constraint?)
    
    private var transitionalState: FollowButtonTransition = .NotFollowingToFollowing
    private var currentButtonState: FollowButtonState = .NotFollowing {
        willSet {
            switch newValue {
            case .NotFollowing: self.updateButtonOptions(options: self.notFollowingOptions)
            case .Following: self.updateButtonOptions(options: self.followingOptions)
            case .Loading: self.updateButtonOptions(options: self.loadingOptions)
            }
        }
    }
    
    // MARK: - Initialization
    // ------------------------------------------------------------
    /**
     Instantiate with a specified `FollowButtonState`
     - parameter state: The state to initialize the button in.
     - note: Do not initialize in the `.Loading` state. If `.Loading` is passed as the paramter, an instance
     of `FollowButton` will be returned in the `.NotFollowing` state
     */
    public convenience init(withState state: FollowButtonState) {
        self.init(frame: .zero)
        
        guard state != .Loading else { return }
        self.updateButtonToState(state: state)
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.setupViewHierarchy()
        self.configureConstraints()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    /**
     Use this function to finish the button's loading state in either a success state, or failure state.
     - parameter success:
     - `true` If the button should finish its transition to a new state
     - `false` If the button should return to it's original state
     - note: In a scenario where the button is pressed and going from a `.NotFollowing` -> `.Following`, a value of `true`
     will finish the loading animation and finish the transition to `.Following`. A value of `false` will finish the
     loading animation and animate back to it's original state, in this case `.NotFollowing`
     */
    internal func finishAnimating(success: Bool) {
        self.finishTransition(success: success)
    }
    
    /// - returns: The button's current `FollowButtonState`
    internal func currentState() -> FollowButtonState {
        return self.currentButtonState
    }
    
    
    // MARK: - Layout Setup
    // ------------------------------------------------------------
    private func configureConstraints() {
        
        self.buttonView.snp.makeConstraints { (make) -> Void in
            make.top.bottom.centerX.equalTo(self)
            make.left.greaterThanOrEqualTo(self)
            make.right.lessThanOrEqualTo(self)
            make.width.greaterThanOrEqualTo(50)
            make.height.greaterThanOrEqualTo(30)
        }
        
        self.buttonLabel.snp.makeConstraints { (make) -> Void in
            // pads the top and bottom of the label by expanding the superview
            make.top.equalTo(buttonView).offset(14.0)
            make.bottom.equalTo(buttonView).inset(14.0)
            make.center.equalTo(buttonView).priority(.required)
            
            // I'll need to save these constraints
            self.adjustedWidthConstraints.left = make.left.equalTo(buttonView).offset(48.0).constraint
            self.adjustedWidthConstraints.right = make.right.equalTo(buttonView).inset(48.0).constraint
        }
        
        self.spinnerImageView.snp.makeConstraints { (make) -> Void in
            make.center.equalTo(self.buttonView)
            make.height.width.equalTo(36.0)
        }
    }
    
    private func setupViewHierarchy() {
        self.addSubview(buttonView)
        self.buttonView.addSubview(buttonLabel)
        self.buttonView.addSubview(spinnerImageView)
    }
    
    public override func layoutSubviews() {
        self.updateCornerRadius()
        
        // Get the button's height once, once we can get it's size from it's constraints
        checkHeightOnce.async { () -> Void in
            self.minButtonWidth = self.frame.size.height
            self.minButtonHeight = self.minButtonWidth
        }
    }
    
    
    // MARK: - Helpers -
    // ------------------------------------------------------------
    
    // MARK: UI Helpers
    /// Used to update the UI state of the button and label.
    private func updateButtonToState(state: FollowButtonState) {
        switch state {
        case .NotFollowing:
            self.currentButtonState = .NotFollowing
            self.expandButton { complete -> Void in
                self.stopAnimatingSpinner()
            }
            
        case .Following:
            self.currentButtonState = .Following
            self.expandButton { complete -> Void in
                self.stopAnimatingSpinner()
            }
            
        case .Loading:
            self.currentButtonState = .Loading
            self.shrinkButton { complete -> Void in
                self.animateSpinner()
            }
        }
    }
    
    /**
     Starts the button animation and tracks the transition states.
     - parameters:
     - fromState: Button's original state before being pressed
     - toState: Button's final state after being pressed
     */
    private func transition(fromState: FollowButtonState, toState: FollowButtonState) {
        self.updateButtonToState(state: .Loading)
        
        if fromState == .NotFollowing {
            self.transitionalState = .NotFollowingToFollowing
        }
        else if fromState == .Following {
            self.transitionalState = .FollowingToNotFollowing
        }
    }
    
    /**
     Finishes the current animations and updates the button to a new state
     - parameter success: On `true`, the button moves from it's original `fromState` to its new `toState`. On 'false'
     the button returns to it's original `fromState`
     - seealso: `transition(fromState:toState:)`
     */
    private func finishTransition(success: Bool) {
        let (successState, transitionState): (Bool, FollowButtonTransition) = (success, self.transitionalState)
        
        switch (successState, transitionState) {
        case (true, .NotFollowingToFollowing),
             (false, .FollowingToNotFollowing):
            self.updateButtonToState(state: .Following)
            
        case (true, .FollowingToNotFollowing),
             (false, .NotFollowingToFollowing):
            self.updateButtonToState(state: .NotFollowing)
        }
        
    }
    
    private func updateButtonOptions(options: FollowButtonOptions) {
        self.buttonLabel.text = options.labelText
        self.buttonLabel.textColor = options.labelTextColor
        self.buttonView.backgroundColor = options.labelBackgroundColor
        self.buttonLabel.alpha = options.showLabel ? 1.0 : 0.0
        self.spinnerImageView.alpha = options.showSpinner ? 1.0 : 0.0
    }
    
    private func updateCornerRadius() {
        let currentHeight: CGFloat = self.frame.size.height
        self.buttonView.layer.cornerRadius = currentHeight/2.0
    }
    
    private func rotationTransform(degrees: CGFloat) -> CATransform3D {
        let radians: CGFloat = degrees * (CGFloat(M_PI) / 180.0)
        return CATransform3DMakeRotation(radians, 0.0, 0.0, -1.0)
    }
    
    
    // MARK: - Animations
    // ------------------------------------------------------------
    
    // MARK: Button Shrink/Expand
    private func shrinkButton(completetion: ((_ complete: Bool)->Void)? = nil) {
        
        guard let minButtonWidth = self.minButtonWidth, minButtonWidth > 0.0 else { return }
        
        self.adjustedWidthConstraints.left?.deactivate()
        self.adjustedWidthConstraints.right?.deactivate()
        self.buttonView.snp.updateConstraints { (make) -> Void in
            make.width.height.greaterThanOrEqualTo(self.minButtonWidth!)
        }
//        self.setNeedsUpdateDeviceOrientationHelperonstraints()
        
        UIView.animate(withDuration: 0.35, animations: { () -> Void in
            self.layoutIfNeeded()
        }, completion: completetion)
    }
    
    private func expandButton(completetion: ((_ complete: Bool)->Void)? = nil) {
        
        guard let minButtonWidth = self.minButtonWidth, minButtonWidth > 0.0 else { return }
                
        self.adjustedWidthConstraints.left?.activate()
        self.adjustedWidthConstraints.right?.activate()
        self.setNeedsUpdateConstraints()
        
        UIView.animate(withDuration: 0.25, animations: { () -> Void in
            self.layoutIfNeeded()
        }, completion: completetion)
    }
    
    // MARK: Spinner
    private func animateSpinner() {
        self.isUserInteractionEnabled = false
        
        UIView.animateKeyframes(withDuration: 1.25, delay: 0.0, options: [.repeat, .beginFromCurrentState, .calculationModePaced], animations: { () -> Void in
            
            UIView.addKeyframe(withRelativeStartTime: 0.0,
                                                    relativeDuration: 0.25,
                                                    animations: { () -> Void in
                                                        self.spinnerImageView.layer.transform = self.rotationTransform(degrees: 90.0)
            })
            
            UIView.addKeyframe(withRelativeStartTime: 0.25,
                                                    relativeDuration: 0.25,
                                                    animations: { () -> Void in
                                                        self.spinnerImageView.layer.transform = self.rotationTransform(degrees: 180.0)
            })
            
            UIView.addKeyframe(withRelativeStartTime: 0.50,
                                                    relativeDuration: 0.25,
                                                    animations: { () -> Void in
                                                        self.spinnerImageView.layer.transform = self.rotationTransform(degrees: 270.0)
            })
            
            UIView.addKeyframe(withRelativeStartTime: 0.75,
                                                    relativeDuration: 0.25,
                                                    animations: { () -> Void in
                                                        self.spinnerImageView.layer.transform = self.rotationTransform(degrees: 360.0)
            })
            
        }) { (complete: Bool) -> Void in
            if complete {
                
            }
        }
        
    }
    
    private func stopAnimatingSpinner() {
        self.isUserInteractionEnabled = true
        self.spinnerImageView.layer.removeAllAnimations()
    }
    
    
    // MARK: - Button Control Actions
    // ------------------------------------------------------------
    @objc internal func followButtonTapped(sender: AnyObject?) {
        switch currentButtonState {
        case .NotFollowing:
            self.transition(fromState: .NotFollowing, toState: .Following)
            self.delegate?.didPressFollowButton(currentState: .NotFollowing)
            
        case .Following:
            self.transition(fromState: .Following, toState: .NotFollowing)
            self.delegate?.didPressFollowButton(currentState: .Following)
            
        case .Loading:
            return
        }
    }
    
    @objc internal func followButtonHighlighted(sender: AnyObject?) {
        if currentButtonState == .NotFollowing {
            self.buttonLabel.textColor = FollowButtonColors.MediumBlue
        } else {
            self.buttonLabel.textColor = FollowButtonColors.DarkText
        }
    }
    
    @objc internal func followButtonReleased(sender: AnyObject?) {
        if currentButtonState == .Following {
            self.buttonLabel.textColor = FollowButtonColors.DarkText
        } else {
            self.buttonLabel.textColor = FollowButtonColors.MediumBlue
        }
    }
    
    
    // MARK: - Lazy Instances
    // ------------------------------------------------------------
    private lazy var buttonView: UIControl = {
        let control: UIControl = UIControl()
        control.backgroundColor = UIColor.white
        control.layer.cornerRadius = 15.0
        control.clipsToBounds = true
        
        control.addTarget(self, action: #selector(self.followButtonTapped(sender:)), for: [.touchUpInside])
//
//        control.addTarget(self, action: "followButtonTapped:", forControlEvents: [.TouchUpInside, .TouchUpOutside])
        control.addTarget(self, action: #selector(self.followButtonHighlighted(sender:)), for: [.touchDown, .touchDragEnter, .touchDragInside])
        control.addTarget(self, action: #selector(self.followButtonReleased(sender:)), for: [.touchCancel, .touchDragExit, .touchDragOutside])
        
        return control
    }()
    
    private lazy var buttonLabel: UILabel = {
        var label: UILabel = UILabel()
        label.textColor = FollowButtonColors.DarkText
        label.font = UIFont.systemFont(ofSize: 16.0, weight: UIFont.Weight.medium)
        label.text = "F O L L O W"
        return label
    }()
    
    private lazy var spinnerImageView: UIImageView = {
        let imageView: UIImageView = UIImageView(image: UIImage(named: "squareSpinner"))
        imageView.contentMode = .scaleAspectFit
        imageView.alpha = 0.0
        return imageView
    }()
    
    private lazy var notFollowingOptions: FollowButtonOptions = {
        let options = FollowButtonOptions(labelText: "F O L L O W",
                                          labelTextColor: FollowButtonColors.DarkText,
                                          labelBackgroundColor: FollowButtonColors.OffWhite,
                                          showSpinner: false, showLabel: true)
        return options
    }()
    
    private lazy var followingOptions: FollowButtonOptions = {
        let options = FollowButtonOptions(labelText: "F O L L O W I N G",
                                          labelTextColor: FollowButtonColors.OffWhite,
                                          labelBackgroundColor: FollowButtonColors.MediumBlue,
                                          showSpinner: false, showLabel: true)
        return options
    }()
    
    private lazy var loadingOptions: FollowButtonOptions = {
        let options = FollowButtonOptions(labelText: "",
                                          labelTextColor: FollowButtonColors.DarkText,
                                          labelBackgroundColor: UIColor.white,
                                          showSpinner: true, showLabel: false)
        return options
    }()
}
