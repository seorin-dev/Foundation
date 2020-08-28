//
//  RotateViewModel.swift
//  FoundationProj
//
//  Created by baedy on 2020/07/12.
//  Copyright (c) 2020 baedy. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift
import RxFlow

class RotateViewModel: ViewModelType, Stepper {
    // MARK: - Stepper
    var steps = PublishRelay<Step>()
    
    // MARK: - ViewModelType Protocol
    typealias ViewModel = RotateViewModel
    
    struct Input {
    }
    
    struct Output {
        let orientation: Observable<UIDeviceOrientation>
    }
    
    func transform(req: ViewModel.Input) -> ViewModel.Output {
        
        return Output(orientation: DeviceOrientationHelper.shared.rx.currentOrientation)
    }
}
