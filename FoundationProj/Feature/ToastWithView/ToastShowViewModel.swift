//
//  ToastShowViewModel.swift
//  FoundationProj
//
//  Created by baedy on 2020/08/26.
//  Copyright (c) 2020 baedy. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift
import RxFlow

class ToastShowViewModel: ViewModelType, Stepper {
    // MARK: - Stepper
    var steps = PublishRelay<Step>()
    
    // MARK: - ViewModelType Protocol
    typealias ViewModel = ToastShowViewModel
    
    let disposeBag = DisposeBag()
    let shutterCountComplete = PublishRelay<Void>()
    var shutterTimer: Timer?
    
    struct Input {
    }
    
    struct Output {
    }
    
    deinit {
        shutterTimer?.invalidate()
        shutterTimer = nil
        ViewToaster.default.animateStop()
    }
    
    func transform(req: ViewModel.Input) -> ViewModel.Output {
        shutterCountComplete.subscribe(onNext: {
            ViewToaster.default.animate(withType: .seeker(5))
        }).disposed(by: disposeBag)
        
        timer(10, self.shutterCountComplete)
        return Output()
    }
    
    func timer(_ count: Int, _ completeRelay: PublishRelay<Void>) {
        var addCount = 0
        ViewToaster.default.animate(withType: .label(count))
        shutterTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true, block: { timer in
            if addCount == count {
                timer.invalidate()
                completeRelay.accept(())
                return
            }
            ViewToaster.default.animate(withType: .label(count - addCount - 1))
            addCount += 1
        })
    }
}
