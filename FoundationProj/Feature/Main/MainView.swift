//
//  MainView.swift
//  FondationProj
//
//  Created by baedy on 2020/05/06.
//  Copyright (c) 2020 baedy. All rights reserved.
//

import UIKit
import SnapKit
import Then
import RxSwift
import RxCocoa
import Reusable
import NSObject_Rx

class MainView: UIBasePreviewType {
    
    // MARK: - Model type implemente
    typealias Model = Screen
    
    // MARK: - init
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupLayout()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    // MARK: - Outlets
    let table = UITableView().then{
        $0.register(cellType: MainCell.self)
        $0.rowHeight = 55
    }
    
    lazy var refreshControl = CustomRefreshControl(lottie: nil)

    // MARK: - Methods
    func setupLayout() {
        table.refreshControl = refreshControl
        table.delegate = self // or table.delegate = refreshControl
        
        refreshControl.rx.refreshTrigger.subscribe(onNext: {
            _ in self.refreshControl.endRefresh()
        }).disposed(by: rx.disposeBag)
        
        self.addSubview(table)
        table.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        
    }
    
    func setupDI(observable: Observable<[Model]>) {
        // model Dependency Injection
        observable.bind(to: table.rx.items(cellIdentifier: MainCell.reuseIdentifier, cellType: MainCell.self)){
            index, data, cell in
            cell.label.text = data.getTitle()
        }.disposed(by: rx.disposeBag)
        
    }
}

extension MainView: UIScrollViewDelegate, UITableViewDelegate{
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        refreshControl.scrollViewDidScroll(scrollView)
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        refreshControl.scrollViewDidEndDragging(scrollView, willDecelerate: decelerate)
    }
}


// MARK: - PreView
#if canImport(SwiftUI) && DEBUG
import SwiftUI

@available(iOS 13.0, *)
struct Main_Previews: PreviewProvider {
    static var previews: some View {
        //        Group {
        //            ForEach(UIView.previceSupportDevices, id: \.self) { deviceName in
        //                DebugPreviewView {
        //                    return MainView()
        //                }.previewDevice(PreviewDevice(rawValue: deviceName))
        //                    .previewDisplayName(deviceName)
        //                    .previewLayout(.sizeThatFits)
        //            }
        //        }        
        Group {
            DebugPreviewView {
                let view = MainView()
                //                .then {
                //                    $0.setupDI(observable: Observable.just([]))
                //                }
                return view
            }
        }
    }
}
#endif
