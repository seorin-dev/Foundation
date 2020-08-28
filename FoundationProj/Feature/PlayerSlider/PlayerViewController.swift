//
//  PlayerViewController.swift
//  FoundationProj
//
//  Created by baedy on 2020/07/15.
//  Copyright (c) 2020 baedy. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import Reusable
import SnapKit
import Then

class PlayerViewController: UIBaseViewController, ViewModelProtocol {
    typealias ViewModel = PlayerViewModel
    
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
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
//        let margin: CGFloat = 20.0
//        let width = view.bounds.width - 2.0 * margin
//        self.subView.sliderView.frame = CGRect(x: margin, y: margin + topLayoutGuide.length + 170, width: width, height: 31.0)
    }
    
    // MARK: - Binding
    func bindingViewModel() {
        let res = viewModel.transform(req: ViewModel.Input())
        
        subView.setupDI(observable: res.orientation)
    }
    
    // MARK: - View
    let subView = PlayerView()
    
    func setupLayout() {
        self.view.addSubview(subView)
        subView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
    
    // MARK: - Methods
    
}
