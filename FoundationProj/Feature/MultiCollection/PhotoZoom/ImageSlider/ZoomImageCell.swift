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

class ZoomImageCell<T>: UICollectionViewCell, ImageSliderCell, Reusable, UIScrollViewDelegate, ARAutoPlayVideoLayerContainer{
    var playerController: ARVideoPlayerController?
    var videoURL: String?{
        didSet {
            if let videoURL = videoURL {
                ARVideoPlayerController.sharedVideoPlayer.setupVideoFor(url: videoURL)
            }
            DispatchQueue.main.async {
                self.videoView.isHidden = self.videoURL == nil
                self.videoLayer.isHidden = self.videoURL == nil
            }
        }
    }
    
    func visibleVideoSize() -> CGFloat {
        let videoFrameInParentSuperView: CGRect? = self.superview?.superview?.convert(videoView.frame, from: videoView)
        guard let videoFrame = videoFrameInParentSuperView,
            let superViewFrame = superview?.frame else {
                return 0
        }
        let visibleVideoFrame = videoFrame.intersection(superViewFrame)
        return visibleVideoFrame.size.width
    }
    
    
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
        
        self.addSubviews([scrollView, videoView])
        scrollView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        shotImageView.snp.remakeConstraints {
            $0.top.bottom.leading.trailing.equalTo(scrollView)
        }
        
        videoView.snp.makeConstraints{
            $0.edges.equalToSuperview()
        }
        
        self.videoView.layer.addSublayer(self.videoLayer)
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
            shotImageView.image = nil
            videoAsset = nil
            
            PHRepository.startCaching(withPHAsset: [asset])
            switch asset.getAssetType{
            case .image(asset: let asset):
                _ = PHRepository.getImageFromAsset(asset, options:  PHRepository.highQuImageFetchOptions,completion: {[weak self] image in
                    guard let `self` = self else { return }
                    //                self.shotImageView.image = image
                    self.image = image
                    self.imageDidSet()
                })
                self.isImage = asset.isImage
            case .gif(asset: let asset):
                _ = PHRepository.getImageDataFromAsset(asset, options: PHRepository.highQuImageFetchOptions, completion: { [weak self] image in
                    guard let `self` = self else { return }
                    self.shotImageView.image = image
                    self.imageDidSet()
                })
                
                self.isImage = false
            case .video(asset: let asset):
//                self.videoView.frame = CGRect(x: self.videoView.frame.origin.x, y: self.videoView.frame.origin.y, width: self.frame.width, height: self.frame.height)
                videoAsset = asset
                break
            case .etc:
                break
            }
            
            
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
        
        scrollView.contentMode = .scaleAspectFill
    }
    
    func imageURLLoad(url: URL){
        shotImageView.sd_setImage(with: url) {[weak self] image, _, _, _ in
            guard let `self` = self else { return }
            self.imageDidSet()
            self.isImage = true
        }
    }
    
    func imageDidSet(){
        DispatchQueue.main.async { [weak self] in
            guard let `self` = self else { return }
            
            let image = self.shotImageView.image
            self.shotImageView.frame = CGRect(x: self.shotImageView.frame.origin.x, y: self.shotImageView.frame.origin.y, width: image?.size.width ?? self.frame.width, height: image?.size.height ?? self.frame.height)
            
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
        $0.isOpaque = false
        $0.bouncesZoom = true
        $0.maximumZoomScale = 3.0
        $0.minimumZoomScale = 1.0
        $0.zoomScale = 1.0
        $0.automaticallyAdjustsScrollIndicatorInsets = false
        $0.contentInsetAdjustmentBehavior = .never
        $0.bounces = false
        $0.delegate = self
        $0.isScrollEnabled = true
    }
    
    lazy var shotImageView = UIImageView().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.backgroundColor = .black
        $0.contentMode = .scaleToFill
    }
    
    var isImage: Bool!
    
    lazy var videoView = UIView().then{
        $0.backgroundColor = .clear
        $0.isHidden = true
    }
    
    lazy var videoLayer = AVPlayerLayer().then {
        $0.videoGravity = AVLayerVideoGravity.resizeAspectFill
        $0.backgroundColor = UIColor.clear.cgColor
    }
    
    // TODO: 비디오 자동 재생 로직 추가 
    var videoAsset: PHAsset? {
        didSet {
            if let video = videoAsset {
//                self.playerController = AVPlayerViewController()
                self.image = nil
                video.videoURL(completionHandler: {[weak self] url in
                    guard let `self` = self else { return }
                    guard let url = url?.absoluteString else { return }
                    self.videoURL = url
                    let userInfo: [AnyHashable : Any] = ["asset": video]
                    NotificationCenter.default.post(name: Notification.Name("VideoURLLoaded"), object: nil, userInfo: userInfo)
                })
            }else{
                videoURL = nil
            }
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        videoLayer.frame = CGRect(x: 0, y: 0, width: bounds.size.width, height: bounds.size.height)
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
