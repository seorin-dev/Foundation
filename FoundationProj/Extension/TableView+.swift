//
//  TableView+.swift
//  FondationProj
//
//  Created by baedy on 2020/04/29.
//  Copyright © 2020 baedy. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift

extension UITableView{
    @objc func selectItemAll(animated: Bool, scrollPosition: ScrollPosition){
        (0..<self.numberOfSections).forEach{ section in
            (0..<self.numberOfRows(inSection: section)).forEach{ item in
                self.selectRow(at: IndexPath(item: item, section: section), animated: animated, scrollPosition: scrollPosition)
            }
        }
    }
    
    @objc func deSelectItemAll(animated: Bool){
        (0..<self.numberOfSections).forEach{ section in
            (0..<self.numberOfRows(inSection: section)).forEach{ item in
                self.deselectRow(at: IndexPath(item: item, section: section), animated: animated)
            }
        }
    }
}

extension Reactive where Base : UITableView {
    var multiSelectionObserable: Observable<Bool>{
        return self.observe(Bool.self, "allowsMultipleSelection").compactMap{ $0 }
    }
    
    var allowMultipleSelection: RxCocoa.Binder<Bool> {
        return Binder(self.base) { view, selection in
            self.base.allowsMultipleSelection = selection
        }
    }
    
    var selectRows: Observable<[IndexPath]>{
        return delegate.methodInvoked(#selector(UITableViewDelegate.tableView(_:didSelectRowAt:)))
            .map { _ in
                guard let items = self.base.indexPathsForSelectedRows else{
                    return []
                }
                return items
        }
    }
}
