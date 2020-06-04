//
//  CollectionMultiSelectionViewModel.swift
//  FondationProj
//
//  Created by baedy on 2020/05/07.
//  Copyright (c) 2020 baedy. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift
import RxFlow
import Photos
import Action

class CollectionMultiSelectionViewModel: ViewModelType, Stepper {
    // MARK: - Stepper
    var steps = PublishRelay<Step>()
    let disposeBag = DisposeBag()
    
    // MARK: - ViewModelType Protocol
    typealias ViewModel = CollectionMultiSelectionViewModel
    
    lazy var albumRequest = Action<Void, PHAssetCollection>(workFactory:{ _ in
        PHRepository.collection()
    })
    
    var album = PublishRelay<PHAssetCollection>()
    
    let mediaList = BehaviorRelay<[AssetType]>(value: [])
    var state: State!
    
    struct Input {
        let albumRequestTrigger: Observable<Void>
        let prefetchItems: Observable<[IndexPath]>
        let cancelPrefetchItems: Observable<[IndexPath]>
        let modelSelect: Observable<Int>
    }
    
    struct Output {
        let imageList: Observable<[AssetType]>
    }
    
    struct State {
        let viewLife: Observable<ViewLifeState>
    }
    
    func stateBind(state: ViewModel.State){
        self.state = state
        _ = state.viewLife.subscribe(onNext: {
            print("\($0)")
        })
        
//        state.viewLife.filter{
//            $0 == .viewDidAppear
//        }.map{ _ in
//            ()
//            }.bind(to: albumRequest.inputs).disposed(by: disposeBag)
    }
    
    func transform(req: ViewModel.Input) -> ViewModel.Output {
        
        albumRequest.elements.bind(to: album).disposed(by: disposeBag)
        
        req.albumRequestTrigger.bind(to: albumRequest.inputs).disposed(by: disposeBag)
        
//        Observable.combineLatest(req.prefetchItems, mediaList.asObservable()).map{ prefetch, media in
//            prefetch.map{
//                $0.item
//            }.compactMap{
//                media.get($0)?.getAsset
//            }
//        }.subscribe(onNext:PHRepository.startCaching(withPHAsset:)).disposed(by: disposeBag)
////
//        Observable.combineLatest(req.cancelPrefetchItems, mediaList.asObservable()).map{ prefetch, media in
//            prefetch.map{
//                $0.item
//            }.compactMap{
//                media.get($0)?.getAsset
//            }
//        }.subscribe(onNext:PHRepository.cancelCaching(withPHAsset:)).disposed(by: disposeBag)
        
        let dismiss = state.viewLife.filter{
            $0 == .viewDismiss
        }
        
        dismiss.map{ _ in }.subscribe(onNext:PHRepository.allStopCaching).disposed(by: disposeBag)
    
        Observable.combineLatest(dismiss, mediaList.asObservable()).map{ _, list in
            list.map{ $0.getAsset }
            }.subscribe(onNext: PHRepository.cancelCaching(withPHAsset:))
             .disposed(by: disposeBag)
              
        album.flatMap{
            Observable.just(($0, PHRepository.FetchOptions()))
        }.concatMap(PHRepository.getTypeAssetFromAlbum).bind(to: mediaList).disposed(by: disposeBag)
      
        
        req.modelSelect.subscribe(onNext:{
                print("\($0)")
            }).disposed(by: disposeBag)
        
        let assetList = mediaList.map{
            $0.map{
                $0.getAsset
            }
        }
        
        Observable.combineLatest(req.modelSelect, assetList).map{ index, assets in
            return AppStep.assetImageZoom(assets, index)
            }.bind(to: steps).disposed(by: disposeBag)
        
        return Output(imageList: mediaList.asObservable())
    }
    
    
}
