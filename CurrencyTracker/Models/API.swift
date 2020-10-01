//
//  API.swift
//  CurrencyTracker
//
//  Created by Said Çankıran on 28.09.2020.
//  Copyright © 2020 Said Çankıran. All rights reserved.
//

import Foundation
import FirebaseAuth
import FirebaseFirestore

class API {
    static let run = API()
    
    let db = Firestore.firestore()
    
    var user:User?
    
    var summaryData:[SummaryDataType] = []
    var detailedData:[DetailDataType] = []
    
    
    
    
    func getUser(_ mail:String,_ password:String,handler:@escaping (_ user:User?,_ error:Error?)-> Void){
       
        Auth.auth().signIn(withEmail: mail, password: password) { (dataResult, error) in
            if let err = error {
                print(err.localizedDescription)
                handler(nil,error)
            } else {
                handler(dataResult!.user,nil)
            }
        }
 
    }
    
    
    
    
    func saveUser(_ mail:String,_ password:String,handler:@escaping (_ user:User?,_ error:Error?)-> Void) {
        
        Auth.auth().createUser(withEmail: mail, password: password) { (dataResult, error) in
            if let err = error {
                handler(nil,err)
            } else {
                handler(dataResult!.user,nil)
            }
        }
        
    }
    
    
    
    
    func getCurrencySummary(handler:@escaping (_ result: [SummaryDataType]?,_ error:Error?)-> Void) {

        db.collection("general").document("summary").getDocument { (snapshot, err) in
            if let error = err {
                handler(nil,error)
                print(error.localizedDescription)
            } else {
                let data =  "\(snapshot!.data()!["last"]!)".data(using: .utf8)
                    
                do {
                    let json = try JSONDecoder().decode([SummaryDataType].self, from: data!)
                    handler(json,nil)
                    self.summaryData = json
                } catch {
                    print("Error during JSON serialization: \(error.localizedDescription)")

                }
            }
        }
    }
    
    
    
    
    
    func getCurrencyDetailed(handler:@escaping (_ result: [DetailDataType]?,_ error:Error?)-> Void) {
        
        db.collection("general").document("all").getDocument { (snapshot, err) in
            if let error = err {
                print(error.localizedDescription)
                handler(nil,err)
            } else {
                let data =  "\(snapshot!.data()!["last"]!)".data(using: .utf8)
                do {
                    let json = try JSONDecoder().decode([DetailDataType].self, from: data!)
                    handler(json,nil)
                    self.detailedData = json
                } catch {
                    print("Error during JSON serialization: \(error.localizedDescription)")

                }
            }
        }
    }
    
    
    
    
    func getCurrencyDetail(_ currencyType:String,handler:@escaping (_ result:[String:Any]?,_ error:Error?)->Void) {
        db.collection("\(currencyType)").document("last").getDocument { (snapshot, err) in
            if let err = err {
                print(err.localizedDescription)
                handler(nil,err)
            } else {
                let generalInfo = snapshot!.data()!["generalInfo"]! as! Dictionary<String, String>
                let bankDataa = "\(snapshot!.data()!["banks"]!)".data(using: .utf8)!
                let changeRateData = "\(snapshot!.data()!["changeRate"]!)".data(using: .utf8)!
                
                do {
                    let bankData = try JSONDecoder.init().decode([BankDataType].self, from: bankDataa)
                    let changeRate = try JSONDecoder.init().decode([SummaryDataType].self, from: changeRateData)
                    handler(["bankData":bankData,"changeRate":changeRate,"name":generalInfo["name"]!,"value":generalInfo["buy"]!],nil)

                } catch  {
                    handler(nil,error as Error)
                    print(error.localizedDescription)
                }
            }
        }
        
    }
}
