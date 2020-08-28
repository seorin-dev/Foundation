//
//  RSSImageButton.swift
//  FoundationProj
//
//  Created by baedy on 2020/08/03.
//  Copyright © 2020 baedy. All rights reserved.
//

import UIKit

class RPImageButton: UIButton {
    
    var index: Int!
    
    func setImage(withName name: String?) {
        let defaultName = "\(name ?? "")"
        self.setImage(UIImage(named: "\(defaultName)Nor"), for: .normal)
        self.setImage(UIImage(named: "\(defaultName)Sel"), for: .selected)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
