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

    @IBOutlet weak var nameField: UILabel!
    @IBOutlet weak var valueAndTypeLabel: UILabel!
    @IBOutlet weak var buyValueLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    
    func configure(data:NSManagedObject) {
        let name = data.value(forKey: "name")
        let date = data.value(forKey: "date")
        let type = data.value(forKey: "type") as! String
        let buyValue = data.value(forKey: "buyValue") as! Double
        let value = data.value(forKey: "value") as! Double
        
        nameField.text = "\(name!)"
        valueAndTypeLabel.text = "\(value) \(type)"
        buyValueLabel.text = "\(buyValue)"
        dateLabel.text = "\(date!)"
    }
}
