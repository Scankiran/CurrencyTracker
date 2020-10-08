//
//  CoreDataController.swift
//  CurrencyTracker
//
//  Created by Said Çankıran on 1.10.2020.
//  Copyright © 2020 Said Çankıran. All rights reserved.
//

import Foundation
import CoreData
import UIKit
import FirebaseAuth; import FirebaseFirestore

class CoreDataController {
    static let run = CoreDataController()
    
    func getInvestment(handler: @escaping (_ result:[NSManagedObject]?,_ error:Error?)-> Void) {
        guard let appDelegate =
          UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        
        let managedContext =
          appDelegate.persistentContainer.viewContext
        
        //2
        let fetchRequest =
          NSFetchRequest<NSManagedObject>(entityName: "Investments")
        
        //3
        do {
            let data = try managedContext.fetch(fetchRequest)
            handler(data,nil)
            
        } catch let error as NSError {
            let err:Error = error as Error
            handler(nil,err)
        }
    }
    
    func deleteInvestment(_ object:NSManagedObject) -> Bool{
        guard let appDelegate =
          UIApplication.shared.delegate as? AppDelegate else {
            return false
        }
        
        let managedContext =
          appDelegate.persistentContainer.viewContext
        
        //2
        let fetchRequest =
          NSFetchRequest<NSManagedObject>(entityName: "Investments")
        
        //3
        do {
            let data = try managedContext.fetch(fetchRequest)
            for index in data {
                if index.isEqual(object) {
                    managedContext.delete(object)
                    try managedContext.save()
                    return true
                }
            }
        } catch let error as NSError {
            print(error.localizedDescription)
            return false
        }
        return false

    }
    
    
    func saveInvestment(_ name:String,_ type:String,_ value:Double,_ buyValue:Double, _ date:Date,handler: @escaping (_ result:Any?,_ error:Error?) -> Void) {
          
        guard let appDelegate =
            UIApplication.shared.delegate as? AppDelegate else {
            return
        }
          
          // 1
        let managedContext =
            appDelegate.persistentContainer.viewContext
          
          // 2
        let entity =
            NSEntityDescription.entity(forEntityName: "Investments",
                                       in: managedContext)!
          
        let entry = NSManagedObject(entity: entity,
                                       insertInto: managedContext)
          
          // 3
        let data:[String:Any] = ["name":name,"type":type,"value":value,"buyValue":buyValue,"date":date]
            
            entry.setValuesForKeys(data)
          // 4
          do {
            try managedContext.save()
            if Auth.auth().currentUser != nil {
                let db = Firestore.firestore()
                db.collection("users").document("\(Auth.auth().currentUser!.uid)").collection("investments").addDocument(data: data)
            }
            handler(true,nil)
          } catch let error as NSError {
            handler(false,error as Error)
            print("Could not save. \(error), \(error.userInfo)")
          }
    }
    
}
