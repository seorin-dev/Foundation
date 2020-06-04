//
//  LinkImageGridViewModel.swift
//  FoundationProj
//
//  Created by baedy on 2020/06/04.
//  Copyright (c) 2020 baedy. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift
import RxFlow
import Action

class LinkImageGridViewModel: ViewModelType, Stepper {
    // MARK: - Stepper
    var steps = PublishRelay<Step>()
    let disposeBag = DisposeBag()
        
    // MARK: - Action
    lazy var linkRequestAction = Action<Void, [URL]>(workFactory: {_ in
        Observable.just(LinkRepository.getImageURL())
    })
    
    // MARK: - Property
    var linkList = PublishRelay<[URL]>()

    
    // MARK: - ViewModelType Protocol
    typealias ViewModel = LinkImageGridViewModel
    
    struct Input {
        let imageRequestTrigger: Observable<Void>
        let modelSelect: Observable<Int>
    }
    
    struct Output {
        let imageList: Observable<[URL]>
    }
    
    func transform(req: ViewModel.Input) -> ViewModel.Output {
        req.imageRequestTrigger.bind(to: linkRequestAction.inputs).disposed(by: disposeBag)
        
        linkRequestAction.elements.bind(to: linkList).disposed(by: disposeBag)
        
        Observable.combineLatest(req.modelSelect, linkList).map{ index, urls in
            return AppStep.linkImageZoom(urls, index)
        }.bind(to: steps).disposed(by: disposeBag)
        
        return Output(imageList: linkRequestAction.elements)
    }
}
