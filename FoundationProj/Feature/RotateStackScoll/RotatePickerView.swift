//
//  RotatePickerView.swift
//  FoundationProj
//
//  FOR U+ AR
//
//  Created by baedy on 2020/08/03.
//  Copyright © 2020 baedy. All rights reserved.
//

import UIKit

protocol RPDataSource: class {
    /// item count for first Section
    func rotateSSItemCount(_ rssView: RotatePickerView) -> Int
    /// item Image Name
    func rotateSSItemImage(_ rssView: RotatePickerView, item: Int, orient: NSLayoutConstraint.Axis) -> String
    /// item Size
    func rotateSSItemSize(_ rssView: RotatePickerView, item: Int, orient: UIDeviceOrientation) -> CGSize
}

protocol RPDelegate: class {
    func rotateSS(_ rssView: RotatePickerView, selectedItem item: Int)
}

class RotatePickerView: UIView {
    
    weak var dataSource: RPDataSource?
    weak var delegate: RPDelegate?
    
    lazy var scrollView = UIScrollView().then {
//        $0.alwaysBounceHorizontal = true
//        $0.alwaysBounceVertical =
        $0.isScrollEnabled = false
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.showsVerticalScrollIndicator = false
        $0.showsHorizontalScrollIndicator = false
        $0.contentInsetAdjustmentBehavior = .never
    }
        
    lazy var stackView = UIStackView().then {
        $0.axis = .horizontal
        $0.alignment = .center
        $0.distribution = .fillProportionally
        $0.spacing = 4
    }
    
    lazy var currentSelectItem = 0
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setuplayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // 데이터를 확실히 갱신하기위해 child 뷰들을 저장함
    lazy var stackSubViews: [RPImageButton] = []
    lazy var currentSelectedItem = 0
    var currentOrientation: UIDeviceOrientation = .portrait

    private func setuplayout() {
        self.translatesAutoresizingMaskIntoConstraints = false
        addSubview(scrollView)
        scrollView.addSubview(stackView)
        
        scrollView.snp.makeConstraints {
            $0.leading.trailing.bottom.top.equalToSuperview()
        }
        
        stackView.snp.makeConstraints {
            $0.leading.trailing.bottom.top.equalToSuperview()
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        selectedItem(currentSelectItem)
    }
    
    func reloadData(_ orientation: UIDeviceOrientation){
        self.currentOrientation = orientation
        // 기존의 뷰 제거 및 초기화
        stackSubViews.forEach {
            $0.removeFromSuperview()
        }
        stackSubViews = []
        
        guard let itemCount = dataSource?.rotateSSItemCount(self) else { return }
    
        let axix: NSLayoutConstraint.Axis = orientation.isPortrait ? .horizontal : .vertical
        self.stackView.axis = axix
//        scrollView.alwaysBounceHorizontal = orientation.isPortrait
//        scrollView.alwaysBounceVertical = !orientation.isPortrait
        
        var items = Array(0 ... itemCount - 1)
        
        if orientation.isLandscape{
            items = items.reversed()
        }
        
        items.compactMap{ item -> String? in dataSource?.rotateSSItemImage(self, item: item, orient: axix) }
        .map{ makeRSSImageButton(name: $0) }
            .enumerated().forEach{
                self.addingStackItem($0.element, $0.offset)
        }
        
        selectedItem(currentSelectItem)
    }
    
    func makeRSSImageButton(name: String) -> RPImageButton{
        RPImageButton().then{
            $0.setImage(withName: name)
        }
    }
    
    func addingStackItem(_ view: RPImageButton, _ index: Int){
        view.index = indexForOrientation(index)
        self.stackView.addArrangedSubview(view)
        self.stackSubViews.append(view)
        view.rx.tap.map{
            view.index
        }.subscribe(onNext: { [weak self] index in
            self?.selectedItem(index)
        }).disposed(by: view.rx.disposeBag)
    }
    
    func indexForOrientation(_ index: Int) -> Int{
        let totalCount = dataSource?.rotateSSItemCount(self) ?? 3
        return currentOrientation.isPortrait ? index : totalCount - 1 - index
    }

    func selectedItem(_ item: Int) {
        stackSubViews.forEach{ $0.isSelected = false }
        let orientItem = indexForOrientation(item)
        currentSelectItem = item
        stackSubViews[orientItem].isSelected = true
        scrollToIndex(item, orientation: self.currentOrientation, animated: true)
        delegate?.rotateSS(self, selectedItem: currentSelectItem)
    }
    
    func scrollToIndex(_ index: Int, orientation: UIDeviceOrientation ,animated: Bool){
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1
        ) { [weak self] in
            guard let `self` = self else { return }
            if let content = self.stackSubViews.get(self.indexForOrientation(index)){
                if orientation.isPortrait{
                    self.scrollView.setContentOffset(CGPoint(x: -(self.scrollView.frame.midX - content.frame.midX), y: 0), animated: animated)
                }else if orientation.isLandscape{
                    self.scrollView.setContentOffset(CGPoint(x: 0, y: -(self.scrollView.frame.midY - content.frame.midY)), animated: animated)
                }
            }
        }
    }
}
