//
//  PHAsset+.swift
//  FoundationProj
//
//  Created by baedy on 2020/05/11.
//  Copyright © 2020 baedy. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift
import Photos
import MobileCoreServices

extension PHAsset{
    var isGIF: Bool{
        get {
            let resource = PHAssetResource.assetResources(for: self)
            guard let data = resource.first, data.uniformTypeIdentifier == (kUTTypeGIF as String) else{
                return false
            }
            
            return true
        }
    }
    
    var isImage: Bool{
        get{
            (self.mediaType == .image) && !self.isGIF
        }
    }
    
    var isVideo: Bool{
        get{
            self.mediaType == .video
        }
    }
    
    var getAssetType: AssetType{
        get {
            if self.isImage{
                return .image(asset: self)
            }else if self.isGIF{
                return .gif(asset: self)
            }else if self.isVideo{
                
                return .video(asset: self)
            }else{
                return .etc(asset: self)
            }
        }
    }
    
    func videoURL(completionHandler : @escaping ((_ responseURL : URL?) -> Void)){
        guard self.isVideo else { return }
        
        let options: PHVideoRequestOptions = PHVideoRequestOptions()
        options.version = .original
        PHImageManager.default().requestAVAsset(forVideo: self, options: options, resultHandler: {(asset: AVAsset?, audioMix: AVAudioMix?, info: [AnyHashable : Any]?) -> Void in
            if let urlAsset = asset as? AVURLAsset {
                let localVideoUrl: URL = urlAsset.url as URL
                completionHandler(localVideoUrl)
            } else {
                completionHandler(nil)
            }
        })
        
    }
}

