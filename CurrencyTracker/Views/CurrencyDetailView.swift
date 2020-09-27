//
//  CurrencyDetailView.swift
//  CurrencyTracker
//
//  Created by Said Çankıran on 21.09.2020.
//  Copyright © 2020 Said Çankıran. All rights reserved.
//

import UIKit
import FirebaseFirestore

class CurrencyDetailView: UIViewController,UITextFieldDelegate {

    @IBOutlet weak var currencyNameLabel: UILabel!
    @IBOutlet weak var currencyValueLabel: UILabel!
    
    @IBOutlet weak var dailyChangeRate: UILabel!
    @IBOutlet weak var weeklyChangeRate: UILabel!
    @IBOutlet weak var yearlyChangeRate: UILabel!
    
    @IBOutlet weak var firstCurrencyField: UITextField!
    @IBOutlet weak var secondCurrencyField: UITextField!
    
    @IBOutlet weak var tableView: UITableView!
    
    let db = Firestore.firestore()
    
    var bankData:[BankDataType] = []
    var changeRate:[SummaryDataType] = []
    
    var currencyType:String = ""
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func backActions(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        getData(currencyType: currencyType)
    }
    
    @IBAction func calculateCurrency(_ sender: UITextField) {
        if !sender.text!.isEmpty, let senderValue = Double(sender.text!){
            if sender.tag == 0  {
                let value = senderValue * Double(currencyValueLabel.text!)!
                let roundValue = Double(round(1000*value)/1000)
                secondCurrencyField.text = "\(roundValue)"
            } else {
                let value = (1 / Double(currencyValueLabel.text!)!) * senderValue
                let roundValue = Double(round(1000*value)/1000)
                firstCurrencyField.text = "\(roundValue)"
            }
        } else {
            secondCurrencyField.text = ""
            firstCurrencyField.text = ""
        }
    }
}



//MARK: Connection
extension CurrencyDetailView {
    
    func getData(currencyType:String) {
        db.collection("\(currencyType)").document("last").getDocument { (snapshot, err) in
            if let err = err {
                print(err.localizedDescription)
            } else {
                let michael = snapshot!.data()!["generalInfo"]! as! Dictionary<String, String>
                print(michael)
                let bankDataa = "\(snapshot!.data()!["banks"]!)".data(using: .utf8)!
                
                let changeRateData = "\(snapshot!.data()!["changeRate"]!)".data(using: .utf8)!
                do {
                    self.bankData = try JSONDecoder.init().decode([BankDataType].self, from: bankDataa)
                    self.changeRate = try JSONDecoder.init().decode([SummaryDataType].self, from: changeRateData)
                    self.registerAndSetTableView()
                    self.setupView(self.changeRate, michael["buy"]!, michael["name"]!)

                } catch  {
                    print(error.localizedDescription)
                }
            }
        }
    }
    
    func setupView(_ dataSet:[SummaryDataType],_ currencyValue:String, _ currencyName:String) {
        currencyNameLabel.text = currencyName
        currencyValueLabel.text = currencyValue.replacingOccurrences(of: ",", with: ".")
        firstCurrencyField.placeholder = currencyName
        
        for rate in dataSet {
            switch rate.name {
            case "Günlük Değişim":
                dailyChangeRate.text = rate.value
                (rate.type == "up") ? (dailyChangeRate.textColor = UIColor.systemGreen) : (dailyChangeRate.textColor = UIColor.red)
            case "Haftalık Değişim":
                weeklyChangeRate.text = rate.value
                (rate.type == "up") ? (weeklyChangeRate.textColor = UIColor.systemGreen) : (weeklyChangeRate.textColor = UIColor.red)
            case "Yıllık Değişim":
                yearlyChangeRate.text = rate.value
                (rate.type == "up") ? (yearlyChangeRate.textColor = UIColor.systemGreen) : (yearlyChangeRate.textColor = UIColor.red)
            default:
                continue
                
            }
        }
        
    }
}



//MARK: Table View
extension CurrencyDetailView: UITableViewDelegate,UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return bankData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "bankValuesCell") as! BankValuesCell
        let data = bankData[indexPath.row]

        cell.configure(data)
        (indexPath.row % 2 == 0) ? cell.mainView.backgroundColor = UIColor.init(displayP3Red: 232/255, green: 242/255, blue: 249/255, alpha: 1) : (cell.mainView.backgroundColor = UIColor.clear)
        
        
        return cell
    }
    
    func registerAndSetTableView() {
        tableView.register(UINib.init(nibName: "BankValuesCell", bundle: nil), forCellReuseIdentifier: "bankValuesCell")
        tableView.delegate = self
        tableView.dataSource = self
        tableView.rowHeight = 60
        tableView.cellLayoutMarginsFollowReadableWidth = true
    }
    
}
