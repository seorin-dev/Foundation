//
//  ZoomingViewModel.swift
//  FoundationProj
//
//  Created by baedy on 2020/05/12.
//  Copyright (c) 2020 baedy. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift
import RxFlow
import Photos

// init - data sequence, current index
// input - image sequence, init index(once)
// output - close Action, transIndex, (added - shard, delete action)

class ZoomingViewModel<T>: ViewModelType, Stepper {
    enum ActionTrigger{
        case close
    }
    
    // MARK: - Stepper
    var steps = PublishRelay<Step>()
    
    // MARK: - Property
    let sequence = BehaviorRelay<[T]>(value: [])
    let initialIndex: Int!
    let disposeBag = DisposeBag()
    
    // MARK: - init
    init(_ items: [T], _ initialIndex: Int) {
        self.sequence.accept(items)
        self.initialIndex = initialIndex
    }
    
    // MARK: - ViewModelType Protocol
    typealias ViewModel = ZoomingViewModel
    
    struct Input {
        let actionTrigger: Observable<ActionTrigger>
        let transIndex: Observable<Int>
        let cancel: Observable<[IndexPath]>
    }
    
    struct Output {
        let inputSequence: Driver<[T]>
        let initalIndex: Int
    }
    
    func transform(req: ViewModel.Input) -> ViewModel.Output {
        req.actionTrigger.subscribe(onNext: actionExe).disposed(by: disposeBag)
        Observable.combineLatest(req.cancel, sequence).filter{
            $0.1.self is [PHAsset]
        }.map{ indexPaths, asset in
            (indexPaths.map{
                $0.item
            }, asset as! [PHAsset])
        }.map{ items, assets in
            items.compactMap{
                assets.get($0)
            }
        }.subscribe(onNext: PHRepository.cancelCaching(withPHAsset:)).disposed(by: disposeBag)
        
        return Output(inputSequence: sequence.asDriver(), initalIndex: initialIndex)
    }
    
    func actionExe(action: ActionTrigger){
        switch action {
        case .close:
            self.steps.accept(AppStep.close)
        }
    }
}
