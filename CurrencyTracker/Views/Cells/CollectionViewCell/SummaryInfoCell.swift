//
//  SummaryInfoCell.swift
//  CurrencyTracker
//
//  Created by Said Çankıran on 19.09.2020.
//  Copyright © 2020 Said Çankıran. All rights reserved.
//

import UIKit

class SummaryInfoCell: UICollectionViewCell {
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var valueLabel: UILabel!
    @IBOutlet weak var typeLabel: UILabel!
    
    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var detailButton: UIButton!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        mainView.layer.cornerRadius = 20
        detailButton.layer.cornerRadius = 10
        
    }
    
    func configure(data:SummaryDataType) {
        nameLabel.text = data.name.uppercased()
        valueLabel.text = data.value
        if data.type == "up" {
            typeLabel.text = "🟢"
        } else {
            typeLabel.text = "🔴"
        }
    }

}
