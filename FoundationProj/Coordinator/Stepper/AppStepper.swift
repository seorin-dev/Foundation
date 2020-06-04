//
//  AppStepper.swift
//  FondationProj
//
//  Created by baedy on 2020/05/06.
//  Copyright © 2020 baedy. All rights reserved.
//

import Foundation
import RxCocoa
import RxFlow

class AppStepper: Stepper {
    static let shared = AppStepper()
    
    var steps = PublishRelay<Step>()
    
    var initialStep: Step {
        AppStep.initialize
    }
    
    func readyToEmitSteps() {
    }
}
