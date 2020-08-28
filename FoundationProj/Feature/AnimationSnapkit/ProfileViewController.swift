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
 >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
 
 Thanks for looking! Check me out on Twitter and >catthoughts
 - author: Louis Tur [@louistur](https://twitter.com/louistur) / [catthoughts](http://catthoughts.ghost.io/)
 
 Design found @[Uplabs](http://www.ios.uplabs.com/posts/profile-page-interaction-and-animation)
 Designer: Malik, [@iOfficialBlack](https://twitter.com/iOfficialBlack) / [@Uplabs](http://www.ios.uplabs.com/iOfficialBlack)
 
 >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
 */
class ProfileViewController: UIViewController, FollowButtonDelegate {
    
    
    // MARK: - Lifecycle -
    // ------------------------------------------------------------
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setupViewHierarchy()
        self.configureConstraints()
        
        self.drawGradientIn(view: self.profileTopSectionView)
        
    }
    
    
    // MARK: - Layout -
    // ------------------------------------------------------------
    internal func configureConstraints() {
        
        self.profileBackgroundView.snp.makeConstraints { (make) -> Void in
            make.edges.equalTo(self.view).inset(UIEdgeInsets(top: 60.0, left: 22.0, bottom: 60.0, right: 22.0))
        }
        
        self.profileTopSectionView.snp.makeConstraints { (make) -> Void in
            make.top.left.right.equalTo(self.profileBackgroundView)
            make.bottom.equalTo(self.profileBottomSectionView.snp.top)
        }
        
        self.profileBottomSectionView.snp.makeConstraints { (make) -> Void in
            make.left.right.bottom.equalTo(self.profileBackgroundView)
            make.top.equalTo(self.profileBackgroundView.snp.centerY).multipliedBy(1.30)
        }
        
        self.followButton.snp.makeConstraints { (make) -> Void in
            make.centerY.equalTo(self.profileBottomSectionView.snp.top)
            make.centerX.equalTo(self.profileBottomSectionView)
            make.height.width.greaterThanOrEqualTo(0.0).priority(990.0)
        }
        
    }
    
    internal func setupViewHierarchy() {
        self.view.backgroundColor = UIColor.gray
        self.followButton.delegate = self
        
        self.view.addSubview(profileBackgroundView)
        self.profileBackgroundView.addSubview(self.profileTopSectionView)
        self.profileBackgroundView.addSubview(self.profileBottomSectionView)
        self.profileBackgroundView.addSubview(self.followButton)
    }
    
    
    // MARK: - FollowButtonDelegate
    func didPressFollowButton(currentState: FollowButtonState) {
        
        if currentState == .Following || currentState == .NotFollowing {
            let threeSecondsFromNow: NSDate = NSDate(timeInterval: 3.0, since: NSDate() as Date)
            let fakeNetworkRequestTimer: Timer = Timer(fireAt: threeSecondsFromNow as Date, interval: 0.0, target: self, selector: #selector(finishFakeNetworkRequest), userInfo: nil, repeats: false)
            
            RunLoop.current.add(fakeNetworkRequestTimer, forMode: RunLoop.Mode.default)
        }
        
    }
    
    @objc func finishFakeNetworkRequest() {
        self.followButton.finishAnimating(success: true)
    }
    
    
    // MARK: - Helpers -
    // MARK: UI Updates
    // ------------------------------------------------------------
    internal func drawGradientIn(view: UIView) {
        self.view.layoutIfNeeded()
        
        let gradientLayer: CAGradientLayer = CAGradientLayer()
        gradientLayer.frame = view.bounds
        gradientLayer.colors = [FollowButtonColors.LightBlue.cgColor, FollowButtonColors.MediumBlue.cgColor]
        gradientLayer.locations = [0.0, 1.0] // even transition from light blue to medium blue
        
        gradientLayer.startPoint = CGPoint(x: 0, y: 0) // top-left corner
        gradientLayer.endPoint = CGPoint(x: 1, y: 1) // bottom-right corner
        
        view.layer.addSublayer(gradientLayer)
    }
    
    
    // MARK: - Lazy Instances -
    // ------------------------------------------------------------
    lazy var profileBackgroundView: UIView = {
        let view: UIView = UIView()
        view.layer.cornerRadius = 12.0
        view.clipsToBounds = true
        return view
    }()
    
    lazy var profileTopSectionView: UIView = {
        let view: UIView = UIView()
        view.backgroundColor = FollowButtonColors.LightBlue
        return view
    }()
    
    lazy var profileBottomSectionView: UIView = {
        let view: UIView = UIView()
        view.backgroundColor = FollowButtonColors.OffWhite
        return view
    }()
    
    lazy var followButton: FollowButton = FollowButton(withState: .NotFollowing)
    
    let borderButtonTitle = ["비디오", "움짤", "사진"]
}
