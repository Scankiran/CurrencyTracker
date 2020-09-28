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

    @IBOutlet weak var userInformationView: UIView!
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var welcomeMessageLabel: UILabel!
    @IBOutlet weak var userNameLabel: UILabel!
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var profilePicture: UIImageView!
    @IBOutlet weak var beforeInvestmenCashLabel: UILabel!
    @IBOutlet weak var afterInvestmentCashLabel: UILabel!
    
    lazy var investmentData:[NSManagedObject] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        checkUser()
        if let money = UserDefaults.standard.value(forKey: "userMoney") as? String {
            self.beforeInvestmenCashLabel.text = money
        }
        // Do any additional setup after loading the view.
    }
    
    @IBAction func updateMoney(_ sender: Any) {
        createAlert()
    }
    
    @IBAction func addInvestment(_ sender: Any) {
        addInvestment()
    }
    
    func isInitial() {
        if UserDefaults.standard.value(forKey: "isInitial") == nil {
            UserDefaults.standard.setValue(false, forKey: "isInitial")
            beforeInvestmenCashLabel.addGestureRecognizer(UITapGestureRecognizer.init(target: self, action: #selector(createAlert)))
            afterInvestmentCashLabel.addGestureRecognizer(UITapGestureRecognizer.init(target: self, action: #selector(createAlert)))

        }
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



//MARK: CoreData
extension DashboardView {
    func getDataFromCoreData() {
        guard let appDelegate =
          UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        
        let managedContext =
          appDelegate.persistentContainer.viewContext
        
        //2
        let fetchRequest =
          NSFetchRequest<NSManagedObject>(entityName: "Dates")
        
        //3
        do {
            let data = try managedContext.fetch(fetchRequest)
            self.investmentData = data
            
        } catch let error as NSError {
          print("Could not fetch. \(error), \(error.userInfo)")
        }
     tableView.reloadData()
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
        
        return cell
    }
    
    func giveDelegateToTableView() {
        tableView.register(UINib.init(nibName: "InvestmentCell", bundle: nil), forCellReuseIdentifier: "investmentCell")
        tableView.delegate = self
        tableView.dataSource = self
    }
    
}
