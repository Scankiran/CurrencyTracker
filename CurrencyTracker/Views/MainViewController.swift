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
    
    let db = Firestore.firestore()
    
    var summaryDataCollection:[SummaryDataType] = []
    var detailedDataCollection:[DetailDataType] = []
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        registerAndSetTableView()
        giveDelegateToCollectionView()
        getSummaryData()
        tableView.backgroundView?.layer.cornerRadius = 20
        
        _ = Timer.scheduledTimer(timeInterval: 10, target: self, selector: #selector(getSummaryData), userInfo: nil, repeats: true)
    }
    
    @IBAction func changeInformation(_ sender: UISegmentedControl) {
        tableView.reloadData()
    }
    
    @IBAction func rightButton(_ sender: Any) {
        performSegue(withIdentifier: "detail", sender: self)
    }
}


//MARK: Data Controller
extension MainViewController {
    @objc func getSummaryData() {
        print("run")
        db.collection("general").document("summary").getDocument { (snapshot, err) in
            if let error = err {
                print(error.localizedDescription)
            } else {
                let data =  "\(snapshot!.data()!["last"]!)".data(using: .utf8)
                    
                do {
                    let json = try JSONDecoder().decode([SummaryDataType].self, from: data!)
                    self.summaryDataCollection = json
                    self.collectionView.reloadData()
                } catch {
                    print("Error during JSON serialization: \(error.localizedDescription)")

                }
            }
        }
        
        db.collection("general").document("all").getDocument { (snapshot, err) in
            if let error = err {
                print(error.localizedDescription)
            } else {
                let data =  "\(snapshot!.data()!["last"]!)".data(using: .utf8)
                do {
                    let json = try JSONDecoder().decode([DetailDataType].self, from: data!)
                    self.detailedDataCollection = json
                    self.tableView.reloadData()
                } catch {
                    print("Error during JSON serialization: \(error.localizedDescription)")

                }
            }
        }
    }
}




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
        
        return cell
        
        
    }
    
    
    func registerAndSetTableView() {
        tableView.register(UINib.init(nibName: "BaseDetailCell", bundle: nil), forCellReuseIdentifier: "baseDetailCell")
        tableView.register(UINib.init(nibName: "DetailedInfoCell", bundle: nil), forCellReuseIdentifier: "detailedCell")
        tableView.delegate = self
        tableView.dataSource = self
        tableView.rowHeight = 80
        tableView.cellLayoutMarginsFollowReadableWidth = true
    }
    
}

