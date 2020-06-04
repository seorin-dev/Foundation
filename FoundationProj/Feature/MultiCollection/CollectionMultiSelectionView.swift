//
//  CollectionMultiSelectionView.swift
//  FondationProj
//
//  Created by baedy on 2020/05/07.
//  Copyright (c) 2020 baedy. All rights reserved.
//

import UIKit
import SnapKit
import Then
import RxSwift
import RxCocoa
import Photos

class CollectionMultiSelectionView: UIBasePreviewType {
    
    // MARK: - Model type implemente
    typealias Model = UIImage
    
    // MARK: - init
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupLayout()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - View
    
    let allbutton = UIButton().then{
        $0.isHidden = true
        $0.setTitleColor(.black, for: .normal)
        $0.setTitle("all select", for: .normal)
    }
    
    let deleteButton = UIButton().then{
        $0.setTitleColor(.black, for: .normal)
        $0.setTitle("delete", for: .normal)
    }
    
    let label = UILabel().then{
        $0.text = "no have image"
        $0.font = UIFont.systemFont(ofSize: 20)
        $0.textAlignment = .center
        $0.textColor = .black
    }
    
    lazy var collectionView = UICollectionView(frame: .zero, collectionViewLayout: makeCollectionViewLayout()).then{
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.showsHorizontalScrollIndicator = false
        $0.showsVerticalScrollIndicator = false
        $0.allowsMultipleSelection = false
        $0.isPrefetchingEnabled = true
        $0.register(cellType: MultiCollectionCell.self)
    }
    // MARK: - Outlets
    let disposeBag = DisposeBag()
    
    // MARK: - Methods
    func setupLayout() {
        
        self.addSubview(collectionView)
        self.addSubview(allbutton)
        self.addSubview(deleteButton)
                
        allbutton.snp.makeConstraints{
            $0.top.equalToSafeAreaAuto(self)
            $0.leading.equalToSafeAreaAuto(self)
            $0.height.equalTo(40)
            $0.width.equalTo(120)
        }
        
        deleteButton.snp.makeConstraints{
            $0.top.trailing.equalToSafeAreaAuto(self)
            $0.leading.equalTo(allbutton.snp.trailing)
            $0.height.equalTo(allbutton.snp.height)
        }
        
        collectionView.snp.makeConstraints{
            $0.top.equalTo(allbutton.snp.bottom)
            $0.bottom.leading.trailing.equalToSuperview()
        }
    }

    func setupDI(observable: Observable<[AssetType]>) {
        // model Dependency Injection
        Observable.combineLatest(observable, collectionView.rx.multiSelectionObserable).map({ list, bool in
            list.map{
                ($0, bool)
            }
        }).bind(to: collectionView.rx.items(cellIdentifier: MultiCollectionCell.reuseIdentifier, cellType: MultiCollectionCell.self)){ index, data, cell in
//            print("setupDI : \(data)")
            
            cell.setupDI(asset: data.0)
            cell.checkBox.isHidden = !data.1
            
        }.disposed(by: rx.disposeBag)
        
        observable.map{ results in
            results.count == 0
        }.bind(to: self.collectionView.rx.isHidden)
            .disposed(by: rx.disposeBag)
    }
    
    private func makeCollectionViewLayout() -> UICollectionViewLayout {
        let layout = UICollectionViewFlowLayout().then {
            $0.scrollDirection = .vertical
            $0.minimumLineSpacing = 15
            $0.minimumInteritemSpacing = 1
        }
        
        let cellWidth = Int(UIScreen.main.bounds.size.width - 2 * 15 - 20) / 3
        layout.itemSize = CGSize(width: cellWidth, height: cellWidth)
        layout.minimumLineSpacing = 15
        layout.sectionInset = UIEdgeInsets(top: 0,
                                           left: 10,
                                           bottom: 0,
                                           right: 10)
        
        return layout
    }
    
}


// MARK: - PreView
#if canImport(SwiftUI) && DEBUG
import SwiftUI

@available(iOS 13.0, *)
struct CollectionMultiSelection_Previews: PreviewProvider {
    static var previews: some View {
        //        Group {
        //            ForEach(UIView.previceSupportDevices, id: \.self) { deviceName in
        //                DebugPreviewView {
        //                    return CollectionMultiSelectionView()
        //                }.previewDevice(PreviewDevice(rawValue: deviceName))
        //                    .previewDisplayName(deviceName)
        //                    .previewLayout(.sizeThatFits)
        //            }
        //        }        
        Group {
            DebugPreviewView {
                let view = CollectionMultiSelectionView()
                //                .then {
                //                    $0.setupDI(observable: Observable.just([]))
                //                }
                return view
            }
        }
    }
}
#endif
