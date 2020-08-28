//
//  HorizontalStackScrollViewModel.swift
//  FoundationProj
//
//  Created by baedy on 2020/06/16.
//  Copyright (c) 2020 baedy. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift
import RxFlow

class HorizontalStackScrollViewModel: ViewModelType, Stepper {
    // MARK: - Stepper
    var steps = PublishRelay<Step>()
    
    let userDefaults = UserDefaults.standard
    
    // MARK: - ViewModelType Protocol
    typealias ViewModel = HorizontalStackScrollViewModel
    
    struct Input {
    }
    
    struct Output {
    }
    
    func transform(req: ViewModel.Input) -> ViewModel.Output {
        let recentArray = ["안녕하세요", "저는", "iOS", "개발자", "입니다"]
        
        userDefaults.set(recentArray, forKey: "recentSearchWords")
        
        return Output()
    }
}
