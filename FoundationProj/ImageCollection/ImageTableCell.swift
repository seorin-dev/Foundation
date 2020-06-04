//
//  ImageTableCell.swift
//  FondationProj
//
//  Created by baedy on 2020/04/29.
//  Copyright © 2020 baedy. All rights reserved.
//

import UIKit
import SnapKit
import Reusable

class ImageTableCell: UITableViewCell, Reusable {
    let label = UILabel().then{
        $0.textAlignment = .center
    }
    
    let checkBox = CheckBox().then{
        $0.onImage = #imageLiteral(resourceName: "cm_btn_checkbox_on")
        $0.offImage = #imageLiteral(resourceName: "cm_btn_checkbox_off")
        $0.isUserInteractionEnabled = false
    }
      
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupLayout(){
        label.font =  .systemFont(ofSize: 12, weight: .medium)
        
        self.addSubview(label)
        self.addSubview(checkBox)
        
        label.snp.makeConstraints{
            $0.edges.equalToSuperview()
            $0.height.equalTo(40)
        }
        
        checkBox.snp.makeConstraints{
            $0.leading.equalToSuperview().offset(40)
            $0.centerY.equalToSuperview().offset(15)
            $0.width.height.equalTo(25)
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        self.checkBox.isSelected = isSelected
        // Configure the view for the selected state
    }

}
