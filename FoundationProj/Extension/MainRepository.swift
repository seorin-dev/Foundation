//
//  MainRepository.swift
//  FondationProj
//
//  Created by baedy on 2020/05/06.
//  Copyright © 2020 baedy. All rights reserved.
//

import UIKit

struct MainRepository {
    static func mainList() -> [Screen]{
        [Screen.multiTable, Screen.multiCollection]
    }
}
