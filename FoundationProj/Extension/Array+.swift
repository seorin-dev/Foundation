//
//  Array+.swift
//  FoundationProj
//
//  Created by baedy on 2020/05/28.
//  Copyright © 2020 baedy. All rights reserved.
//

import UIKit

extension Array {
    func get(_ index: Int) -> Element? {
        if 0 <= index && index < count {
            return self[index]
        } else {
            return nil
        }
    }
}
