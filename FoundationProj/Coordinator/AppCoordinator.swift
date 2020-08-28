//
//  AppCoordinator.swift
//  FondationProj
//
//  Created by baedy on 2020/05/06.
//  Copyright © 2020 baedy. All rights reserved.
//

import Foundation
import RxCocoa
import RxFlow
import RxSwift
import UIKit

class AppCoordinator: NSObject {
    public static let shared = AppCoordinator()
    fileprivate let coordinator = FlowCoordinator()
    fileprivate var disposeBag = DisposeBag()
    
    fileprivate lazy var initialFlow = {
        return InitFlow.shared
    }()
    
    func start(inWindow window: UIWindow, flow: Flow? = nil) {
        
        
//        let vc = ProfileViewController()
//
//        window.rootViewController = vc
//        window.makeKeyAndVisible()
        
        let mainFlow = initialFlow
        Flows.whenReady(flow1: mainFlow) { root in
            window.rootViewController = root
            window.makeKeyAndVisible()
        }
        
        coordinator.coordinate(flow: mainFlow, with: AppStepper.shared)
        
        coordinator.rx.didNavigate.subscribe(onNext: { flow, step in
            print("did navigate to flow=\(flow) and step=\(step)")
        }).disposed(by: self.disposeBag)
        
        coordinator.rx.willNavigate.subscribe(onNext: { flow, step in
            Log.d("@@@ did willNavigate to flow=\(flow) and step=\(step)")
        }).disposed(by: self.disposeBag)
        
    }
}
