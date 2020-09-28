//
//  ViewController.swift
//  CurrencyTracker
//
//  Created by Said Çankıran on 18.09.2020.
//  Copyright © 2020 Said Çankıran. All rights reserved.
//

import UIKit
import FirebaseFirestore

class MainViewController: UIViewController  {
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var scroolView: UIScrollView!
    
    lazy var db = Firestore.firestore()
    
    var summaryDataCollection:[SummaryDataType] = []
    var detailedDataCollection:[DetailDataType] = []
    
    lazy var selectedData:SummaryDataType? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        registerAndSetTableView()
        giveDelegateToCollectionView()
        getSummaryData()
        tableView.backgroundView?.layer.cornerRadius = 20
        
        _ = Timer.scheduledTimer(timeInterval: 60, target: self, selector: #selector(getSummaryData), userInfo: nil, repeats: true)
    }
    
    @IBAction func changeInformation(_ sender: UISegmentedControl) {
        tableView.reloadData()
    }
    
    @IBAction func rightButton(_ sender: Any) {
        performSegue(withIdentifier: "detail", sender: self)
    }
    
    @IBAction func profilePage(_ sender: Any) {
        performSegue(withIdentifier: "profileAndCalculatorPage", sender: self)

        
    }
}


//MARK: Data Controller
extension MainViewController {
    @objc func getSummaryData() {
        print("run")
        API.run.getCurrencySummary { (result, err) in
            if let err = err {
                print(err.localizedDescription)
            } else {
                self.summaryDataCollection = result!
                self.collectionView.reloadData()
            }
        }
        
        API.run.getCurrencyDetailed { (result, err) in
            if let err = err {
                print(err.localizedDescription)
            } else {
                self.detailedDataCollection = result!
                self.tableView.reloadData()
            }
        }
    }
}



//MARK: Collection View
extension MainViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return summaryDataCollection.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "summaryCell", for: indexPath) as! SummaryInfoCell
        let data = summaryDataCollection[indexPath.row]
        
        cell.configure(data: data)
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        selectedData = summaryDataCollection[indexPath.row]
        if selectedData!.name.lowercased() != Formatter.run.currencyTypeFormatter(currency: selectedData!.name) {
            performSegue(withIdentifier: "detail", sender: self)
        }
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "detail" {
            let vc = segue.destination as! CurrencyDetailView
            vc.currencyType = Formatter.run.currencyTypeFormatter(currency: selectedData!.name)
        }
    }
    
    func giveDelegateToCollectionView() {
        collectionView.register(UINib.init(nibName: "SummaryInfoCell", bundle: nil), forCellWithReuseIdentifier: "summaryCell")
        collectionView.delegate = self
        collectionView.dataSource = self
        
    }
    
}




//MARK: TableView
extension MainViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return detailedDataCollection.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "detailedCell") as! DetailedInfoCell
        let data = detailedDataCollection[indexPath.row]
        
        cell.configure(name: data.name, buy: data.buy, sell: data.sell, min: data.min, maks: data.max, type: data.type)
        
        (indexPath.row % 2 == 0) ? cell.backView.backgroundColor = UIColor.init(displayP3Red: 232/255, green: 242/255, blue: 249/255, alpha: 1) : (cell.backView.backgroundColor = UIColor.clear)
        
        return cell
        
    }
    
    
    func registerAndSetTableView() {
        tableView.register(UINib.init(nibName: "BaseDetailCell", bundle: nil), forCellReuseIdentifier: "baseDetailCell")
        tableView.register(UINib.init(nibName: "DetailedInfoCell", bundle: nil), forCellReuseIdentifier: "detailedCell")
        tableView.delegate = self
        tableView.dataSource = self
        tableView.rowHeight = 60
        tableView.cellLayoutMarginsFollowReadableWidth = true
    }
    
}

