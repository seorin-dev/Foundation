//
//  HorizontalStackScrollViewController.swift
//  FoundationProj
//
//  Created by baedy on 2020/06/16.
//  Copyright (c) 2020 baedy. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import Reusable
import SnapKit
import Then

class HorizontalStackScrollViewController: UIBaseViewController, ViewModelProtocol {
    typealias ViewModel = HorizontalStackScrollViewModel
    
    // MARK: - ViewModelProtocol
    var viewModel: ViewModel!
    
    // MARK: - Properties
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        setupLayout()
        bindingViewModel()
        
        subView.hssView.refreshStackView()
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        self.subView.hssView.stackView.sizeToFit()
        self.subView.hssView.stackView.layoutIfNeeded()
    }
    
    // MARK: - Binding
    func bindingViewModel() {
        _ = viewModel.transform(req: ViewModel.Input())
    }
    
    // MARK: - View
    let subView = HorizontalStackScrollView()
    
    func setupLayout() {
        self.view.addSubview(subView)
        subView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
    
    // MARK: - Methods
    
}
