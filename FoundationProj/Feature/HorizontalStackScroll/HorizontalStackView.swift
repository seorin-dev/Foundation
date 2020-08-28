//
//  HorizontalStackView.swift
//  kids
//
//  Created by pineone on 2020/06/15.
//  Copyright © 2020 LG U+. All rights reserved.
//

import UIKit

class HorizontalStackView: UIView {
    
    let userDefaults = UserDefaults.standard
    let searchKey = "recentSearchWords"
    let betweenCells = 5 // 각 셀간의 간격
    
    // 검색어가 길어지면 가로로 스크롤 가능하게 하기위해 추가
    lazy var scrollView = UIScrollView().then {
        $0.alwaysBounceHorizontal = true
        $0.alwaysBounceVertical = false
        $0.isScrollEnabled = true
    }
        
    lazy var stackView = UIStackView().then {
        $0.axis = .horizontal
        $0.alignment = .center
        $0.distribution = .fillProportionally
        $0.spacing = CGFloat(betweenCells)
    }
    
    // 데이터를 확실히 갱신하기위해 child 뷰들을 저장함
    lazy var stackSubViews: [UIView] = []
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setuplayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    /// 스택뷰(자신)의 위치를 잡아줌
    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        guard nil != self.superview else { return }
        
        self.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }    
    }
    
    private func setuplayout() {
        addSubview(scrollView)
//        scrollView.addSubview(contentView)
        scrollView.addSubview(stackView)
        
//        scrollView.contentOffset = CGPoint(x: 0, y: 0)
        scrollView.snp.makeConstraints {
            $0.leading.trailing.bottom.top.equalToSuperview()
        }
        
//        contentView.snp.makeConstraints{
//            $0.leading.trailing.bottom.top.equalToSuperview()
//        }
//
//        contentView.addSubview(stackView)
        
        stackView.snp.makeConstraints {
            $0.leading.trailing.bottom.top.equalToSuperview()
        }
        
    }
    
    /// 최신 검색어를 새로 추가 및 제거할 때 (검색 OR 셀의 제거버튼)
    func refreshStackView() {
        // user Dafault 추가
        // stackview addArrangedSubview
        // stackSubViews property에도 추가 (...?? 무슨 말 일까)
        
        // 기존의 셀들 제거 및 초기화
        stackSubViews.forEach {
            $0.removeFromSuperview()
        }
        stackSubViews = []
        
        guard let arr = self.userDefaults.array(forKey: self.searchKey) else { return }
        
        for (index, title) in arr.enumerated() {
            let view = RecentItemView()
            
            view.itemTitleButton.setTitle(title as? String, for: .normal)
            view.setupConstraints() // 버튼의 가로 길이를 다 더해서 스택뷰의 길이를 구함
            
            stackView.addArrangedSubview(view)
            stackSubViews.append(view)
            
            view.itemTitleButton.tag = index
            view.itemTitleButton.addTarget(self, action: #selector(buttonTap), for: .touchUpInside)
            view.deleteButton.tag = index
            view.deleteButton.addTarget(self, action: #selector(removeView), for: .touchUpInside)
        }
        
        // 구한 셀길이 총 합에 각 셀의 간격을 더해줌
        stackView.layoutIfNeeded()
        stackView.sizeToFit()
        
        
        let contentWidth = self.stackView.frame.width
        let margin = (UIScreen.main.bounds.width - contentWidth) / 2
        
        if margin > 0 {
            DispatchQueue.main.async { [weak self] in
                guard let `self` = self else { return }
                self.scrollView.contentInset = UIEdgeInsets(top: 0, left: margin, bottom: 0, right: margin)
            }
        }
    }
    
    // actionComplete - title action return String
    var completeHandler: ((String) -> Void)?
    
    @objc func buttonTap(sender: UIButton) {
        guard let title = sender.title(for: .normal), let handler = completeHandler else { return }
        if var recentArray = userDefaults.array(forKey: self.searchKey) {
            recentArray.remove(at: sender.tag)
            userDefaults.set(recentArray, forKey: self.searchKey)
        }
        handler(title)
    }
    
    @objc func removeView(sender: UIButton) {
        if var recentArray = userDefaults.array(forKey: self.searchKey) {
            recentArray.remove(at: sender.tag)
            userDefaults.set(recentArray, forKey: self.searchKey)
        }
        self.refreshStackView()
    }
}
