//
//  CustomRefreshControl.swift
//  FoundationProj
//
//  Created by baedy on 2020/06/10.
//  Copyright © 2020 baedy. All rights reserved.
//

import RxCocoa
import RxSwift
import SnapKit
import UIKit
import Lottie

class CustomRefreshControl: UIRefreshControl {
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    init(lottie: String? = nil){
        super.init()
        self.animationView = AnimationView(name: lottie ?? "Full to refresh_Magic hat")
        animationView.loopMode = .loop
        setupView()
    }

    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        self.snp.makeConstraints{
            $0.centerY.equalTo(superview!.snp.top).offset(-20)
            $0.centerX.equalToSuperview()
        }
        
        self.addSubview(animationView)
         animationView.snp.makeConstraints{ make in
             make.width.equalTo(50)
             make.height.equalTo(50)
             make.centerX.equalToSuperview()
             let offset = 50 / CGFloat(2.0)
             make.centerY.equalToSuperview().offset(offset)
         }
    }
    
    var animationView: AnimationView!
    
    fileprivate let refreshTrigger = PublishSubject<Void>()
    fileprivate let animating = BehaviorRelay<Bool>(value: false)
    
    fileprivate var isAnimating = false
    fileprivate let maxPullDistance: CGFloat = 250
    
    fileprivate func updateProgress(with offsetY: CGFloat) {
        guard !animating.value else { return }
        let progress = min(abs(offsetY / maxPullDistance), 1)
        animationView.currentProgress = progress
    }
    
    func endRefresh() {
        self.endRefreshing()
        animationView.stop()
//        isAnimating = false
        animating.accept(false)
     }
    
    func setupView() {
        // hide default indicator view
        tintColor = .clear
        animationView.loopMode = .loop
        addSubview(animationView)

        addTarget(self, action: #selector(beginRefreshing), for: .valueChanged)
        animationView.translatesAutoresizingMaskIntoConstraints = false
    }
    
    @objc func trigger(){
        self.refreshTrigger.onNext(())
    }
}

extension CustomRefreshControl: UITableViewDelegate, UIScrollViewDelegate{

    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if self.isRefreshing {
            if !animating.value {
                // 정보 조회
//                isAnimating = true
                animating.accept(true)
                animationView.currentProgress = 0
                animationView.play()
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 2, execute: {
                    self.trigger()
                })
            }
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView){
        updateProgress(with: scrollView.contentOffset.y)
    }
    
}

extension Reactive where Base: CustomRefreshControl{
    var isAnimate: Observable<Bool>{
        base.animating.asObservable()
    }
    
    var refreshTrigger: PublishSubject<Void>{
        base.refreshTrigger
    }
}
