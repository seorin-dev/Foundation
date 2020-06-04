//
//  InitFlow.swift
//  FondationProj
//
//  Created by baedy on 2020/05/06.
//  Copyright © 2020 baedy. All rights reserved.
//

import RxFlow
import UIKit
import Then
import RxSwift
import RxCocoa

class InitFlow: Flow {
    static let `shared`: InitFlow = InitFlow()

    var root: Presentable{
        return self.rootViewController
    }
    
    private lazy var rootViewController = UINavigationController().then {
          $0.setNavigationBarHidden(false, animated: false)
      }
    
    func navigate(to step: Step) -> FlowContributors {
        guard let step = step as? AppStep else {
            return .none
        }
        
        switch step {
        case .initialize:
            return navigateToMain()
        case .multiSelectTable:
            return navigateToMultiTable()
        case .multiSelectCollection:
            return navigateToMultiCollection()
        case .linkCollection:
            return navigateToLinkImageCollection()
        case .linkImageZoom(let urls, let index):
            return modalShowImageSlider(withItems: urls, initialIndex: index)
        case .modalClose:
            return modalDismiss()
        case .assetImageZoom(let aseets, let index):
            return modalShowImageSlider(withItems: aseets, initialIndex: index)
        default:
            return .none
        }
    }
}

extension InitFlow{
    private func navigateToMultiTable() -> FlowContributors{
        FlowSugar(TableMultiSelectionViewModel(), TableMultiSelectionViewController.self)
            .navigationItem(with:{
                $0.title = "multiSelectTable"
            }).oneStepPushBy(self.rootViewController)
    }
    
    private func navigateToMultiCollection() -> FlowContributors{
         FlowSugar(CollectionMultiSelectionViewModel(), CollectionMultiSelectionViewController.self)
             .navigationItem(with:{
                 $0.title = "multiSelectCollection"
             }).oneStepPushBy(self.rootViewController)
     }
    
    private func navigateToLinkImageCollection() -> FlowContributors{
        FlowSugar(LinkImageGridViewModel(), LinkImageGridViewController.self)
            .navigationItem(with:{
                $0.title = "LinkImageGrid"
            })
            .oneStepPushBy(self.rootViewController)
    }
    
    private func modalShowImageSlider<T>(withItems items: [T], initialIndex: Int) -> FlowContributors{
        
        FlowSugar(PhotoZoomViewModel(items, initialIndex), PhotoZoomViewController<T>.self)
            .setVCProperty(viewControllerBlock:{
                
                self.rootViewController.delegate = $0.transitionController
                $0.transitionController.animator.currentIndex = initialIndex
                                
                if let parentVC = UIApplication.shared.topViewController as? CollectionMultiSelectionViewController {
                    parentVC.zoomIndexDelegate = $0
                    $0.transitionController.fromDelegate = parentVC
                }
                if let parentVC = UIApplication.shared.topViewController as? LinkImageGridViewController {
                    parentVC.zoomIndexDelegate = $0
                    $0.transitionController.fromDelegate = parentVC
                }
                
                $0.transitionController.toDelegate = $0
            })
            .oneStepPushBy(self.rootViewController)
    }
    
    private func modalDismiss() -> FlowContributors{
        rootViewController.popViewController(animated: true)
        return .none
    }
     
    private func navigateToMain() -> FlowContributors{
        FlowSugar(MainViewModel(), MainViewController.self)
            .navigationItem(with: {
                $0.title = "Fondation"
            })
            .oneStepPushBy(self.rootViewController)
    }
}
