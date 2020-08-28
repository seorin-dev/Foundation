//
//  RecentItemView.swift
//  kids
//
//  Created by pineone on 2020/06/13.
//  Copyright © 2020 LG U+. All rights reserved.
//

import UIKit

//enum RecentItemAction {
//    case title(Int)
//    case delete(Int)
//}

/// 폰트가 적용 된 String의 길이를 반환
extension String {
    func widthOfString(usingFont font: UIFont) -> CGFloat {
        let fontAttributes = [NSAttributedString.Key.font: font]
        let size = self.size(withAttributes: fontAttributes)
        return size.width
    }
}

class RecentItemView: UIView {
    
    let betweenOffset = 5
    
    let deleteButton = UIButton().then {
        $0.setTitle("X", for: .normal)
    }
    
    let itemTitleButton = UIButton()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupLayout() {
        self.backgroundColor = .orange
        self.translatesAutoresizingMaskIntoConstraints = false
        
        self.addSubview(itemTitleButton)
        self.addSubview(deleteButton)
    }
    
    /// 버튼의 가로 길이를 반환
    func setupConstraints() {
        
        self.layer.cornerRadius = 10
        
        itemTitleButton.snp.removeConstraints()
        deleteButton.snp.removeConstraints()
        
        itemTitleButton.snp.makeConstraints {
            $0.top.bottom.equalToSuperview()
            $0.leading.equalTo(10)
        }
        
        deleteButton.snp.makeConstraints {
            $0.bottom.top.trailing.equalToSuperview()
            $0.leading.equalTo(itemTitleButton.snp.trailing).offset(betweenOffset)
        }
    }
}
