//
//  LinkImageGridView.swift
//  FoundationProj
//
//  Created by baedy on 2020/06/04.
//  Copyright (c) 2020 baedy. All rights reserved.
//

import UIKit
import SnapKit
import Then
import RxSwift
import RxCocoa

class LinkImageGridView: UIBasePreviewType {
    
    // MARK: - Model type implemente
    typealias Model = URL
    
    // MARK: - init
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupLayout()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - View
    lazy var label = UILabel().then {
        $0.text = "LinkImageGrid View"
        $0.textColor = .red
    }
    
    lazy var collectionView = UICollectionView(frame: .zero, collectionViewLayout: makeCollectionViewLayout()).then{
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.showsHorizontalScrollIndicator = false
        $0.showsVerticalScrollIndicator = false
        $0.allowsMultipleSelection = false
        $0.isPrefetchingEnabled = true
        $0.register(cellType: LinkImageCell.self)
    }
    
    // MARK: - Methods
    func setupLayout() {
        self.addSubview(collectionView)
        collectionView.snp.makeConstraints{
            $0.top.bottom.leading.trailing.equalToSuperview()
           }
    }
    
    func setupDI(observable: Observable<[Model]>) {
        // model Dependency Injection
        observable.bind(to: collectionView.rx.items(cellIdentifier: LinkImageCell.reuseIdentifier, cellType: LinkImageCell.self)){ index, data, cell in
            cell.mapping(url: data)
        }.disposed(by: rx.disposeBag)
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
struct LinkImageGrid_Previews: PreviewProvider {
    static var previews: some View {
        //        Group {
        //            ForEach(UIView.previceSupportDevices, id: \.self) { deviceName in
        //                DebugPreviewView {
        //                    return LinkImageGridView()
        //                }.previewDevice(PreviewDevice(rawValue: deviceName))
        //                    .previewDisplayName(deviceName)
        //                    .previewLayout(.sizeThatFits)
        //            }
        //        }        
        Group {
            DebugPreviewView {
                let view = LinkImageGridView()
                //                .then {
                //                    $0.setupDI(observable: Observable.just([]))
                //                }
                return view
            }
        }
    }
}
#endif
