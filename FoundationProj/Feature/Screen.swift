
//
//  Screen.swift
//  FondationProj
//
//  Created by baedy on 2020/05/06.
//  Copyright © 2020 baedy. All rights reserved.
//

import Foundation

enum Screen {
    case multiTable
    case multiCollection
    case linkCollection
    
    func getTitle() -> String{
        switch self {
        case .multiTable:
            return "Table Multi Select"
        case .multiCollection:
            return "Collection Multi Select"
        case .linkCollection:
            return "link Image Collection"
        }
    }
}
