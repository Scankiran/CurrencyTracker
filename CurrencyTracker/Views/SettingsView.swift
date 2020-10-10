//
//  SettingsView.swift
//  CurrencyTracker
//
//  Created by Said Çankıran on 7.10.2020.
//  Copyright © 2020 Said Çankıran. All rights reserved.
//

import UIKit
import FirebaseAuth
import MessageUI
import Kingfisher
class SettingsView: UIViewController, MFMailComposeViewControllerDelegate, UIImagePickerControllerDelegate & UINavigationControllerDelegate {

    @IBOutlet weak var userImage: UIImageView!
    @IBOutlet weak var userNameField: UITextField!
    @IBOutlet weak var userMoneyField: UITextField!
    @IBOutlet weak var notificationSwitch: UISwitch!
    var imagePicker = UIImagePickerController()
    let currentUser = Auth.auth().currentUser!
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        imagePicker.delegate = self
    }
    @IBAction func updateImage(_ sender: UIButton) {
        if UIImagePickerController.isSourceTypeAvailable(.savedPhotosAlbum){
                   print("Button capture")

                   imagePicker.delegate = self
                   imagePicker.sourceType = .savedPhotosAlbum
                   imagePicker.allowsEditing = true

                   present(imagePicker, animated: true, completion: nil)
        	}
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        self.dismiss(animated: true) {
            print(info)
            let image = info[.editedImage] as! UIImage
            self.userImage.image = image
            let imageUrl = "\(info[.imageURL]!)"
            
            let compressed = image.compress(.medium)
            API.run.uploadImage(compressed!,String(imageUrl.split(separator: "/").last!))
//            API.run.uploadImage(image.compress(.medium)!)
            
        }
    }
    
    
    
    @IBAction func updateUserName(_ sender: UIButton) {
        if !userNameField.isEnabled {
            userNameField.isEnabled = true
            sender.setTitle("Güncelle", for: .normal)
        } else {
            API.run.saveInfo(["username" : userNameField.text!], currentUser)
            let changeRequest = currentUser.createProfileChangeRequest()
            changeRequest.displayName = userNameField.text!
            
            changeRequest.commitChanges { (error) in
                if let err = error {
                    print(err.localizedDescription)
                }
            }
            userNameField.isEnabled = false
            sender.setTitle("Düzenle", for: .normal)
        }
    }
    
    @IBAction func updateMoney(_ sender: Any) {
        createAlert()
    }
    
    @IBAction func logout(_ sender: Any) {
        try? Auth.auth().signOut()
    }
    
    @IBAction func sendMail(_ sender: Any) {
        sendEmail()
    }
    
    @IBAction func updatePasswrod(_ sender: Any) {
        changePassword()
    }
    
    @IBAction func syncProcess(_ sender: Any) {
        sync()
    }
    
    @IBAction func back(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
}


extension SettingsView {
    //MARK: Setup View
    func setupView() {
        userNameField.text = Auth.auth().currentUser?.displayName
        userMoneyField.text = UserDefaults.standard.value(forKey: "userMoney") as? String ?? ""
        
        API.run.getImage(Auth.auth().currentUser!.uid) { (image, err) in
            if let err = err {
                print(err.localizedDescription)
            } else {
                if image != nil {
                    self.userImage.image = image!
                }
            }
        }
    }
    
    
    //MARK: Mail
    func sendEmail() {
        if MFMailComposeViewController.canSendMail() {
            let mail = MFMailComposeViewController()
            mail.mailComposeDelegate = self
            mail.setToRecipients(["s.cankiran@hotmail.com"])
            mail.setMessageBody("<p>Lütfen çekinmeden bana yazın.</p>", isHTML: true)

            present(mail, animated: true)
        } else {
            // show failure alert
        }
    }

    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true)
    }
    
    
    
    //MARK: Update Money Alert
    @objc func createAlert() {
        let alert = UIAlertController.init(title: "Ne kadar paranız var?", message: "Girdiğiniz miktar yatırımlarınızdan önceki miktarı belirtmelidir. ", preferredStyle: .alert)
        
            alert.addTextField { (textField) in
            textField.placeholder = "Para Miktarınız"
            textField.textAlignment = .center
        }
        
        let save = UIAlertAction.init(title: "Güncelle", style: .default) { (action) in
            
            if let text = alert.textFields![0].text {
                UserDefaults.standard.set(text, forKey: "userMoney")
                API.run.saveInfo(["userMoney":text], Auth.auth().currentUser!)
                //Yatırım yapılabilecek parayı burda kayıtlı olarak tuttum. Eğer daha önceden kayıt edilmişse güncel parayı eski paranın üzerine ekledim.
                if UserDefaults.standard.value(forKey: "restMoney") == nil {
                    UserDefaults.standard.set(text, forKey: "restMoney")
                    API.run.saveInfo(["restMoney":text], Auth.auth().currentUser!)
                } else {
                    let value = Double(text)!
                    let restMoney = Double(UserDefaults.standard.value(forKey: "restMoney") as! String)!
                    UserDefaults.standard.set("\(value + restMoney)", forKey: "restMoney")
                    API.run.saveInfo(["restMoney":"\(value + restMoney)"], Auth.auth().currentUser!)
                }
                
                self.userMoneyField.text = alert.textFields![0].text
            }
        }
        
        let cancel = UIAlertAction.init(title: "Vazgeç", style: .cancel, handler: nil)
        
        alert.addAction(cancel)
        alert.addAction(save)
        self.present(alert,animated: true)
    }
    
    //MARK: Change Password
    @objc func changePassword() {
        let alert = UIAlertController.init(title: "Şifre Değiştir", message: "Lütfen önce eski şifrenizi, daha sonra yeni şifrenizi giriniz.", preferredStyle: .alert)
        
            alert.addTextField { (textField) in
            textField.placeholder = "Eski Şifreniz"
            textField.textAlignment = .center
            textField.textContentType = .password

        }
        
        alert.addTextField { (textField) in
            textField.placeholder = "Yeni şifreniz?"
            textField.textAlignment = .center
            textField.textContentType = .newPassword
        }
        
        
        let save = UIAlertAction.init(title: "Güncelle", style: .default) { (action) in
            
            Auth.auth().signIn(withEmail: self.currentUser.email!, password: alert.textFields![0].text!) { (user, err) in
                if let err = err {
                    print(err)
                } else {
                    self.currentUser.updatePassword(to: alert.textFields![1].text!) { (err) in
                        if let err = err {
                            print(err.localizedDescription)
                        }
                    }
                }
            }
        }
        
        let cancel = UIAlertAction.init(title: "Vazgeç", style: .cancel, handler: nil)
        
        alert.addAction(cancel)
        alert.addAction(save)
        self.present(alert,animated: true)
    }
    
    
    //MARK: Sync
    func sync() {
        CoreDataController.run.getInvestment { (objects, err) in
            if let err = err {
                print(err.localizedDescription)
            } else {
                for object in objects! {
                    let dict = object.dictionaryWithValues(forKeys: Array(object.entity.attributesByName.keys))
                    API.run.saveInfo(dict, Auth.auth().currentUser!)
                }
            }
        }
    }
}
