//
//  MainViewController.swift
//  FondationProj
//
//  Created by baedy on 2020/05/06.
//  Copyright (c) 2020 baedy. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import Reusable
import SnapKit
import Then

class MainViewController: UIBaseViewController, ViewModelProtocol {
    typealias ViewModel = MainViewModel
    
    // MARK: - ViewModelProtocol
    var viewModel: ViewModel!
    
    // MARK: - Properties
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        setupLayout()
        bindingViewModel()
        stateBind()        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
    }
    
    // MARK: - Binding
    func stateBind(){
        viewModel.stateBind(state: ViewModel.State(viewLife: self.viewState))
    }
    
    func bindingViewModel() {
        let res = viewModel.transform(req: ViewModel.Input(selectItem: subView.table.rx.modelSelected(Screen.self).asObservable()))
        subView.setupDI(observable: res.itemList)
        
        print("binding complete")
    }
    
    // MARK: - View
    let subView = MainView()
    
    func setupLayout() {
        self.view.addSubview(subView)
        subView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
    
    // MARK: - Methods
}
