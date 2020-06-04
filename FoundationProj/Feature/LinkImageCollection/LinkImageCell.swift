//
//  LinkImageCell.swift
//  FoundationProj
//
//  Created by baedy on 2020/06/04.
//  Copyright © 2020 baedy. All rights reserved.
//

import UIKit
import SnapKit
import Reusable
import RxSwift
import RxCocoa
import Photos
import Cell_Rx
import SDWebImage

class LinkImageCell: UICollectionViewCell, Reusable  {
    let label = UILabel().then{
        $0.textAlignment = .center
    }
    
    let checkBox = CheckBox().then{
        $0.onImage = #imageLiteral(resourceName: "mr_btn_checkbox_on")
        $0.offImage = #imageLiteral(resourceName: "mr_btn_checkbox_off")
        $0.isUserInteractionEnabled = false
        $0.isHidden = true
    }
    
    let imageView = UIImageView().then{
        $0.contentMode = .scaleAspectFill
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupLayout()
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
    
    func mapping(url: URL){
        self.imageView.sd_setImage(with: url, completed: { (image, error, _, url)  in
            
        })
    }
    
    override var isSelected: Bool{
        didSet{
            self.checkBox.isSelected = isSelected
        }
    }
}
