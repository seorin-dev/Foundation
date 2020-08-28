//
//  ARVideoPlayerController.swift
//  UPlusAR
//
//  Created by 최성욱 on 2020/03/28.
//  Copyright © 2020 최성욱. All rights reserved.
//

import AVFoundation
import UIKit

protocol ARAutoPlayVideoLayerContainer {
    var videoURL: String? { get set }
    var videoLayer: AVPlayerLayer { get set }
    func visibleVideoSize() -> CGFloat
}

class ARVideoPlayerController: NSObject, NSCacheDelegate {
    var minimumLayerHeightToPlay: CGFloat = 60
    var minimumLayerWidthToPlay: CGFloat = 200
    // Mute unmute video
    var mute = false
    var preferredPeakBitRate: Double = 1_000_000
    private static var playerViewControllerKVOContext = 0
    static let sharedVideoPlayer = ARVideoPlayerController()
    //video url for currently playing video
    private var videoURL: String?
    /**
     Stores video url as key and true as value when player item associated to the url
     is being observed for its status change.
     Helps in removing observers for player items that are not being played.
     */
    private var observingURLs = [String: Bool]()
    // Cache of player and player item
    private var videoCache = NSCache<NSString, ARVideoContainer>()
    private var videoLayers = VideoLayers()
    // Current AVPlapyerLayer that is playing video
    private var currentLayer: AVPlayerLayer?

    override init() {
        super.init()
        videoCache.delegate = self
    }

    /**
     Download of an asset of url if corresponding videocontainer
     is not present.
     Uses the asset to create new playeritem.
     */
    func setupVideoFor(url: String) {
        if self.videoCache.object(forKey: url as NSString) != nil {
            return
        }
        guard let URL = URL(string: url) else {
            return
        }
        let asset = AVURLAsset(url: URL)
        let requestedKeys = ["playable"]
        asset.loadValuesAsynchronously(forKeys: requestedKeys) { [weak self] in
            guard let strongSelf = self else {
                return
            }
            /**
             Need to check whether asset loaded successfully, if not successful then don't create
             AVPlayer and AVPlayerItem and return without caching the videocontainer,
             so that, the assets can be tried to be downloaded again when need be.
             */
            var error: NSError?
            let status = asset.statusOfValue(forKey: "playable", error: &error)
            switch status {
                case .loaded:
                    break
                case .failed, .cancelled:
                    print("Failed to load asset successfully")
                    return
                default:
                    print("Unkown state of asset")
                    return
            }
            let player = AVPlayer()
            let item = AVPlayerItem(asset: asset)
            DispatchQueue.main.async {
                let videoContainer = ARVideoContainer(player: player, item: item, url: url)
                strongSelf.videoCache.setObject(videoContainer, forKey: url as NSString)
                videoContainer.player.replaceCurrentItem(with: videoContainer.playerItem)
                /**
                 Try to play video again in case when playvideo method was called and
                 asset was not obtained, so, earlier video must have not run
                 */
                if strongSelf.videoURL == url, let layer = strongSelf.currentLayer {
                    strongSelf.playVideo(withLayer: layer, url: url)
                }
            }
        }
    }
    // Play video with the AVPlayerLayer provided
    func playVideo(withLayer layer: AVPlayerLayer, url: String) {
        videoURL = url
        currentLayer = layer
        if let videoContainer = self.videoCache.object(forKey: url as NSString) {
            layer.player = videoContainer.player
            videoContainer.playOn = true
            addObservers(url: url, videoContainer: videoContainer)
        }
        // Give chance for current video player to be ready to play
        DispatchQueue.main.async {
            if let videoContainer = self.videoCache.object(forKey: url as NSString),
                videoContainer.player.currentItem?.status == .readyToPlay {
                videoContainer.playOn = true
            }
        }
    }

    private func pauseVideo(forLayer layer: AVPlayerLayer, url: String) {
        videoURL = nil
        currentLayer = nil
        if let videoContainer = self.videoCache.object(forKey: url as NSString) {
            videoContainer.playOn = false
            //videoContainer.play = false
            removeObserverFor(url: url)
        }
    }

    func removeLayerFor(cell: ARAutoPlayVideoLayerContainer) {
        if let url = cell.videoURL {
            removeFromSuperLayer(layer: cell.videoLayer, url: url)
        }
    }

    private func removeFromSuperLayer(layer: AVPlayerLayer, url: String) {
        videoURL = nil
        currentLayer = nil
        if let videoContainer = self.videoCache.object(forKey: url as NSString) {
            videoContainer.playOn = false
            removeObserverFor(url: url)
        }
        layer.player = nil
    }

    private func pauseRemoveLayer(layer: AVPlayerLayer, url: String, layerHeight: CGFloat) {
        pauseVideo(forLayer: layer, url: url)
    }

    // Play video again in case the current player has finished playing
    @objc func playerDidFinishPlaying(note: NSNotification) {
        guard let playerItem = note.object as? AVPlayerItem,
            let currentPlayer = currentVideoContainer()?.player else {
                return
        }
        if let currentItem = currentPlayer.currentItem, currentItem == playerItem {
            currentPlayer.seek(to: CMTime.zero)
            currentPlayer.play()
        }
    }

    private func currentVideoContainer() -> ARVideoContainer? {
        if let currentVideoUrl = videoURL {
            if let videoContainer = videoCache.object(forKey: currentVideoUrl as NSString) {
                return videoContainer
            }
        }
        return nil
    }

    private func addObservers(url: String, videoContainer: ARVideoContainer) {
        if self.observingURLs[url] == false || self.observingURLs[url] == nil {
            videoContainer.player.currentItem?.addObserver(self,
                                                           forKeyPath: "status",
                                                           options: [.new, .initial],
                                                           context: &ARVideoPlayerController.playerViewControllerKVOContext)
            NotificationCenter.default.addObserver(self,
                                                   selector: #selector(self.playerDidFinishPlaying(note:)),
                                                   name: NSNotification.Name.AVPlayerItemDidPlayToEndTime,
                                                   object: videoContainer.player.currentItem)
            self.observingURLs[url] = true
        }
    }

    private func removeObserverFor(url: String) {
        if let videoContainer = self.videoCache.object(forKey: url as NSString) {
            if let currentItem = videoContainer.player.currentItem, observingURLs[url] == true {
                currentItem.removeObserver(self,
                                           forKeyPath: "status",
                                           context: &ARVideoPlayerController.playerViewControllerKVOContext)
                NotificationCenter.default.removeObserver(self,
                                                          name: NSNotification.Name.AVPlayerItemDidPlayToEndTime,
                                                          object: currentItem)
                observingURLs[url] = false
            }
        }
    }

    func pausePlayerVideosForPaging(collectionView: UICollectionView, appEnteredFromBackground: Bool = false) {
        let visisbleCells = collectionView.visibleCells
        var videoCellContainer: ARAutoPlayVideoLayerContainer?
        var maxWidth: CGFloat = 0.0
        for cellView in visisbleCells {
            guard let containerCell = cellView as? ARAutoPlayVideoLayerContainer,
                let videoCellURL = containerCell.videoURL else {
                    continue
            }
            let width = containerCell.visibleVideoSize()
            if maxWidth < width {
                maxWidth = width
                videoCellContainer = containerCell
            }
            pauseRemoveLayer(layer: containerCell.videoLayer, url: videoCellURL, layerHeight: width)
        }
        guard let videoCell = videoCellContainer,
            let videoCellURL = videoCell.videoURL else {
            return
        }
//        let minCellLayerWidth = videoCell.videoLayer.bounds.size.width
        /**
         Visible video layer height should be at least more than max of predefined minimum height and
         cell's videolayer's 50% height to play video.
         */
//        let minimumVideoLayerVisibleWidth = max(minCellLayerWidth, minimumLayerWidthToPlay)
        if maxWidth == videoCell.videoLayer.bounds.size.width {
            if appEnteredFromBackground {
                setupVideoFor(url: videoCellURL)
            }
            playVideo(withLayer: videoCell.videoLayer, url: videoCellURL)
        }
    }
    
    func pausePlayerVideosFor(collectionView: UICollectionView, appEnteredFromBackground: Bool = false) {
        let visisbleCells = collectionView.visibleCells
        var videoCellContainer: ARAutoPlayVideoLayerContainer?
        var maxHeight: CGFloat = 0.0
        for cellView in visisbleCells {
            guard let containerCell = cellView as? ARAutoPlayVideoLayerContainer,
                let videoCellURL = containerCell.videoURL else {
                    continue
            }
            let height = containerCell.visibleVideoSize()
            if maxHeight < height {
                maxHeight = height
                videoCellContainer = containerCell
            }
            pauseRemoveLayer(layer: containerCell.videoLayer, url: videoCellURL, layerHeight: height)
        }
        guard let videoCell = videoCellContainer,
            let videoCellURL = videoCell.videoURL else {
            return
        }
        let minCellLayerHeight = videoCell.videoLayer.bounds.size.height * 0.5
        /**
         Visible video layer height should be at least more than max of predefined minimum height and
         cell's videolayer's 50% height to play video.
         */
        let minimumVideoLayerVisibleHeight = max(minCellLayerHeight, minimumLayerHeightToPlay)
        if maxHeight > minimumVideoLayerVisibleHeight {
            if appEnteredFromBackground {
                setupVideoFor(url: videoCellURL)
            }
            playVideo(withLayer: videoCell.videoLayer, url: videoCellURL)
        }
    }

    func pausePlayerVideosFor(tableView: UITableView, appEnteredFromBackground: Bool = false) {
        let visisbleCells = tableView.visibleCells
        var videoCellContainer: ARAutoPlayVideoLayerContainer?
        var maxHeight: CGFloat = 0.0
        for cellView in visisbleCells {
            guard let containerCell = cellView as? ARAutoPlayVideoLayerContainer,
                let videoCellURL = containerCell.videoURL else {
                    continue
            }
            let height = containerCell.visibleVideoSize()
            if maxHeight < height {
                maxHeight = height
                videoCellContainer = containerCell
            }
            pauseRemoveLayer(layer: containerCell.videoLayer, url: videoCellURL, layerHeight: height)
        }
        guard let videoCell = videoCellContainer,
            let videoCellURL = videoCell.videoURL else {
            return
        }
        let minCellLayerHeight = videoCell.videoLayer.bounds.size.height * 0.5
        /**
         Visible video layer height should be at least more than max of predefined minimum height and
         cell's videolayer's 50% height to play video.
         */
        let minimumVideoLayerVisibleHeight = max(minCellLayerHeight, minimumLayerHeightToPlay)
        if maxHeight > minimumVideoLayerVisibleHeight {
            if appEnteredFromBackground {
                setupVideoFor(url: videoCellURL)
            }
            playVideo(withLayer: videoCell.videoLayer, url: videoCellURL)
        }
    }

    // Set observing urls false when objects are removed from cache
    func cache(_ cache: NSCache<AnyObject, AnyObject>, willEvictObject obj: Any) {
        if let videoObject = obj as? ARVideoContainer {
            observingURLs[videoObject.url] = false
        }
    }

    // Play video only when current videourl's player is ready to play
    override func observeValue(forKeyPath keyPath: String?, of object: Any?,
                               change: [NSKeyValueChangeKey: Any]?,
                               context: UnsafeMutableRawPointer?) {
        // Make sure the this KVO callback was intended for this view controller.
        guard context == &ARVideoPlayerController.playerViewControllerKVOContext else {
            super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
            return
        }
        if keyPath == "status" {
            /**
             Handle `NSNull` value for `NSKeyValueChangeNewKey`, i.e. when
             `player.currentItem` is nil.
             */
            let newStatus: AVPlayerItem.Status
            if let newStatusAsNumber = change?[NSKeyValueChangeKey.newKey] as? NSNumber {
                newStatus = AVPlayerItem.Status(rawValue: newStatusAsNumber.intValue)!
                if newStatus == .readyToPlay {
                    guard let item = object as? AVPlayerItem,
                        let currentItem = currentVideoContainer()?.player.currentItem else {
                            return
                    }
                    if item == currentItem && currentVideoContainer()?.playOn == true {
                        currentVideoContainer()?.playOn = true
                    }
                }
            } else {
                newStatus = .unknown
            }
            if newStatus == .failed {
            }
        }
    }

    deinit {
    }
}
