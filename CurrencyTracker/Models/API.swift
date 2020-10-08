//
//  API.swift
//  CurrencyTracker
//
//  Created by Said Çankıran on 28.09.2020.
//  Copyright © 2020 Said Çankıran. All rights reserved.
//

import Foundation
import FirebaseAuth
import FirebaseFirestore; import FirebaseStorage
import Kingfisher

class API {
    static let run = API()
    
    let db = Firestore.firestore()
    let cache = ImageCache.default
    let storage = Storage.storage().reference()
    var user:User?
    
    var summaryData:[SummaryDataType] = []
    var detailedData:[DetailDataType] = []
    
    
    
    
    
    func uploadImage(_ data:Data) {
        cache.removeImage(forKey: Auth.auth().currentUser!.uid)
        let path = storage.child("users/\(Auth.auth().currentUser!.uid)")
        
        let metaData = StorageMetadata()
        metaData.contentType = "image/jpeg"
        
        path.putData(data, metadata: metaData) { (metaData, err) in
            if let error = err {
                print(error.localizedDescription)
                return
            }else{
                //store downloadURL
                path.downloadURL { (url, error) in
                    if let err = error {
                        print(err.localizedDescription)
                        return
                    }
                    else {
                        let changeRequest = Auth.auth().currentUser!.createProfileChangeRequest()
                        changeRequest.photoURL = url
                        changeRequest.commitChanges { (error) in
                            if let err = error {
                                print(err.localizedDescription)
                            }
                        }
                    }
                }
            }
        }
    }
    
    
    func getUser(_ mail:String,_ password:String,handler:@escaping (_ user:User?,_ error:Error?)-> Void){
       
        Auth.auth().signIn(withEmail: mail, password: password) { (dataResult, error) in
            if let err = error {
                print(err.localizedDescription)
                handler(nil,error)
            } else {
                handler(dataResult!.user,nil)
            }
        }
        
        print(Auth.auth().currentUser)
 
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
    
    
    func saveInfo(_ data:[String:Any],_ user:User) {
        db.collection("users").document(user.uid).setData(data)
    }
    
    
    func getImage(_ userUID:String, handler:@escaping(_ image:UIImage?,_ error:Error?)-> Void) {
        cache.memoryStorage.config.totalCostLimit = 1
        
        if !cache.isCached(forKey: userUID) {
            let downloader = ImageDownloader.default
            
            //Show network activity indicator
            UIApplication.shared.isNetworkActivityIndicatorVisible = true
            
            //Download image
            if let url = Auth.auth().currentUser?.photoURL {
                downloader.downloadImage(with: url, completionHandler:  { result in
                    switch result {
                    case .success(let value):
                        self.cache.storeToDisk(value.originalData, forKey: userUID)
                        handler(value.image, nil)
                    case .failure(let error):
                        handler(nil,error)
                    }
                })
            } else {
                handler(UIImage.init(named: "no_image"),nil)
            }
            UIApplication.shared.isNetworkActivityIndicatorVisible = false

        } else {
            //Get image from cache.
            cache.retrieveImage(forKey: userUID) { result in
                switch result {
                    case .success(let value):
                        handler(value.image,nil)

                    case .failure(let error):
                        handler(nil,error)// The error happens
                    }
            }
        }
        
 
    }
}


extension UIImage {
    enum JPEGQuality: CGFloat {
        case lowest  = 0
        case low     = 0.25
        case medium  = 0.5
        case high    = 0.75
        case highest = 1
    }

    /// Returns the data for the specified image in JPEG format.
    /// If the image object’s underlying image data has been purged, calling this function forces that data to be reloaded into memory.
    /// - returns: A data object containing the JPEG data, or nil if there was a problem generating the data. This function may return nil if the image has no data or if the underlying CGImageRef contains data in an unsupported bitmap format.
    func compress(_ jpegQuality: JPEGQuality) -> Data? {
        return jpegData(compressionQuality: jpegQuality.rawValue)
    }
}
