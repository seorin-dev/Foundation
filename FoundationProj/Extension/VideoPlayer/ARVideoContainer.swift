//
//  ARVideoPlayerContainer.swift
//  UPlusAR
//
//  Created by 최성욱 on 2020/03/28.
//  Copyright © 2020 최성욱. All rights reserved.
//

import AVFoundation
import UIKit

class ARVideoContainer {
    var url: String
    var playOn: Bool {
        didSet {
            player.isMuted = ARVideoPlayerController.sharedVideoPlayer.mute
            playerItem.preferredPeakBitRate = ARVideoPlayerController.sharedVideoPlayer.preferredPeakBitRate
            if playOn && playerItem.status == .readyToPlay {
                player.play()
            } else {
                player.pause()
            }
        }
    }

    let player: AVPlayer
    let playerItem: AVPlayerItem

    init(player: AVPlayer, item: AVPlayerItem, url: String) {
        self.player = player
        self.playerItem = item
        self.url = url
        playOn = false
    }
}
