//
//  CollectionView+.swift
//  FondationProj
//
//  Created by baedy on 2020/04/29.
//  Copyright © 2020 baedy. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

extension UICollectionView{
    
    @objc func selectItemAll(animated: Bool, scrollPosition: ScrollPosition){
        (0..<self.numberOfSections).forEach{ section in
            (0..<self.numberOfItems(inSection: section)).forEach{ item in
                self.selectItem(at: IndexPath(item: item, section: section), animated: animated, scrollPosition: scrollPosition)
            }
        }
    }
    
    @objc func deSelectItemAll(animated: Bool){
        (0..<self.numberOfSections).forEach{ section in
            (0..<self.numberOfItems(inSection: section)).forEach{ item in
                self.deselectItem(at: IndexPath(item: item, section: section), animated: animated)
            }
        }
    }
}

extension Reactive where Base : UICollectionView {
    
    var reloaded: Observable<()> {
        let reloadData = sentMessage(#selector(base.reloadData))
        return Observable.create { observer in
            let reloadDataDisposable = reloadData.subscribe(onNext: { _ in
                DispatchQueue.main.async {
                    observer.on(.next(()))
                }
            })
            return Disposables.create([reloadDataDisposable])
        }
    }
    var multiSelectionObserable: Observable<Bool>{
        return self.observe(Bool.self, "allowsMultipleSelection").compactMap{ $0 }
    }
    
    var allowMultipleSelection: RxCocoa.Binder<Bool> {
        return Binder(self.base) { view, selection in
            self.base.allowsMultipleSelection = selection
        }
    }
    
    var itemDeselect: Observable<[Any]>{
        return delegate
            .methodInvoked(#selector(UICollectionViewDelegate.collectionView(_:didDeselectItemAt:)))
    }
    
    var itemselect: Observable<[Any]>{
           return delegate
               .methodInvoked(#selector(UICollectionViewDelegate.collectionView(_:didSelectItemAt:)))
           
       }
    
    var selectItems: Observable<[IndexPath]>{
        let itemSelected = delegate
            .methodInvoked(#selector(UICollectionViewDelegate.collectionView(_:didSelectItemAt:)))
        let itemDeselected = delegate
        .methodInvoked(#selector(UICollectionViewDelegate.collectionView(_:didDeselectItemAt:)))
          
        return Observable.of(itemSelected, itemDeselected)
            .merge()
            .flatMap { Observable.just($0[0] as? UICollectionView) }
            .flatMap { Observable.just($0?.indexPathsForSelectedItems ?? []) }
            .filter{$0.count != 0}
            .map{
                $0.sorted()
        }
    }
}
