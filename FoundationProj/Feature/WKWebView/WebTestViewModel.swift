//
//  WebTestViewModel.swift
//  FoundationProj
//
//  Created by baedy on 2020/07/03.
//  Copyright (c) 2020 baedy. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift
import RxFlow

class WebTestViewModel: ViewModelType, Stepper {
    // MARK: - Stepper
    var steps = PublishRelay<Step>()
    
    // MARK: - ViewModelType Protocol
    typealias ViewModel = WebTestViewModel
    
    struct Input {
    }
    
    struct Output {
    }
    
    func transform(req: ViewModel.Input) -> ViewModel.Output {
        return Output()
    }
}
