//
//  RotateViewController.swift
//  FoundationProj
//
//  Created by baedy on 2020/07/12.
//  Copyright (c) 2020 baedy. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import Reusable
import SnapKit
import Then

class RotateViewController: UIBaseViewController, ViewModelProtocol {
    typealias ViewModel = RotateViewModel
    
    // MARK: - ViewModelProtocol
    var viewModel: ViewModel!
    
    // MARK: - Properties
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        setupLayout()
        bindingViewModel()
    }
    
    // MARK: - Binding
    func bindingViewModel() {
        let res = viewModel.transform(req: ViewModel.Input())
        
        subView.setupDI(observable: res.orientation)
    }
    
    // MARK: - View
    let subView = RotateView()
    
    func setupLayout() {
        self.view.addSubview(subView)
        subView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
    
    // MARK: - Methods
    
}
