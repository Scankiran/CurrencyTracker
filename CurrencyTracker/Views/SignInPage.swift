//
//  ProfileView.swift
//  CurrencyTracker
//
//  Created by Said Çankıran on 23.09.2020.
//  Copyright © 2020 Said Çankıran. All rights reserved.
//

import UIKit
import FirebaseAuth
import ARSLineProgress
class SignInPage: UIViewController {
    
    @IBOutlet weak var mailField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var rePasswordField: UITextField!
    @IBOutlet weak var userNameField: UITextField!
    
    var isFirst:Bool = true
    @IBOutlet weak var signUpFieldView: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
   
    func createAccountView() {
        //username ve mail istenecek
        //şifre iki defa sorulacak
    }
    
    
    @IBAction func signUp(_ sender: Any) {
        signUp()
    }
    
    @IBAction func login(_ sender: Any) {
        API.run.getUser(mailField.text!, passwordField.text!) { (user, err) in
            if let err = err {
                print(err.localizedDescription)
                return
            }
            
        }
    }
    
    
    
    @IBAction func backButton(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
}






extension SignInPage {
    func checkField() -> Bool{
        if !mailField.text!.isEmpty, !passwordField.text!.isEmpty, !rePasswordField.text!.isEmpty, !userNameField.text!.isEmpty {
            return true
        }
        
        return false
    }
    
    func signUp() {
        if isFirst {
            UIView.animate(withDuration: 0.7) {
                self.signUpFieldView.constant = 0
                self.view.layoutIfNeeded()
            }
            isFirst = false
        } else {
            if checkField() {
                API.run.saveUser(mailField.text!, passwordField.text!) { [self] (user, err) in
                    if let err = err {
                        print(err.localizedDescription)
                        ARSLineProgress.showFail()
                    } else {
                        //save user info
                        let data:[String:Any] = ["username":userNameField.text!]
                        API.run.saveInfo(data, user!)
                        let changeRequest = user?.createProfileChangeRequest()
                        changeRequest?.displayName = userNameField.text!
                        changeRequest?.commitChanges { (error) in
                            if let err = err {
                                print(err.localizedDescription)
                            }
                        }
                    }
                }
                ARSLineProgress.showSuccess()
            } else {
                ARSLineProgress.showFail()
            }
        }
    }
}
