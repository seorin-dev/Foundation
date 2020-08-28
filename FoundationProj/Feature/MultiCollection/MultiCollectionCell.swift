//
//  MultiCollectionCell.swift
//  FondationProj
//
//  Created by baedy on 2020/04/28.
//  Copyright © 2020 baedy. All rights reserved.
//

import UIKit
import SnapKit
import Reusable
import RxSwift
import RxCocoa
import Photos
import Cell_Rx

class MultiCollectionCell: UICollectionViewCell, Reusable {
    let assetRelay = PublishRelay<AssetType>()
    
    let label = UILabel().then{
        $0.textAlignment = .center
    }
    
    let checkBox = CheckBox().then{
        $0.onImage = #imageLiteral(resourceName: "mr_btn_checkbox_on")
        $0.offImage = #imageLiteral(resourceName: "mr_btn_checkbox_off")
        $0.isUserInteractionEnabled = false
    }
    
    var image: UIImage!{
        didSet{
            self.imageView.image = image
        }
    }
    
    let imageView = UIImageView().then{
        $0.contentMode = .scaleAspectFill
    }
    
    private var bindCompleted: Bool = false
      
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupLayout()
        bindData()
    }

    func setupLayout(){
        self.clipsToBounds = true
        self.addSubview(imageView)
        self.addSubview(checkBox)
        
        imageView.snp.makeConstraints{
            $0.edges.equalToSuperview()
        }
        
        checkBox.snp.makeConstraints{
            $0.leading.top.equalToSuperview().offset(10)
            $0.width.height.equalTo(25)
        }
    }
    
    func bindData(){
        assetRelay.map{
            $0.getAsset
        }.subscribe(onNext: { asset in
            _ = PHRepository.getImageFromAsset(asset, options: PHRepository.defaultImageFetchOptions, completion: { [weak self] image in
                guard let `self` = self else { return }
                print("imageAsset : \(asset.description)")
                self.imageView.image = image
            })
        }).disposed(by: rx.disposeBag)
    }

    func setupDI(asset: AssetType){
        self.assetRelay.accept(asset)
    }
    
    func requestImageFromAseet(asset: PHAsset) -> Observable<UIImage>{
        var fetchOption = PHRepository.FetchOptions()
        fetchOption.size = CGSize(width: 300, height: 300)
        fetchOption.contentMode = .default
        let imageFunc = PHRepository.GetFuncImageFromAsset(fetchOptions:  fetchOption)
        return imageFunc(asset)
    }
    
    override var isSelected: Bool{
        didSet{
            self.checkBox.isSelected = isSelected
        }
    }
}
