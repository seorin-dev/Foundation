//
//  PHRepository.swift
//  FoundationProj
//
//  Created by baedy on 2020/05/22.
//  Copyright © 2020 baedy. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import Then
import Photos
import NSObject_Rx

enum AssetType{
    case image(asset: PHAsset)
    case gif(asset: PHAsset)
    case video(asset: PHAsset)
    case etc(asset: PHAsset)
    
    var correctAsset: Bool{
        get {
            switch self {
            case .etc:
                return false
            default:
                return true
            }
        }
    }
    
    var getAsset: PHAsset{
        get{
            switch self {
            case .etc(let data), .image(let data), .gif(let data), .video(let data):
                return data
            }
        }
    }
        
    func requestImage(imageView: UIImageView){
        switch self {
        case .etc(let data), .image(let data), .gif(let data), .video(let data):
            PHRepository.getImageFromAsset(data).bind(to: imageView.rx.image).disposed(by: imageView.rx.disposeBag)
        }
    }
}

public enum AssetFetchResult<T> {
    case assets([T])
    case asset(T)
    case error
}

struct PHRepository {
    public struct FetchOptions {
        public var count: Int
        public var newestFirst: Bool
        public var size: CGSize?
        public var contentMode: PHImageContentMode
        
        public init() {
            self.count = 0
            self.newestFirst = true
            self.size = CGSize(width: 720, height: 1024)
            self.contentMode = .aspectFill
        }
    }
    
    static let imageManager = PHCachingImageManager().then{
        $0.allowsCachingHighQualityImages = false
    }
    static let defaultAlbumName = "U+AR"
    
    let assetListRelay = BehaviorRelay<[AssetType]>(value: [])
    
    public static var defaultImageFetchOptions: PHImageRequestOptions {
        let options = PHImageRequestOptions()
        options.version = .original
        options.deliveryMode = .highQualityFormat
        options.resizeMode = .fast
        options.isNetworkAccessAllowed = true
//        options.isSynchronous = nil
        
        return options
    }
    
    public static var highQuImageFetchOptions: PHImageRequestOptions {
        let options = PHImageRequestOptions()
        options.version = .original
        options.deliveryMode = .highQualityFormat
        options.resizeMode = .none
        options.isNetworkAccessAllowed = true
        options.isSynchronous = false
        
        return options
    }
    
    
    
    public static func startCaching(withPHAsset assets: [PHAsset]){
        DispatchQueue.main.async{
            imageManager.startCachingImages(for: assets, targetSize: CGSize(width: 720, height: 1024), contentMode: .aspectFill, options: nil)
        }
    }
    
    public static func cancelCaching(withPHAsset assets: [PHAsset]){
//        DispatchQueue.main.async{
            imageManager.stopCachingImages(for: assets, targetSize: CGSize(width: 720, height: 1024), contentMode: .aspectFill, options: nil)
//        }
    }
    
    public static func allStopCaching(){
        imageManager.stopCachingImagesForAllAssets()
    }
    
    public static func createAlbum(named: String? = nil, completion: @escaping ( _ album: PHAssetCollection?) -> ()) {
//        print("createAlbum: named \(named)")
        DispatchQueue.main.async{
            var placeholder: PHObjectPlaceholder?
            
            PHPhotoLibrary.shared().performChanges({
                let createAlbumRequest = PHAssetCollectionChangeRequest.creationRequestForAssetCollection(withTitle: named ?? defaultAlbumName)
                placeholder = createAlbumRequest.placeholderForCreatedAssetCollection
            }) { success, error in
                var album: PHAssetCollection?
                if success {
                    let collectionFetchResult = PHAssetCollection.fetchAssetCollections(withLocalIdentifiers: [placeholder?.localIdentifier ?? ""], options: nil)
                    album = collectionFetchResult.firstObject
                }
                
                completion(album)
            }
        }
    }
    
    public static func getImagesFromAlbum(named: String, fetchOptions: FetchOptions = FetchOptions(), options: PHImageRequestOptions = defaultImageFetchOptions, completion: @escaping (_ result: AssetFetchResult<UIImage>) -> ()) {
//        print("getImagesFromAlbum: named \(named)")
        DispatchQueue.main.async{
            let albumFetchOptions = PHFetchOptions()
            albumFetchOptions.predicate = NSPredicate(format: "(estimatedAssetCount > 0) AND (localizedTitle == %@)", named)
            let albums = PHAssetCollection.fetchAssetCollections(with: .album, subtype: .any, options: albumFetchOptions)
            guard let album = albums.firstObject else { return completion(.error) }
            
            PHRepository.getImagesFromAlbum(album: album, fetchOptions: fetchOptions, completion: completion)
        }
    }
    
    public static func getImagesFromAlbum(album: PHAssetCollection, fetchOptions: FetchOptions = FetchOptions(), options: PHImageRequestOptions = defaultImageFetchOptions, completion: @escaping (_ result: AssetFetchResult<UIImage>) -> ()) {
//        print("getImagesFromAlbum: \(album)")
        DispatchQueue.main.async{
            PHRepository.getAssetsFromAlbum(album, fetchOptions, completion: { result in
                switch result {
                case .asset: ()
                case .error: completion(.error)
                case .assets(let assets):
//                    let imageManager = PHCachingImageManager.default()
                    assets.forEach { asset in
                        
                        self.imageManager.requestImage(
                            for: asset,
                            targetSize: fetchOptions.size ?? CGSize(width: asset.pixelWidth, height: asset.pixelHeight),
                            contentMode: .aspectFill,
                            options: options,
                            resultHandler: { image, _ in
                                guard let image = image else { return }
                                completion(.asset(image))
                        })
                    }
                }
            })
        }
    }
    
    public static func getTypeAssetFromAlbum(_ album: PHAssetCollection, _ fetchOptions: FetchOptions = FetchOptions(), completion: @escaping (_ result: [AssetType]) -> ()){
//        print("getTypeAssetFromAlbum: \(album)")
        DispatchQueue.main.async{
            PHRepository.getAssetsFromAlbum(album, fetchOptions, completion: {
                assets in
                switch assets{
                case .assets(let list):
                    completion( list.map{ $0.getAssetType } )
                case .error:
                    completion([])
                default:
                    break
                }
            })
        }
    }
    
     public static func collection(withAlbumName name: String? = nil) -> Observable<PHAssetCollection> {
//         print("collection withAlbumName: \(name)")
         return Observable<PHAssetCollection>.create{ observer in
             if let album = PHRepository.fetchAssetCollectionForAlbum(name) {
                 // 앨범이 있는 상태
                 observer.onNext(album)
             }else{
                 // 앨범이 없는 상태
                 PHRepository.createAlbum(named: name, completion: { responseAlbum in
                     guard let album = responseAlbum else {
                         return
                     }
                     observer.onNext(album)
                 })
             }
             
             return Disposables.create()
         }
     }
    
    public static func getImageFromAsset(_ asset: PHAsset, options: PHImageRequestOptions = defaultImageFetchOptions, fetchOptions: FetchOptions = FetchOptions()) -> Observable<UIImage>{
//        print("getImageFromAsset: \(asset)")
        return Observable<UIImage>.create{ observer in
            let requestId = PHRepository.getImageFromAsset(asset, options: options, fetchOptions: fetchOptions, completion: { result in
                observer.onNext(result)
            })
            
            self.imageManager.cancelImageRequest(requestId)
            return Disposables.create()
        }
    }
    
    public static func GetFuncImageFromAsset(withOption options: PHImageRequestOptions = defaultImageFetchOptions, fetchOptions: FetchOptions = FetchOptions()) -> ((PHAsset) -> Observable<UIImage>){
        return { asset in
            self.getImageFromAsset(asset, options: options, fetchOptions: fetchOptions)
        }
    }
    
    
    /// specific get image from asset
    public static func getImageFromAsset(_ asset: PHAsset, options: PHImageRequestOptions = defaultImageFetchOptions, fetchOptions: FetchOptions = FetchOptions(), completion: @escaping (_ result: UIImage) -> ()) -> PHImageRequestID{
//        print("getImageFromAsset: \(asset)")
        let imageManager = PHImageManager.default()
        
//        self.imageManager.startCachingImages(for: [asset], targetSize: fetchOptions.size ?? CGSize(width: 720, height: 1024), contentMode: .aspectFill, options: options)
        
        return imageManager.requestImage(for: asset, targetSize: fetchOptions.size ?? CGSize(width: 720, height: 1024), contentMode: fetchOptions.contentMode, options: options, resultHandler: { image, _ in
            guard let image = image else { return }
//            print("getImageFromAsset complete : \(image)")
            completion(image)
        })
    }
    
    // gif
    public static func getImageDataFromAsset(_ asset: PHAsset, options: PHImageRequestOptions = defaultImageFetchOptions,  completion: @escaping (_ result: UIImage) -> ()) -> PHImageRequestID {
        return imageManager.requestImageDataAndOrientation(for: asset, options: options, resultHandler: {
            (imageData, UTI, _, _) in
            guard let data = imageData, let image = UIImage.sd_image(withGIFData: data) else { return }
            completion(image)
        })
    }
    
    
    public static func getAssetsFromAlbum(_ album: PHAssetCollection, _ fetchOptions: FetchOptions = FetchOptions(), completion: @escaping (_ result: AssetFetchResult<PHAsset>) -> ()) {
//        print("getAssetsFromAlbum: \(album)")
        DispatchQueue.main.async{
            let phfetchOptions = PHFetchOptions()
            phfetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
            
            var assets = [PHAsset]()
            
            let fetchedAssets = PHAsset.fetchAssets(in: album, options: nil)
            
            let rangeLength = min(fetchedAssets.count, fetchOptions.count)
            let range = NSRange(location: 0, length: fetchOptions.count != 0 ? rangeLength : fetchedAssets.count)
            let indexes = NSIndexSet(indexesIn: range)
            fetchedAssets.enumerateObjects(at: indexes as IndexSet, options: []) { asset, index, stop in
                assets.append(asset)
            }
//            startCaching(withPHAsset: assets)
            
            if assets.count > 0{
                completion(.assets(assets))
            }else{
                completion(.error)
            }
            
        }
    }
    
    public static func getTypeAssetFromAlbum(_ album: PHAssetCollection, _ fetchOptions: FetchOptions = FetchOptions()) -> Observable<[AssetType]>{
//        print("getTypeAssetFromAlbum: \(album)")
        return Observable<[AssetType]>.create{ observer in
            PHRepository.getTypeAssetFromAlbum(album, completion: { result in
                observer.onNext(result)
            })
            return Disposables.create()
        }
    }
    
    public static func saveImage(withUIImage image: UIImage, to album: PHAssetCollection, completion: ((_ success: Bool, _ error: Error?) -> ())? = nil) {
        DispatchQueue.main.async{
            PHPhotoLibrary.shared().performChanges({
                let assetRequest = PHAssetChangeRequest.creationRequestForAsset(from: image)
                let placeholder = assetRequest.placeholderForCreatedAsset
                guard let _placeholder = placeholder else { completion?(false, nil); return; }
                
                let albumChangeRequest = PHAssetCollectionChangeRequest(for: album)
                albumChangeRequest?.addAssets([_placeholder] as NSFastEnumeration)
            }) { success, error in
                completion?(success, error)
            }
        }
    }
    
    public static func saveVideo(withVideoURL videoURL: URL, to album: PHAssetCollection, completion: ((_ success: Bool, _ error: Error?) -> ())? = nil){
        DispatchQueue.main.async{
            PHPhotoLibrary.shared().performChanges({
                let assetRequest = PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: videoURL)
                let placeholder = assetRequest?.placeholderForCreatedAsset
                guard let _placeholder = placeholder else { completion?(false, nil); return; }
                
                let albumChangeRequest = PHAssetCollectionChangeRequest(for: album)
                albumChangeRequest?.addAssets([_placeholder] as NSFastEnumeration)
            }) { success, error in
                completion?(success, error)
            }
        }
    }
    
    public static func saveImage(withImageURL ImageURL: URL, to album: PHAssetCollection, completion: ((_ success: Bool, _ error: Error?) -> ())? = nil){
//        print("saveImage: \(ImageURL)")
        DispatchQueue.main.async{
            PHPhotoLibrary.shared().performChanges({
                let assetRequest = PHAssetChangeRequest.creationRequestForAssetFromImage(atFileURL: ImageURL)
                let placeholder = assetRequest?.placeholderForCreatedAsset
                guard let _placeholder = placeholder else { completion?(false, nil); return; }
                
                let albumChangeRequest = PHAssetCollectionChangeRequest(for: album)
                albumChangeRequest?.addAssets([_placeholder] as NSFastEnumeration)
            }) { success, error in
                completion?(success, error)
            }
        }
    }
    
    /// Get PHAssetCollection with AlbumName(String)
    public static func fetchAssetCollectionForAlbum(_ albumName: String? = nil) -> PHAssetCollection? {
//        print("fetchAssetCollectionForAlbum: \(albumName?.description)")
        let fetchOptions = PHFetchOptions()
        fetchOptions.predicate = NSPredicate(format: "title = %@", albumName ?? defaultAlbumName)
        
        let collection = PHAssetCollection.fetchAssetCollections(with: .album, subtype: .any, options: fetchOptions)
        
        guard let albumCollection = collection.firstObject else {
            return nil
        }
        
        return albumCollection
    }
    
    
    public static func requestPhotoAuth(completion: @escaping () -> Void){
        PHPhotoLibrary.requestAuthorization { granted in
            DispatchQueue.main.async {
                if granted == .authorized {
                    completion()
                }
            }
        }
    }
 
}
