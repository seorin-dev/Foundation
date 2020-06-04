//
//  ViewBased.swift
//  FondationProj
//
//  Created by baedy on 2020/05/06.
//  Copyright © 2020 baedy. All rights reserved.
//

import Foundation
import RxSwift
import UIKit
import RxCocoa

protocol ViewBased {
    func setupLayout()
}

enum ViewLifeState{
    case viewDidLoad
    case viewWillAppear
    case viewDidAppear
    case viewWillDisAppear
    case viewDidDisAppear
    case viewDismiss
    case viewWillLayoutSubviews
    case viewDidLayoutSubviews
}

class UIBaseViewController: UIViewController {
    let viewState: PublishSubject<ViewLifeState> = PublishSubject<ViewLifeState>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        viewState.onNext(.viewDidLoad)
        self.view.backgroundColor = .white
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewState.onNext(.viewWillAppear)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        viewState.onNext(.viewDidAppear)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        viewState.onNext(.viewWillDisAppear)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        viewState.onNext(.viewDidDisAppear)
    }
    
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        viewState.onNext(.viewWillLayoutSubviews)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        viewState.onNext(.viewDidLayoutSubviews)
    }
    
    deinit {
        viewState.onNext(.viewDismiss)
    }

    override func present(_ viewControllerToPresent: UIViewController, animated flag: Bool, completion: (() -> Void)? = nil) {
       // overrideAnimation()
        super.present(viewControllerToPresent, animated: flag, completion: completion)
    }

    override func dismiss(animated flag: Bool, completion: (() -> Void)? = nil) {
        overrideAnimation()
        super.dismiss(animated: flag, completion: completion)
    }
}

extension UIBaseViewController {
    func overrideAnimation() {
        let transition = CATransition()
        transition.duration = 0.5
        transition.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        transition.type = .fade
        navigationController?.view.window?.layer.add(transition, forKey: nil)
    }
}

extension Reactive where Base: UIBaseViewController{
    var viewDidLoad: Observable<Void>{
        return base.viewState.asObserver().filter{ $0 == .viewDidLoad }.flatMap{ _ in Observable.empty()
        }
    }
    
    var viewWillAppear: Observable<Void>{
        return base.viewState.asObserver().filter{ $0 == .viewWillAppear }.flatMap{ _ in Observable.empty()
        }
    }
    
    var viewDidAppear: Observable<Void>{
        return base.viewState.asObserver().filter{ $0 == .viewDidAppear }.flatMap{ _ in
            Observable.empty()
        }
    }
}
