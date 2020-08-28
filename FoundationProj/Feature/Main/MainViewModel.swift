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
import CoreTelephony

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
        _ = state.viewLife.subscribe(onNext: { _ in
//            print("Main ------ \($0)")
        })
        
        state.viewLife.filter{$0 == .viewDidAppear}.bind(to: loadAction.inputs).disposed(by: disposeBag)
    }
    
    func transform(req: ViewModel.Input) -> ViewModel.Output {
        
        req.selectItem.map(emitStep(_:))
            .bind(to: self.steps)
            .disposed(by: disposeBag)
        
        return Output(itemList: loadAction.elements)
    }
    
    func emitStep(_ screen: Screen) -> AppStep{
        switch screen {
        case .multiTable:
            return .multiSelectTable
        case .multiCollection:
            return .multiSelectCollection
        case .linkCollection:
            return .linkCollection
        case .horizontalStackScroll:
            return .horizontalStackScroll
        case .webTest:
            return .webSchemeTest
        case .rotateView:
            return .rotate
        case .playerSlider:
            return .playerSlider
        case .rotateStackScroll:
            return .rotateStackScroll
        case .filterSlider:
            return .filterSlider
        case .toastWithView:
            return .toastWithView
        }
    }
}


