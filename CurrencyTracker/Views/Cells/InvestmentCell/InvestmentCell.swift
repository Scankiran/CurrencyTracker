//
//  InvestmentCell.swift
//  CurrencyTracker
//
//  Created by Said Çankıran on 28.09.2020.
//  Copyright © 2020 Said Çankıran. All rights reserved.
//

import UIKit
import CoreData

class InvestmentCell: UITableViewCell {

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    
    func configure(data:NSManagedObject) {
        print(data.value(forKey: "type"))
    }
}
