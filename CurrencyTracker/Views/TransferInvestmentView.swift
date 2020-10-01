//
//  TransferInvestmentView.swift
//  CurrencyTracker
//
//  Created by Said Çankıran on 28.09.2020.
//  Copyright © 2020 Said Çankıran. All rights reserved.
//

import UIKit
import CoreData

class TransferInvestmentView: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var fromType: UITextField!
    @IBOutlet weak var toType: UITextField!
    @IBOutlet weak var fromValue: UITextField!
    @IBOutlet weak var toValue: UITextField!
    
    @IBOutlet weak var fromTypeLabel: UILabel!
    @IBOutlet weak var toTypeLabel: UILabel!
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var newInvestmentField: UITextField!
    
    let pickerView = UIPickerView()
    lazy var currency:[String] = ["Euro","Dolar","Sterlin","Altın"]
    lazy var filteredInvestment:[NSManagedObject] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        giveDelegateToPickerView()
        giveDelegateToTableView()
        setupToolbar()
        // Do any additional setup after loading the view.
    }
    
    @IBAction func showInfo(_ sender: Any) {
        showInfoAlert()
    }
    
    @IBAction func saveAsNewInvestment(_ sender: Any) {
        //Core Data
        let date = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        
        CoreDataController.run.saveInvestment(newInvestmentField.text!, toType.text!, Double(toValue.text!)!, getCurrencyValue(toType.text!), formatter.date(from: "\(date)")!) { (result, err) in
            if result as! Bool {
                //show succes
                print("succes")
            } else {
                print(err!.localizedDescription)
            }
        }
        //hud
    }

    @IBAction func back(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func textChangeActions(_ sender: UITextField) {
        if !sender.text!.isEmpty {
            switch sender.tag {
            case 0:
                filterInvestment(currrencyType: sender.text!)
            case 1:
                let toCurVal = getCurrencyValue(toType.text!)
                let fromCurVal = getCurrencyValue(fromType.text!)
                toValue.text = "\(Double(round(Double(fromValue.text!)! * (fromCurVal / toCurVal))*1000)/1000)"
            case 2:
                let toCurVal = getCurrencyValue(toType.text!)
                let fromCurVal = getCurrencyValue(fromType.text!)
                fromValue.text = "\(Double(round(Double(toValue.text!)! * (toCurVal / fromCurVal))*1000)/1000)"
            default:
                break
            }
        }
    }
    
    func getCurrencyValue(_ type:String)->Double {
        for index in API.run.summaryData {
            //Sterlin hatası çıkıyor bu yüzden sterlin ayrı kontrol edildi.
            if type == "Sterlin" {
                if index.name == "STERLİN" {
                    return Double(index.value.replacingOccurrences(of: ",", with: "."))!
                }
            }
            if type.lowercased() == index.name.lowercased() {
                return Double(index.value.replacingOccurrences(of: ",", with: "."))!
            }
        }
    
        return 0
    }
    
}




//MARK: TableView
extension TransferInvestmentView: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredInvestment.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "investmentCell") as! InvestmentCell
        
        cell.configure(data: filteredInvestment[indexPath.row])
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let data = filteredInvestment[indexPath.row]
        
        let name = data.value(forKey: "name") as! String
        let type = data.value(forKey: "type") as! String
        let value = data.value(forKey: "value") as! Double
        let buyValue = data.value(forKey: "buyValue") as! Double
        let date = data.value(forKey: "date") as! Date
        
        let alert = UIAlertController.init(title: "Yatırımınız taşınacak.", message: "Yatırımınızı farklı bir yatırıma taşımak üzeresiniz. Emin misiniz?", preferredStyle: .alert)
        
        let yes = UIAlertAction.init(title: "Evet", style: .default) { (UIAlertAction) in
            CoreDataController.run.deleteInvestment(data)
            
            CoreDataController.run.saveInvestment(name, type, value, buyValue, date) { (result, err) in
                if let err = err {
                    //show fail
                    print(err.localizedDescription)
                    return
                }
                
                if result as! Bool {
                    print("Succes")
                    //show ok
                }
            }
        }
        
        let cancel = UIAlertAction.init(title: "İptal", style: .cancel, handler: nil)
        
        alert.addAction(yes)
        alert.addAction(cancel)
        self.present(alert, animated: true, completion: nil)
    }
    
    func filterInvestment(currrencyType:String) {
        CoreDataController.run.getInvestment { (dataSet, error) in
            if let err = error {
                print(err)
                //show hud
                return
            }
            
            for object in dataSet! {
                if object.value(forKey: "type") as! String == currrencyType {
                    self.filteredInvestment.append(object)
                }
            }
            
            self.tableView.reloadData()
        }
    }
    
    func giveDelegateToTableView() {
        tableView.register(UINib.init(nibName: "InvestmentCell", bundle: nil), forCellReuseIdentifier: "investmentCell")
        tableView.delegate = self
        tableView.dataSource = self
        tableView.rowHeight = 146

    }
}





extension TransferInvestmentView {
    func showInfoAlert() {
        let alert = UIAlertController.init(title: "Bilgi", message: "İsterseniz aktarilacak yatırımı aşağıdan seçebilir ya da İsim vererek yeni yatırım olarak kayıt edebilirsiniz.", preferredStyle: .alert)
        
        let ok = UIAlertAction.init(title: "Tamam", style: .default, handler: nil)
        
        alert.addAction(ok)
        self.present(alert, animated: true, completion: nil)
    }
}


//MARK: Picker View and Toolbar
extension TransferInvestmentView: UIPickerViewDelegate, UIPickerViewDataSource {
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
            if toType.isFirstResponder {
                toType.text = currency[row - 1]
                toTypeLabel.text = currency[row - 1]
            } else {
                fromType.text = currency[row - 1]
                fromTypeLabel.text = currency[row - 1]
            }
        }
    }
    
    func giveDelegateToPickerView() {
        pickerView.delegate = self
        pickerView.dataSource = self
        toType.inputView = pickerView
        fromType.inputView = pickerView
    }
    
    func setupToolbar() {
        let toolbar = UIToolbar.init()
        toolbar.sizeToFit()
        
        let done = UIBarButtonItem.init(title: "Tamam", style: .done, target: nil, action: #selector(closeKeyboard))
        let space = UIBarButtonItem.init(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        
        toolbar.setItems([space,done], animated: true)
        
        fromType.inputAccessoryView = toolbar
        toType.inputAccessoryView = toolbar

    }
    
    @objc func closeKeyboard() {
        self.view.endEditing(true)
    }
    
    
}
