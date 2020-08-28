//
//  ZoomingViewController.swift
//  FoundationProj
//
//  Created by baedy on 2020/05/12.
//  Copyright (c) 2020 baedy. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import Reusable
import SnapKit
import Photos
import Then

class ZoomingViewController<T>: UIBaseViewController, ViewModelProtocol, UIGestureRecognizerDelegate {
    typealias ViewModel = ZoomingViewModel
    typealias Trigger = ZoomingViewModel<T>.ActionTrigger
    
    // MARK: - ViewModelProtocol
    var viewModel: ViewModel<T>!
    
    // MARK: - Properties
    let currentIndex = BehaviorRelay<Int>(value: 0)
    let actionTrigger = PublishRelay<Trigger>()
    
    var transitionController = ZoomTransitionController()
    var panGestureRecognizer: UIPanGestureRecognizer!
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
    }
    
    override func viewDidDisappear(_ animated: Bool) {
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
        
        transitionSetup()
        setupLayout()
        bindingViewModel()
        
        NotificationCenter.default.addObserver(forName: Notification.Name("VideoURLLoaded"), object: nil, queue: .main, using: self.videoLoaded(_:))
    }
    
    @objc func videoLoaded(_ noti: Notification){
        for cell in self.subView.imageSlider.collectionView.visibleCells{
            guard let cell = cell as? ZoomImageCell<PHAsset> else {
                continue
            }
            
            let asset = noti.userInfo?["asset"] as? PHAsset
            if cell.videoAsset == asset{
                ARVideoPlayerController.sharedVideoPlayer.pausePlayerVideosForPaging(collectionView: self.subView.imageSlider.collectionView)
            }
        }
    }
    
    deinit {
        ARVideoPlayerController.sharedVideoPlayer.pausePlayerVideosForPaging(collectionView: self.subView.imageSlider.collectionView)
        self.navigationController?.delegate = nil
        Log.d("ZoomingViewController deinit")
    }
    
    // MARK: - Binding
    func bindingViewModel() {
        let res = viewModel.transform(req: ViewModel.Input(actionTrigger: actionTrigger.asObservable(), transIndex: currentIndex.asObservable(), cancel: self.subView.imageSlider.collectionView.rx.cancelPrefetchingForItems.asObservable()))
                
        self.subView.imageSlider.scrollToPage(index: res.initalIndex)
        
        currentIndex.subscribe(onNext: {
            self.transitionController.animator.currentIndex = $0
        }).disposed(by: rx.disposeBag)
        
        currentIndex.accept(res.initalIndex)
        
        _ = subView.setupDI(generic: actionTrigger)
        .setupDI(generic: res.inputSequence.asObservable())
        .setupDI(generic: currentIndex)
    }
    
    // MARK: - View
    let subView = ZoomingView<T>()
    
    func setupLayout() {
        self.view.addSubview(subView)
        subView.snp.makeConstraints {
            $0.top.leading.trailing.bottom.equalToSuperview()
        }
        
        subView.imageSlider.delegate = self
    }
    
    // MARK: - Methods
    
    // MARK: - gesture method

    func transitionSetup(){
        
        self.panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(didPanWith(gestureRecognizer:)))
        panGestureRecognizer.maximumNumberOfTouches = 1
        panGestureRecognizer.delegate = self
        
        self.view.addGestureRecognizer(self.panGestureRecognizer)
    }
    
    @objc func didPanWith(gestureRecognizer: UIPanGestureRecognizer) {
//        print("너 작동하니 : \(gestureRecognizer)")
        //        if self.currentMode != .full || (self.currentMode == .full){
        switch gestureRecognizer.state {
        case .began:
            //                    self.changeScreenMode(to: .normal)
            let velocity = gestureRecognizer.velocity(in: self.view)
            if (abs(velocity.x) < abs(velocity.y)) {
                guard self.subView.imageSlider.isEnablePopView() else { return }
                self.transitionController.isInteractive = true
                let _ = self.navigationController?.popViewController(animated: true)
                self.subView.imageSlider.collectionView.isScrollEnabled = false
            }
        case .ended, .cancelled, .failed:
            if self.transitionController.isInteractive {
                
                self.transitionController.isInteractive = false
                self.transitionController.didPanWith(gestureRecognizer: gestureRecognizer)
                self.subView.imageSlider.collectionView.isScrollEnabled = true
            }
        default:
            if self.transitionController.isInteractive {
                self.transitionController.didPanWith(gestureRecognizer: gestureRecognizer)
            }
        }
        //        }
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        NotificationCenter.default.post(name: Notification.Name("orientation"), object: self, userInfo: nil)
        super.viewWillTransition(to: size, with: coordinator)
        
    }
    
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
//        print("wtf : \(gestureRecognizer)")
        if let gestureRecognizer = gestureRecognizer as? UIPanGestureRecognizer {
            let velocity = gestureRecognizer.velocity(in: self.view)

            var velocityCheck : Bool = false

            if UIDevice.current.orientation.isLandscape {
                velocityCheck = //(velocity.x > 100 || velocity.x < -100 ||
                    (abs(velocity.x) > abs(velocity.y))
//                velocityCheck = velocity.y  50
            }
//            else {
//
//                velocityCheck = velocity.x < 0
//            }
            if velocityCheck {
                return false
            }
        }
        
        return true
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
//        print("shouldRecognizeSimultaneouslyWith : \(gestureRecognizer)")
        if otherGestureRecognizer == self.subView.imageSlider.collectionView.panGestureRecognizer {
            if self.subView.imageSlider.collectionView.contentOffset.y == 0 {
                return true
            }
        }else if let cellsScroll = (self.subView.imageSlider.collectionView.visibleCells.first as? ImageSliderCell)?.scrollView, otherGestureRecognizer == cellsScroll.panGestureRecognizer{
            if cellsScroll.contentOffset.y == 0{
                return true
            }
        }
        return false
    }
    
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldBeRequiredToFailBy otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return self.transitionController.isInteractive
    }
}

extension ZoomingViewController: ImageSliderDelegate{
    func readyforPageSlide(_ pageSlider: ImageSlider, collectionView: UICollectionView, numberOfPages: Int){
        ARVideoPlayerController.sharedVideoPlayer.pausePlayerVideosForPaging(collectionView: collectionView)
    }
}

extension ZoomingViewController: ZoomAnimatorForIndexDelegate{
    
    func transitionIndexPath() -> Int{
        currentIndex.value
    }
}

extension ZoomingViewController: ZoomAnimatorDelegate {
    func zoominRefereneceView(for zoomAnimator: ZoomAnimator) -> UIView? {
        return self.view
    }
    
    func transitionWillStartWith(zoomAnimator: ZoomAnimator) {
    }
    
    func transitionDidEndWith(zoomAnimator: ZoomAnimator) {
    }
    
    func referenceImageView(for zoomAnimator: ZoomAnimator) -> UIImageView? {
        guard let cell = self.subView.imageSlider.collectionView.visibleCells.first as? ImageSliderCell else {
            return nil
        }
        guard self.subView.imageSlider.isEnablePopView() else { return nil }
        
        return cell.shotImageView
    }
    
    func referenceImageViewFrameInTransitioningView(for zoomAnimator: ZoomAnimator) -> CGRect? {
        guard let cell = self.subView.imageSlider.collectionView.visibleCells.first as? ImageSliderCell else {
            return nil
        }
        
        guard self.subView.imageSlider.isEnablePopView() else { return nil }
        
        return cell.shotImageView.frame
    }
}
