//
//  FilterSliderViewController.swift
//  FoundationProj
//
//  Created by baedy on 2020/08/19.
//  Copyright (c) 2020 baedy. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import Reusable
import SnapKit
import Then

class FilterSliderViewController: UIBaseViewController, ViewModelProtocol {
    typealias ViewModel = FilterSliderViewModel
    
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
        _ = viewModel.transform(req: ViewModel.Input())
    }
    
    // MARK: - View
    let subView = FilterSliderView()
    
    func setupLayout() {
        self.view.addSubview(subView)
        subView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
    
    // MARK: - Methods
    
}
