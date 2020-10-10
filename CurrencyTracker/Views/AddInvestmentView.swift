//
//  InvestmentEditView.swift
//  CurrencyTracker
//
//  Created by Said Çankıran on 25.09.2020.
//  Copyright © 2020 Said Çankıran. All rights reserved.
//

import UIKit
import CoreData
import FirebaseAuth
import FirebaseFirestore
import ARSLineProgress

class AddInvestmentView: UIViewController {

    let pickerView = UIPickerView()
    let datePicker = UIDatePicker()
    
    @IBOutlet weak var tryLabel: UILabel!
    @IBOutlet weak var euroLabel: UILabel!
    @IBOutlet weak var usdLabel: UILabel!
    @IBOutlet weak var gbpLabel: UILabel!
    @IBOutlet weak var goldLabel: UILabel!
    
    @IBOutlet weak var nameField: UITextField!
    @IBOutlet weak var typeField: UITextField!
    @IBOutlet weak var secondTypeField: UILabel!
    @IBOutlet weak var valueField: UITextField!
    @IBOutlet weak var dateField: UITextField!
    @IBOutlet weak var buyValueField: UITextField!

    lazy var currency:[String] = ["Euro","Dolar","Sterlin","Altın"]
    lazy var alert:UIAlertController = UIAlertController()

    override func viewDidLoad() {
        super.viewDidLoad()
        giveDelegateToPickerView()
        setupView()
        getMoneyAndCalculate()

        
        // Do any additional setup after loading the view.
    }
    @IBAction func back(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func saveButton(_ sender: Any) {
        let canInvesmentMoney = (API.run.currencyDict[secondTypeField.text!.lowercased()]! * Double(valueField.text!)!)
        if canInvesmentMoney < Double(UserDefaults.standard.value(forKey: "restMoney") as! String)! {
            CoreDataController.run.saveInvestment(nameField.text!, typeField.text!, Double(valueField.text!)!, Double(buyValueField.text!)!, datePicker.date) { (result, error) in
                
                if let err = error {
                    //show fail hud
                    print(err.localizedDescription)
                    ARSLineProgress.showFail()
                    return
                } else {
                    //show succes hud
                    ARSLineProgress.showSuccess()
                    self.navigationController?.popViewController(animated: true)
                }
            }
            
            let value = Double(UserDefaults.standard.value(forKey: "userMoney") as! String)!
            let restMoney = Double(valueField.text!)! * Double(buyValueField.text!)!
            
            UserDefaults.standard.setValue("\(value - restMoney)", forKey: "restMoney")
            API.run.saveInfo(["restMoney":"\(value - restMoney)"], Auth.auth().currentUser!)
        } else {
            ARSLineProgress.showFail()
        }

    }
    

    
    @objc func checkDate(datePicker:UIDatePicker) {
        let date = Date()
        let formatter = DateFormatter()
        
        formatter.dateFormat = "yyyy-MM-dd"
        let result = formatter.string(from: date)
        let formatted = formatter.string(from: datePicker.date)
        
        dateField.text = formatted
        
        if result == formatted {
            //TODO: Buraya birim fiyatı girecek şekilde ayarlanacak.
            for index in API.run.summaryData {
                if index.name.lowercased() == typeField.text?.lowercased() {
                    buyValueField.text = index.value
                }
            }
        }
        
        
    }
    
    func getMoneyAndCalculate() {
        if let money = UserDefaults.standard.value(forKey: "restMoney") as? String {
            let moneyValue = Double(money.replacingOccurrences(of: ",", with: "."))
            
            for index in API.run.summaryData {
                switch index.name.lowercased() {
                case "euro":
                    let euro = Double(index.value)!
                    euroLabel.text = "\(Double(round(1000*(moneyValue! / euro))/1000)) €"
                case "dolar":
                    let usd = Double(index.value)!
                    usdLabel.text = "\(Double(round(1000*(moneyValue! / usd))/1000)) $"
                case "sterli̇n":
                    let gbp = Double(index.value)!
                    gbpLabel.text = "\(Double(round(1000*(moneyValue! / gbp))/1000)) £"
                case "gram altin":
                    let gold = Double(index.value)!
                    goldLabel.text = "\(Double(round(1000*(moneyValue! / gold))/1000)) GR"
                default:
                    continue
                }
            }
            tryLabel.text = "\(Double(round(1000*(Double(money)!))/1000)) ₺"
        }
    }
    
    @objc func closeKeyboard() {
        self.view.endEditing(true)
    }
}


extension AddInvestmentView {
    
    //MARK: Setup Toolbar
    func setupView() {
        let toolbar = UIToolbar.init()
        toolbar.sizeToFit()
        
        let done = UIBarButtonItem.init(title: "Tamam", style: .done, target: nil, action: #selector(closeKeyboard))
        let space = UIBarButtonItem.init(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        
        toolbar.setItems([space,done], animated: true)
        
        typeField.inputAccessoryView = toolbar
        dateField.inputAccessoryView = toolbar

        datePicker.addTarget(self, action: #selector(checkDate), for: .valueChanged)
        
        
        let tap = UITapGestureRecognizer.init(target: self, action: #selector(closeKeyboard))
        self.view.addGestureRecognizer(tap)
        
        typeField.inputView = pickerView
        dateField.inputView = datePicker
        datePicker.datePickerMode = .date
        if #available(iOS 13.4, *) {
            datePicker.preferredDatePickerStyle = UIDatePickerStyle.wheels
        }
        
    }
}


//MARK: PickerView Delegate
extension AddInvestmentView: UIPickerViewDelegate, UIPickerViewDataSource {
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
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if row != 0 {
            typeField.text = currency[row - 1]
            secondTypeField.text = currency[row - 1]
        }
    }
    
    func giveDelegateToPickerView() {
        pickerView.delegate = self
        pickerView.dataSource = self
    }
}
