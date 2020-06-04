//
//  CheckBox.swift
//  FoundationProj
//
//  Created by baedy on 2020/05/07.
//  Copyright © 2020 baedy. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

@IBDesignable
class CheckBox: UIControl {
    @IBInspectable
    var offImage: UIImage? {
        didSet {
            if !isSelected {
                imageView.image = offImage
            }
        }
    }

    @IBInspectable
    var onImage: UIImage? {
        didSet {
            if isSelected {
                imageView.image = onImage
            }
        }
    }

    @IBInspectable
    var isChecked: Bool {
        get { return isSelected }
        set { isSelected = newValue }
    }

    override var isSelected: Bool {
        didSet {
            if isEnabled {
                imageView.image = isSelected ? onImage : offImage
            } else {
                imageView.image = isSelected ? #imageLiteral(resourceName: "mr_btn_checkbox_on") : #imageLiteral(resourceName: "cm_btn_checkbox_off")
            }
        }
    }

    override var isEnabled: Bool {
        didSet {
            if isChecked {
                imageView.image = isEnabled ? onImage : #imageLiteral(resourceName: "mr_btn_checkbox_on")
            } else {
                imageView.image = isEnabled ? offImage : #imageLiteral(resourceName: "cm_btn_checkbox_off")
            }
        }
    }

    private let imageView = UIImageView()

    override func didMoveToWindow() {
        super.didMoveToWindow()
        addSubview(imageView)

        imageView.snp.makeConstraints {
            $0.center.equalToSuperview()
        }

        addTarget(self, action: #selector(handleTap), for: .touchUpInside)
        addTarget(self, action: #selector(handlePress), for: .touchDown)
    }

    override var intrinsicContentSize: CGSize {
        return onImage?.size ?? .zero
    }

    @objc
    private func handleTap() {
        isSelected.toggle()
        sendActions(for: .valueChanged)
    }

    @objc
    private func handlePress() {
        if isSelected {
            self.imageView.image = #imageLiteral(resourceName: "mr_btn_checkbox_on")
        } else {
            self.imageView.image = #imageLiteral(resourceName: "cm_btn_checkbox_off")
        }
    }
}

extension Reactive where Base: CheckBox {
    var valueChanged: ControlEvent<Bool> {
        let valueChanged = controlEvent(.valueChanged)
        let source = Observable<Bool>.create { [weak control = base] observer in
            let event = valueChanged.subscribe(onNext: {
                guard let isChecked = control?.isChecked else {
                    return
                }
                observer.on(.next(isChecked))
            })
            return Disposables.create {
                event.dispose()
            }
        }
        return ControlEvent(events: source)
    }
    
    var isHidden: RxCocoa.Binder<Bool> {
        return Binder(self.base) { view, hidden in
            self.base.isHidden = hidden
        }
    }
}
