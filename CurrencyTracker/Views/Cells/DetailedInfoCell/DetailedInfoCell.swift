//
//  DetailedInfoCell.swift
//  CurrencyTracker
//
//  Created by Said Çankıran on 18.09.2020.
//  Copyright © 2020 Said Çankıran. All rights reserved.
//

import UIKit

class DetailedInfoCell: UITableViewCell {

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var buyLabel: UILabel!
    @IBOutlet weak var sellLabel: UILabel!
    @IBOutlet weak var minLabel: UILabel!
    @IBOutlet weak var maksLabel: UILabel!
    
    @IBOutlet weak var backView: UIView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        backView.layer.cornerRadius = 25
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func configure(name:String, buy:String, sell:String, min:String, maks:String, type:String) {
        
        nameLabel.text = name
        buyLabel.text = buy
        sellLabel.text = sell
        minLabel.text = min
        maksLabel.text = maks
        
        (type == "up") ? (nameLabel.textColor = UIColor.systemRed) : (nameLabel.textColor = UIColor.systemGreen)
        
        
    }
    
}
