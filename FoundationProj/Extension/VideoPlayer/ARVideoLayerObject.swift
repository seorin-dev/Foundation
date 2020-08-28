//
//  ARVideoPlayerObject.swift
//  UPlusAR
//
//  Created by 최성욱 on 2020/03/28.
//  Copyright © 2020 최성욱. All rights reserved.
//

import AVFoundation
import UIKit

class ARVideoLayerObject: NSObject {
    var layer = AVPlayerLayer()
    var used = false
    override init() {
        layer.backgroundColor = UIColor.clear.cgColor
        layer.videoGravity = AVLayerVideoGravity.resize
    }
}

struct VideoLayers {
    var layers = [ARVideoLayerObject]()
    init() {
        for _ in 0..<1 {
            layers.append(ARVideoLayerObject())
        }
    }

    func getLayerForParentLayer(parentLayer: CALayer) -> AVPlayerLayer {
        for videoObject in layers {
            if videoObject.layer.superlayer == parentLayer {
                return videoObject.layer
            }
        }
        return getFreeVideoLayer()
    }

    func getFreeVideoLayer() -> AVPlayerLayer {
        for videoObject in layers {
            if videoObject.used == false {
                videoObject.used = true
                return videoObject.layer
            }
        }
        return layers[0].layer
    }

    func freeLayer(layerToFree: AVPlayerLayer) {
        for videoObject in layers {
            if videoObject.layer == layerToFree {
                videoObject.used = false
                videoObject.layer.player = nil
                if videoObject.layer.superlayer != nil {
                    videoObject.layer.removeFromSuperlayer()
                }
                break
            }
        }
    }
}
