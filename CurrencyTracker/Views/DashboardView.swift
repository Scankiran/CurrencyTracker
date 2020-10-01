//
//  ProfileAndCalculatorPage.swift
//  CurrencyTracker
//
//  Created by Said Çankıran on 22.09.2020.
//  Copyright © 2020 Said Çankıran. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import CoreData
class DashboardView: UIViewController {

    //Yatırım Silme seçeneği olacak (Coredata ve firebase'den silme) ayrıca paraları güncelleme olacak.
//    Data formatter yapılacak cell için.
    //User auth işlemlerine başlansın. Firestore'da yatırım tutma yapıları için çalışma yap.
    @IBOutlet weak var userInformationView: UIView!
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var welcomeMessageLabel: UILabel!
    @IBOutlet weak var userNameLabel: UILabel!
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var profilePicture: UIImageView!
    @IBOutlet weak var beforeInvestmenCashLabel: UILabel!
    @IBOutlet weak var afterInvestmentCashLabel: UILabel!
    
    lazy var investmentData:[NSManagedObject] = []
    lazy var afterInvestmentValue:Double = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        checkUser()
        giveDelegateToTableView()

        CoreDataController.run.getInvestment { (data, error) in
            if let err = error {
                //TODO: SHow Fail
                print(err.localizedDescription)
                return
            }
            
            self.investmentData = data!
            self.tableView.reloadData()
        }
        
        if let money = UserDefaults.standard.value(forKey: "userMoney") as? String {
            self.beforeInvestmenCashLabel.text = "\(money) ₺"
        }
        // Do any additional setup after loading the view.
    }
    
    @IBAction func updateMoney(_ sender: Any) {
        createAlert()
    }
    
    @IBAction func addInvestment(_ sender: Any) {
        addInvestment()
    }
    @IBAction func toTransfer(_ sender: Any) {
        performSegue(withIdentifier: "toTransfer", sender: self)
    }
    
    func isInitial() {
        if UserDefaults.standard.value(forKey: "isInitial") == nil {
            UserDefaults.standard.setValue(false, forKey: "isInitial")
            beforeInvestmenCashLabel.addGestureRecognizer(UITapGestureRecognizer.init(target: self, action: #selector(createAlert)))
            afterInvestmentCashLabel.addGestureRecognizer(UITapGestureRecognizer.init(target: self, action: #selector(createAlert)))

        }
    }
    
    @IBAction func back(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
}





//MARK: View Functions
extension DashboardView {
    
    @objc func goToProfile() {
        performSegue(withIdentifier: "toProfile", sender: self)
    }
    
    @objc func createAlert() {
        let alert = UIAlertController.init(title: "Ne kadar paranız var?", message: "Girdiğiniz miktar yatırımlarınızdan önceki miktarı belirtmelidir. ", preferredStyle: .alert)
        
            alert.addTextField { (textField) in
            textField.placeholder = "Para Miktarınız"
            textField.textAlignment = .center
        }
        
        let save = UIAlertAction.init(title: "Güncelle", style: .default) { (action) in
            
            if let text = alert.textFields![0].text {
                UserDefaults.standard.set(text, forKey: "userMoney")
                
                //Yatırım yapılabilecek parayı burda kayıtlı olarak tuttum. Eğer daha önceden kayıt edilmişse güncel parayı eski paranın üzerine ekledim.
                if UserDefaults.standard.value(forKey: "restMoney") == nil {
                    UserDefaults.standard.set(text, forKey: "restMoney")
                } else {
                    let value = Double(text)!
                    let restMoney = Double(UserDefaults.standard.value(forKey: "restMoney") as! String)!
                    UserDefaults.standard.set("\(value + restMoney)", forKey: "restMoney")
                }
                
                self.beforeInvestmenCashLabel.text = alert.textFields![0].text
            }
        }
        
        let cancel = UIAlertAction.init(title: "Vazgeç", style: .cancel, handler: nil)
        
        alert.addAction(cancel)
        alert.addAction(save)
        self.present(alert,animated: true)
    }
    
    @objc func addInvestment() {
        performSegue(withIdentifier: "toInvestment", sender: self)
    }
    
    func checkUser() {
        if let user = Auth.auth().currentUser {
          // User is signed in.
          // ...
            let userUID = user.uid
            userNameLabel.text = user.displayName
            
            
            if let money = UserDefaults.standard.value(forKey: "userMoney") as? String {
                self.beforeInvestmenCashLabel.text = money
            }
            
            
            //show username
            //show userProfile Photo
            //check money and investment
        } else {
            welcomeMessageLabel.text = "Giriş Yap"
            welcomeMessageLabel.isUserInteractionEnabled = true
            welcomeMessageLabel.backgroundColor = UIColor.green
            
            userNameLabel.text = "Kayıt Ol"
            userNameLabel.isUserInteractionEnabled = true
            userNameLabel.backgroundColor = UIColor.blue
            
            welcomeMessageLabel.addGestureRecognizer(UITapGestureRecognizer.init(target: self, action: #selector(goToProfile)))
            userNameLabel.addGestureRecognizer(UITapGestureRecognizer.init(target: self, action: #selector(goToProfile)))
        }
    }
}




//MARK: TableView
extension DashboardView: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return investmentData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "investmentCell") as! InvestmentCell
        let data = investmentData[indexPath.row]
        
        cell.configure(data: data)
        
        afterInvestmentValue += (data.value(forKey: "buyValue") as! Double) * (data.value(forKey: "value") as! Double)
        afterInvestmentCashLabel.text = "\(Double(round(10000*(afterInvestmentValue))/10000)) ₺"
        return cell
    }
    
    func giveDelegateToTableView() {
        tableView.register(UINib.init(nibName: "InvestmentCell", bundle: nil), forCellReuseIdentifier: "investmentCell")
        tableView.delegate = self
        tableView.dataSource = self
        tableView.rowHeight = 146
        
    }
    
}
