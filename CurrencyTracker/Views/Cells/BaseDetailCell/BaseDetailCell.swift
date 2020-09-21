//
//  BaseDetailCell.swift
//  CurrencyTracker
//
//  Created by Said Çankıran on 18.09.2020.
//  Copyright © 2020 Said Çankıran. All rights reserved.
//

import UIKit

class BaseDetailCell: UITableViewCell {

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var valueOrBuyLabel: UILabel!
    @IBOutlet weak var typeOrSellLabel: UILabel!
    @IBOutlet weak var backgorundView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.backgorundView!.layer.cornerRadius = 25
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func configure(name:String,value:String,type:String) {
        nameLabel.text = name.uppercased()
        valueOrBuyLabel.text = value
        if type == "up" {
            valueOrBuyLabel.textColor = UIColor.systemGreen
            typeOrSellLabel.text = "🟢"
        } else {
            valueOrBuyLabel.textColor = UIColor.systemRed
            typeOrSellLabel.text = "🔴"
        }
    }
    
}
