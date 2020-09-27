//
//  BankValuesCell.swift
//  CurrencyTracker
//
//  Created by Said Çankıran on 21.09.2020.
//  Copyright © 2020 Said Çankıran. All rights reserved.
//

import UIKit

class BankValuesCell: UITableViewCell {
    @IBOutlet weak var mainView: UIView!
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var buyLabel: UILabel!
    @IBOutlet weak var sellLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        //mainView.layer.cornerRadius = 20
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func configure(_ data:BankDataType) {
        nameLabel.text = data.name
        sellLabel.text = data.sell
        buyLabel.text = data.buy
    }
    
}
