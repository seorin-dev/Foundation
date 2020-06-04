//
//  UIKitPreView+.swift
//  FondationProj
//
//  Created by baedy on 2020/05/06.
//  Copyright © 2020 baedy. All rights reserved.
//

import Foundation
import RxCocoa
import RxSwift
import SnapKit
import Then
//import UIKit

#if canImport(SwiftUI) && DEBUG
import SwiftUI

@available(iOS 10.0, *)
struct DebugPreviewView<T: UIView>: UIViewRepresentable {
    let view: UIView

    init(_ builder: @escaping () -> T) {
        view = builder()
    }

    func makeUIView(context: Context) -> UIView {
        return view
    }

    func updateUIView(_ view: UIView, context: Context) {
        view.setContentHuggingPriority(.defaultHigh, for: .vertical)
        view.setContentHuggingPriority(.defaultHigh, for: .horizontal)
    }
}
#endif

extension UIView {
    static var previceSupportDevices: [String] {
        get {
            let deviceNames: [String] = [
                "iPhone SE",
                "iPhone 7",
                "iPhone X",
                "iPhone XS Max"
            ]
            return deviceNames
        }
    }
}

class BaseView: UIView {
}

public protocol UIBasePreview {
    associatedtype Model
    typealias Models = [Model]

//    var model: Observable<Model>? { get set }
    func mapper(element: Self.Model, with view: AnyObject?)
    //func setupDI(observable: Observable<Self.Models>)
}

extension UIBasePreview {
    //func mapper(element: Self.Model, with view: AnyObject?) {}
    func mapper(element: Self.Model, with view: AnyObject? = nil) {
        mapper(element: element, with: view)
    }
}

extension UIBasePreview {
    func setupDI(observable: Observable<Self.Model>) {}
    func setupDI(observable: Observable<Self.Models>) {}
    func setupDI(observable: BehaviorRelay<Self.Models>) {}

    @discardableResult
    func setupDI<T>(observable: Observable<[T]>) -> Self { return self }
    @discardableResult
    func setupDI<T>(generic: PublishRelay<T>) -> Self { return self }

}

typealias UIBasePreviewType = BaseView & UIBasePreview

struct EmptyModel: Decodable {}
