//
//  MainViewModel.swift
//  FondationProj
//
//  Created by baedy on 2020/05/06.
//  Copyright (c) 2020 baedy. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift
import RxFlow
import Action

class MainViewModel: ViewModelType, Stepper {
    // MARK: - Stepper
    var steps = PublishRelay<Step>()
    
    let disposeBag = DisposeBag()
    
    let loadAction: Action<ViewLifeState, [Screen]> = Action(workFactory:{ _ in
        return Observable.just(MainRepository.mainList())
    })
    
    // MARK: - ViewModelType Protocol
    typealias ViewModel = MainViewModel
    
    struct Input {
        let selectItem: Observable<Screen>
    }
    
    struct Output {
        let itemList: Observable<[Screen]>
    }
    
    struct State {
        let viewLife: Observable<ViewLifeState>
//        let isHidden: Observable<Bool>
    }
    
    func stateBind(state: ViewModel.State){
        _ = state.viewLife.subscribe(onNext: {
            print("Main ------ \($0)")
        })
        
        state.viewLife.filter{$0 == .viewDidAppear}.bind(to: loadAction.inputs).disposed(by: disposeBag)
    }
    
    func transform(req: ViewModel.Input) -> ViewModel.Output {
        
        req.selectItem.subscribe(onNext: self.emitStep(_:)).disposed(by: disposeBag)
        
        return Output(itemList: loadAction.elements)
    }
    
    func emitStep(_ screen: Screen){
        switch screen {
        case .multiTable:
            self.steps.accept(AppStep.multiSelectTable)
        case .multiCollection:
            self.steps.accept(AppStep.multiSelectCollection)
        case .linkCollection:
            self.steps.accept(AppStep.linkCollection)
        }
    }
}


