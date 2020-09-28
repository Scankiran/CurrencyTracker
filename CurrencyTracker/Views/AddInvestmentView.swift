//
//  InvestmentEditView.swift
//  CurrencyTracker
//
//  Created by Said Çankıran on 25.09.2020.
//  Copyright © 2020 Said Çankıran. All rights reserved.
//

import UIKit
import CoreData

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
    @IBOutlet weak var valueField: UITextField!
    @IBOutlet weak var dateField: UITextField!
    @IBOutlet weak var buyValueField: UITextField!


    
    lazy var currency:[String] = ["Euro","Dolar","Sterlin","Altın"]
    
    lazy var alert:UIAlertController = UIAlertController()

    override func viewDidLoad() {
        super.viewDidLoad()
        giveDelegateToPickerView()
        typeField.inputView = pickerView
        dateField.inputView = datePicker
        datePicker.datePickerMode = .date
        if #available(iOS 13.4, *) {
            datePicker.preferredDatePickerStyle = UIDatePickerStyle.wheels
        }
        
        datePicker.addTarget(self, action: #selector(checkDate), for: .valueChanged)
        
        getMoneyAndCalculate()
        
        let tap = UITapGestureRecognizer.init(target: self, action: #selector(closeKeyboard))
        self.view.addGestureRecognizer(tap)
        // Do any additional setup after loading the view.
    }
    
    //Alış tarihi date picker olacak ve eğer
//bugün seçilmezse birim parası sorulacak. Yatırımdan sonraki para miktarı sorulacak.

    //Yatırımın bankasıda sorulabilir.
    
    //Yatırım miktarı daha önceki yatırımlarından sonra kalan parayı gösterecek.
    
    //Coredata'ya ve eğer auth olmuşsa firebase'e kaydedilecek.
    
    //User defaults'da değer güncellemesi yapılacak.
    
    @objc func checkDate(datePicker:UIDatePicker) {
        var selectedDate = datePicker.date
        
        let date = Date()
        let formatter = DateFormatter()
        
        formatter.dateFormat = "yyyy-MM-dd"
        let result = formatter.string(from: date)
        var formatted = formatter.string(from: selectedDate)
        
        if result == formatted {
            //TODO: Buraya birim fiyatı girecek şekilde ayarlanacak.
        }
        
        
    }
    
    func getMoneyAndCalculate() {
        if let money = UserDefaults.standard.value(forKey: "userMoney") as? String {
            let moneyValue = Double(money.replacingOccurrences(of: ",", with: "."))
            
            for index in API.run.summaryData {
                switch index.name.lowercased() {
                case "euro":
                    let euro = Double(index.value.replacingOccurrences(of: ",", with: "."))!
                    euroLabel.text = "\(Double(round(1000*(moneyValue! / euro))/1000)) €"
                case "dolar":
                    let usd = Double(index.value.replacingOccurrences(of: ",", with: "."))!
                    usdLabel.text = "\(Double(round(1000*(moneyValue! / usd))/1000)) $"
                case "sterli̇n":
                    let gbp = Double(index.value.replacingOccurrences(of: ",", with: "."))!
                    gbpLabel.text = "\(Double(round(1000*(moneyValue! / gbp))/1000)) £"
                case "gram altin":
                    let gold = Double(index.value.replacingOccurrences(of: ",", with: "."))!
                    goldLabel.text = "\(Double(round(1000*(moneyValue! / gold))/1000)) GR"
                default:
                    continue
                }
            }
            tryLabel.text = "\(money) ₺"
        }
    }
    
    func saveCoreData(_ date:String,_ target:Int,_ status:Int,_ isSucces:Bool) {
          
          guard let appDelegate =
            UIApplication.shared.delegate as? AppDelegate else {
            return
          }
          
          // 1
          let managedContext =
            appDelegate.persistentContainer.viewContext
          
          // 2
          let entity =
            NSEntityDescription.entity(forEntityName: "Dates",
                                       in: managedContext)!
          
          let entry = NSManagedObject(entity: entity,
                                       insertInto: managedContext)
          
          // 3
          
            
            let data:[String:Any] = ["date":date,"target":target,"status":status,"isSucces":isSucces]
            
            entry.setValuesForKeys(data)
          // 4
          do {
            try managedContext.save()
            print("Succes")
          } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
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
        
        let done = UIBarButtonItem.init(title: "Tamam", style: .done, target: nil, action: nil)
        let space = UIBarButtonItem.init(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        
        toolbar.setItems([space,done], animated: true)
        
        typeField.inputAccessoryView = toolbar
        dateField.inputAccessoryView = toolbar

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
    
    func giveDelegateToPickerView() {
        pickerView.delegate = self
        pickerView.dataSource = self
    }
}
