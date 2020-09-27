//
//  InvestmentEditView.swift
//  CurrencyTracker
//
//  Created by Said Çankıran on 25.09.2020.
//  Copyright © 2020 Said Çankıran. All rights reserved.
//

import UIKit

class InvestmentEditView: UIViewController {

    let pickerView = UIPickerView()
    
    lazy var alert:UIAlertController = UIAlertController()
    
    lazy var currency:[String] = ["Euro","Dolar","Sterlin","Altın"]
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    //Alış tarihi date picker olacak ve eğer
//bugün seçilmezse birim parası sorulacak. Yatırımdan sonraki para miktarı sorulacak.

    //Yatırımın bankasıda sorulabilir.
    
    //Yatırım miktarı daha önceki yatırımlarından sonra kalan parayı gösterecek.
    
    //Coredata'ya ve eğer auth olmuşsa firebase'e kaydedilecek.
    
    //User defaults'da değer güncellemesi yapılacak.

}




extension InvestmentEditView: UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return 5
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if row == 0 {
            return ""
        }
        
        return currency[row - 1]
    }
    
    
    
    
    func giveDelegateToPickerView() {
        pickerView.delegate = self
        pickerView.dataSource = self
    }
}
