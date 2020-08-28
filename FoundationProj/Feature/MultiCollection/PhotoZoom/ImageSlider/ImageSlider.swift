//
//  ImageSlider.swift
//  FoundationProj
//
//  Created by baedy on 2020/05/13.
//  Copyright © 2020 baedy. All rights reserved.
//

import RxCocoa
import RxSwift
import UIKit
import Then

public protocol ImageSliderDelegate: class {
//    func pageItemSize(_ Slider: ImageSlider) -> CGSize
    
    func readyforPageSlide(_ pageSlider: ImageSlider, collectionView: UICollectionView, numberOfPages: Int)
//
//    @objc
//    optional func viewAtIndex(_ Slider: ImageSlider, previusPage: Int, currentPage: Int)
//
//    @objc
//    optional func scrollViewDidEndDecelerating()
//
//    @objc
//    optional func scrollViewDidEndDragging(willDecelerate decelerate: Bool)
}

public class ImageSlider: UIView {
    
    weak var delegate: ImageSliderDelegate?
    
    let current = BehaviorRelay<Int>(value: 0)
    
    override public init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
        controlBinding()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
        controlBinding()
    }
    
    func controlBinding() {
        collectionView.rx.reloaded.skip(1).subscribe(onNext: { [weak self] in
            guard let `self` = self else { return }
            let pages = self.collectionView.numberOfItems(inSection: 0)
            self.delegate?.readyforPageSlide(self, collectionView: self.collectionView, numberOfPages: pages)
        }).disposed(by: rx.disposeBag)
    }

    func setupView() {
        addSubview(collectionView)
        collectionView.snp.makeConstraints {
            $0.top.leading.trailing.bottom.equalToSuperview()
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(rotated), name: Notification.Name("orientation"), object: nil)
        
        NotificationCenter.default.rx
            .notification(UIApplication.willEnterForegroundNotification)
            .subscribe(onNext: {[weak self] _ in
                guard let `self` = self else { return }
                self.appEnteredFromBackground()
        }).disposed(by: rx.disposeBag)
    }
    
    func pausePlayerVideos(collectionView: UICollectionView? = nil) {
        ARVideoPlayerController.sharedVideoPlayer.pausePlayerVideosForPaging(collectionView: collectionView ?? self.collectionView)
    }
    
    @objc func appEnteredFromBackground() {
        ARVideoPlayerController.sharedVideoPlayer.pausePlayerVideosForPaging(collectionView: collectionView, appEnteredFromBackground: true)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: Notification.Name("orientation"), object: nil)
    }
    
    lazy var collectionView = UICollectionView(frame: .zero, collectionViewLayout: collectionViewLayout()).then {
        $0.backgroundColor = .black
        $0.isPagingEnabled = true
        $0.alwaysBounceHorizontal = false
//        $0.bounces = false
        $0.showsVerticalScrollIndicator = false
        $0.showsHorizontalScrollIndicator = false
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.delegate = self
        $0.contentInset = .zero
        $0.automaticallyAdjustsScrollIndicatorInsets = true
        $0.contentInsetAdjustmentBehavior = .never
        
//        $0.layer.shouldRasterize = true
//        $0.layer.rasterizationScale = UIScreen.main.scale
//        $0.isOpaque = true
    }
    
    private func collectionViewLayout() -> UICollectionViewLayout {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 0
        //layout.headerReferenceSize = .zero
        layout.sectionInset = UIEdgeInsets(top: 0,
                                           left: 0,
                                           bottom: 0,
                                           right: 0)
        
        layout.itemSize = CGSize(width: UIScreen.main.bounds.width,
                                 height: UIScreen.main.bounds.height)
        return layout
    }
    
    @objc func rotated(){
        DispatchQueue.main.async { [weak self] in
            guard let `self` = self else { return }
            if let layout = self.collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
                
                UIView.animate(withDuration: 0.2, animations: {
                    self.scrollToPage(index: self.current.value, animated: false)
                }, completion: { _ in
                    if let cell = self.collectionView.visibleCells.first as? ImageSliderCell{
                        cell.shotImageView.center = cell.scrollView.center
                    }
                    layout.itemSize = self.frame.size
                    layout.headerReferenceSize = .zero
                    layout.footerReferenceSize = .zero
                    layout.sectionInset = .zero
                    
                    layout.invalidateLayout()
                })
            }
        }
    }
    
    func isEnablePopView() -> Bool{
        Int(collectionView.contentOffset.x) % Int(self.collectionView.frame.width) <= 4 && !collectionView.isDragging
    }
    
    func scrollToPage(index: Int, animated: Bool = false) {
        DispatchQueue.main.async {
            
            if index <= self.collectionView.numberOfItems(inSection: 0) && index >= 0 {

                let iframe = CGRect(x: self.collectionView.frame.width * CGFloat(index), y: self.collectionView.contentOffset.y, width: self.collectionView.frame.width, height: self.collectionView.frame.height)
                self.collectionView.setContentOffset(iframe.origin, animated: animated)
                
//                if let cell = self.collectionView.visibleCells.first as? ImageSliderCell{
//                    cell.scrollView.layoutIfNeeded()
//                }
//
//                let zIndex = index - 1
//                if UIDevice.current.orientation.isLandscape{
//                    // land
//                }else{
//                    let iframe = CGRect(x: self.collectionView.frame.width * CGFloat(index), y: self.collectionView.contentOffset.y, width: self.collectionView.frame.width, height: self.collectionView.frame.height)
//                    self.collectionView.setContentOffset(iframe.origin, animated: animated)
//                }
                //            let zIndex = index
                //            let iframe = CGRect(x: self.collectionView.frame.width * CGFloat(zIndex), y: 0, width: self.collectionView.frame.width, height: self.collectionView.frame.height)
//                self.collectionView.scrollToItem(at: IndexPath(item: index, section: 0), at: .centeredHorizontally, animated: false)
            }
        }
    }
}

extension ImageSlider: UICollectionViewDelegateFlowLayout {
    public func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {

    }
    
    public func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        DispatchQueue.main.async {
            if let cell = cell as? ImageSliderCell {
                cell.scrollView.zoomScale = cell.scrollView.minimumZoomScale
            }
        }
    }
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        self.frame.size
    }
    
    public func scrollViewWillBeginDecelerating(_ scrollView: UIScrollView) {
        pausePlayerVideos()
    }
    
    public func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        updateCurrentIndex(scrollView)
        pausePlayerVideos()
    }
    
    public func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        updateCurrentIndex(scrollView)
        pausePlayerVideos()
//        delegate?.scrollViewDidEndDecelerating?()
    }

    public func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        updateCurrentIndex(scrollView)
        if !decelerate {
            pausePlayerVideos()
        }
//        delegate?.scrollViewDidEndDragging?(willDecelerate: decelerate)
    }
    
    func updateCurrentIndex(_ scrollView: UIScrollView){
//        NSObject.cancelPreviousPerformRequests(withTarget: self)
        let pageNumber = round(scrollView.contentOffset.x / scrollView.frame.size.width)
        //        currentPosition = Int(pageNumber)
        //        scrollToPage(index: Int(pageNumber))
        
        current.accept(Int(pageNumber))
        
//        if let cell = collectionView.cellForItem(at: IndexPath(item: Int(pageNumber), section: 0)) as? ImageSliderCell {
//            cell.scrollView.zoomScale = cell.scrollView.minimumZoomScale
//        }
        
        
    }
}
