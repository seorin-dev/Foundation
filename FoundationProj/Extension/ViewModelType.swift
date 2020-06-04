//
//  ViewModelType.swift
//  FondationProj
//
//  Created by baedy on 2020/05/06.
//  Copyright © 2020 baedy. All rights reserved.
//

import Foundation

protocol ViewModelType: ViewModel {
    // ViewModel
    associatedtype ViewModel: ViewModelType

    // Input
    associatedtype Input

    // Output
    associatedtype Output

    func transform(req: ViewModel.Input) -> ViewModel.Output
}
