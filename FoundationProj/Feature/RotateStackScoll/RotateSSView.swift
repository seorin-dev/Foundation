//
//  RotateSSView.swift
//  FoundationProj
//
//  Created by baedy on 2020/08/03.
//  Copyright (c) 2020 baedy. All rights reserved.
//

import UIKit
import SnapKit
import Then
import RxSwift
import RxCocoa

class RotateSSView: UIBasePreviewType {
    
    // MARK: - Model type implemente
    typealias Model = Void
    
    // MARK: - init
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupLayout()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - View
    lazy var bottomContainerView = UIView().then{
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0.7)
    }
    /// 비디오, 움짤, 사진 시작 버튼
    lazy var captureButton = UIButton().then {
        $0.setImage(#imageLiteral(resourceName: "btnVideoOff"), for: .normal)
        $0.setImage(#imageLiteral(resourceName: "btnVideoOn"), for: .selected)
        $0.setImage(#imageLiteral(resourceName: "btnVideoOn"), for: [.selected, .highlighted])
    }
    
    lazy var pickerView = RotatePickerView().then{
        $0.dataSource = self
        $0.delegate = self
    }
    
    // MARK: - Rx
    
    func setupDI(deviceOrientation: Observable<UIDeviceOrientation>) {
        deviceOrientation.skip(1).subscribe(onNext: { [weak self] ori in
            guard let `self` = self else { return }
            self.rotateLayout(ori)
        }).disposed(by: rx.disposeBag)
    }

    // MARK: - Outlets
    let borderButtonImageNamed = ["btnTapVideo", "btnTapGif", "btnTapPhoto"]
    
    // MARK: - layout's constraints
    var portraitConstraints: [Constraint] = []
    var landscapeConstraints: [Constraint] = []
    
    // MARK: - Methods
    func setupLayout() {
        self.addSubview(bottomContainerView)
        
        bottomContainerView.snp.makeConstraints { [unowned self] in
            $0.trailing.equalToSuperview()
            
            let ptHeight = $0.height.equalTo(144).constraint
            let ptBottom = $0.bottom.equalToSuperview().constraint
            let ptLead = $0.leading.equalToSuperview().constraint
            self.portraitConstraints.append(contentsOf: [ptHeight, ptBottom, ptLead])
            
            let lrWidth = $0.width.equalTo(120).priority(.medium).constraint
            let lrBottom = $0.bottom.equalToSuperview().priority(.medium).constraint
            let lrTop = $0.top.equalToSuperview().priority(.medium).constraint
            
            self.addToLandConstraint([lrWidth, lrBottom, lrTop])
        }
        bottomContainerView.addSubviews([captureButton, pickerView])
        
        captureButton.snp.makeConstraints {[unowned self] in
            $0.width.height.equalTo(78)

            let ptTop = $0.top.equalToSuperview().offset(6).constraint
            let ptCenter = $0.centerX.equalToSuperview().constraint
            self.portraitConstraints.append(contentsOf: [ptTop, ptCenter])

            let lrLead = $0.leading.equalToSuperview().offset(6).priority(.medium).constraint
            let lrCenter = $0.centerY.equalToSuperview().priority(.medium).constraint
            self.addToLandConstraint([lrLead, lrCenter])
        }
        
        pickerView.snp.makeConstraints {[unowned self] in
            let ptTop = $0.top.equalTo(captureButton.snp.bottom).offset(1).constraint
            let ptWidth = $0.width.equalToSuperview().constraint
            let ptHeight = $0.height.equalTo(26).constraint
            let ptCenter = $0.centerX.equalToSuperview().constraint
            self.portraitConstraints.append(contentsOf: [ptTop, ptWidth, ptHeight, ptCenter])

            let lrLead = $0.leading.equalTo(captureButton.snp.trailing).offset(1).priority(.medium).constraint
            let lrHeight = $0.height.equalToSuperview().priority(.medium).constraint
            let lrWidht = $0.width.equalTo(26).priority(.medium).constraint
            let lrCenter = $0.centerY.equalToSuperview().priority(.medium).constraint
            self.addToLandConstraint([lrLead, lrHeight, lrWidht, lrCenter])
        }
    }
    
    func addToLandConstraint(_ consts: [Constraint]) {
        consts.forEach {
            $0.deactivate()
        }

        self.landscapeConstraints.append(contentsOf: consts)
    }

    func rotateLayout(_ orient: UIDeviceOrientation) {
        if orient == .portrait {
            
            self.landscapeConstraints.forEach {
                $0.update(priority: orient == .portrait ? .low : .required)
                $0.deactivate()
            }
            
            self.portraitConstraints.forEach {
                $0.update(priority: orient != .portrait ? .low : .required)
                $0.activate()
            }
        } else if orient == .landscapeRight {
            self.portraitConstraints.forEach {
                $0.update(priority: .low)
                $0.deactivate()
            }
            
            self.landscapeConstraints.forEach {
                $0.update(priority: .required)
                $0.activate()
            }
        }
        
        self.rotateWindow(orient)
        
        updateConstraints()
        
        UIView.animate(withDuration: 0.3, animations: {
            self.layoutIfNeeded()
            self.pickerView.reloadData(orient)
        }) { [weak self] _ in
        }
    }
    
    
    override func didMoveToWindow() {
        super.didMoveToWindow()
        self.pickerView.reloadData(.portrait)
    }
    
    func rotateWindow(_ orientation: UIDeviceOrientation) {
        let mask: UIInterfaceOrientationMask
        let interface: UIInterfaceOrientation
        switch orientation {
        case .portrait:
            mask = .portrait
            interface = .portrait
        case .landscapeRight:
            mask = .landscapeRight
            interface = .landscapeRight
        default:
            return
        }
        
        AppUtility.lockOrientation(mask, andRotateTo: interface)
    }
    
    func setupDI(observable: Observable<[Model]>) {
        // model Dependency Injection
    }
}

extension RotateSSView: RPDataSource, RPDelegate{
    func rotateSSItemCount(_ rssView: RotatePickerView) -> Int {
        borderButtonImageNamed.count
    }
    
    func rotateSSItemImage(_ rssView: RotatePickerView, item: Int, orient: NSLayoutConstraint.Axis) -> String {
        "\(borderButtonImageNamed[item])\(orient == .horizontal ? "W" : "H")"
    }
    
    func rotateSSItemSize(_ rssView: RotatePickerView, item: Int, orient: UIDeviceOrientation) -> CGSize {
        
        if orient == .portrait {
            return item == 0 ? CGSize(width: 52, height: 26) : CGSize(width: 41, height: 26)
        } else {
            return item == 0 ? CGSize(width: 26, height: 52) : CGSize(width: 26, height: 41)
        }
    }
    
    func rotateSS(_ rssView: RotatePickerView, selectedItem item: Int) {
        Log.d("select Item: \(borderButtonImageNamed[item])")
    }
    
}

// MARK: - PreView
#if canImport(SwiftUI) && DEBUG
import SwiftUI

@available(iOS 13.0, *)
struct RotateSS_Previews: PreviewProvider {
    static var previews: some View {
        //        Group {
        //            ForEach(UIView.previceSupportDevices, id: \.self) { deviceName in
        //                DebugPreviewView {
        //                    return RotateSSView()
        //                }.previewDevice(PreviewDevice(rawValue: deviceName))
        //                    .previewDisplayName(deviceName)
        //                    .previewLayout(.sizeThatFits)
        //            }
        //        }        
        Group {
            DebugPreviewView {
                let view = RotateSSView()
                //                .then {
                //                    $0.setupDI(observable: Observable.just([]))
                //                }
                return view
            }
        }
    }
}
#endif
