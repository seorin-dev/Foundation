//
//  ZoomImageCell.swift
//  FoundationProj
//
//  Created by baedy on 2020/05/28.
//  Copyright © 2020 baedy. All rights reserved.
//

import AVFoundation
import AVKit
import Then
import UIKit
import Photos
import Reusable
import RxCocoa
import RxSwift
import SDWebImage

class ZoomImageCell<T>: UICollectionViewCell, ImageSliderCell, Reusable, UIScrollViewDelegate{
    
    let genericRelay = PublishRelay<T>()
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    var doubleTapGestureRecognizer: UITapGestureRecognizer!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupLayout()
        bindData()
        setupGesture()
        
        NotificationCenter.default.addObserver(self, selector: #selector(rotated), name: Notification.Name("orientation"), object: nil)
    }
    
    deinit {
//        Log.d("imageCell deinit")
        NotificationCenter.default.removeObserver(self, name: Notification.Name("orientation"), object: nil)
    }
    
    @objc func rotated(){
        DispatchQueue.main.async {
            self.updateZoomScaleForSize(self.shotImageView.image?.size, self.scrollView, self.bounds.size)
        }
    }
    
    func setupGesture(){
        isImage = false
        self.doubleTapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(didDoubleTapWith(gestureRecognizer:)))
        self.doubleTapGestureRecognizer.numberOfTapsRequired = 2
        self.addGestureRecognizer(doubleTapGestureRecognizer)
    }
    
    func setupLayout(){
        clearLayout()
        scrollView.addSubview(shotImageView)
        
        self.addSubviews([scrollView])
        scrollView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        shotImageView.snp.remakeConstraints {
            $0.top.bottom.leading.trailing.equalTo(scrollView)
        }
    }
    
    func bindData(){
        genericRelay.asObservable()
            .subscribe(onNext: dataLoad)
            .disposed(by: rx.disposeBag)
    }
    
    var image: UIImage!{
        didSet{
            self.shotImageView.image = image
        }
    }
    
    func dataLoad<T>(item: T){
        if let asset = item as? PHAsset{
//            Log.d("asset: \(asset)")
            PHRepository.startCaching(withPHAsset: [asset])
            
            _ = PHRepository.getImageFromAsset(asset, options:  PHRepository.highQuImageFetchOptions,completion: {[weak self] image in
                guard let `self` = self else { return }
//                self.shotImageView.image = image
                self.image = image
                self.imageDidSet()
            })
            self.isImage = asset.isImage
            
        }else if let url = item as? URL{
//            Log.d("url : \(url)")
            imageURLLoad(url: url)
        }else if let urlString = item as? String, let url = URL(string: urlString){
//            Log.d("url : \(url)")
            imageURLLoad(url: url)
        }else if let image = item as? UIImage{
//            Log.d("image : \(image)")
//            self.shotImageView.image = image
            self.image = image
            imageDidSet()
        }
    }
    
    func imageURLLoad(url: URL){
        shotImageView.sd_setImage(with: url) {[weak self] image, _, _, _ in
            guard let `self` = self else { return }
            self.imageDidSet()
        }
    }
    
    func imageDidSet(){
        DispatchQueue.main.async { [weak self] in
            guard let `self` = self else { return }
            
            let image = self.shotImageView.image
            self.shotImageView.frame = CGRect(x: self.shotImageView.frame.origin.x, y: self.shotImageView.frame.origin.y, width: image?.size.width ?? 0, height: image?.size.height ?? 0)
            
            self.updateZoomScaleForSize(self.shotImageView.image?.size, self.scrollView, self.bounds.size)
            self.layoutIfNeeded()
            self.updateConstraintsForSize(self.bounds.size)
        }        
    }
    
    private func clearLayout() {
        self.scrollView.removeFromSuperview()
        self.shotImageView.removeFromSuperview()
    }
    
    var viewBounds: CGSize{
        get{
            self.bounds.size
        }
    }
    
    lazy var scrollView = UIScrollView().then {
        $0.bouncesZoom = true
        $0.maximumZoomScale = 3.0
        $0.minimumZoomScale = 1.0
        $0.zoomScale = 1.0
        $0.contentInsetAdjustmentBehavior = .never
        $0.bounces = false
        $0.delegate = self
    }
    
    lazy var shotImageView = UIImageView().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.backgroundColor = .black
        $0.contentMode = .scaleToFill
    }
    
    var isImage: Bool!
    
    var playerController: AVPlayerViewController?
    lazy var videoLayer = AVPlayerLayer().then {
        $0.videoGravity = AVLayerVideoGravity.resizeAspectFill
        $0.backgroundColor = UIColor.clear.cgColor
    }
    
    // TODO: 비디오 자동 재생 로직 추가 
    var videoAsset: PHAsset? {
        didSet {
            if let video = videoAsset {
                self.playerController = AVPlayerViewController()
                video.videoURL(completionHandler: {[weak self] url in
                    guard let `self` = self, let url = url else { return }
                    let player = AVPlayer(url: url)
                    
                    self.playerController?.player = player
                })
            }else{
                videoLayer.isHidden = videoAsset == nil
                self.playerController = nil
            }
        }
    }
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return shotImageView
    }
    
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        updateConstraintsForSize(scrollView.bounds.size)
        
        self.layoutIfNeeded()
    }
    
    @objc func didDoubleTapWith(gestureRecognizer: UITapGestureRecognizer) {
        if isImage {
            let pointInView = gestureRecognizer.location(in: shotImageView)
            var newZoomScale = self.scrollView.maximumZoomScale
            
            if self.scrollView.zoomScale >= newZoomScale || abs(self.scrollView.zoomScale - newZoomScale) <= 0.01 {
                newZoomScale = self.scrollView.minimumZoomScale
            }
            
            let width = self.scrollView.bounds.width / newZoomScale
            let height = self.scrollView.bounds.height / newZoomScale
            let originX = pointInView.x - (width / 2.0)
            let originY = pointInView.y - (height / 2.0)
            
            let rectToZoomTo = CGRect(x: originX, y: originY, width: width, height: height)
            self.scrollView.zoom(to: rectToZoomTo, animated: true)
        }
    }
}
