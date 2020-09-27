//
//  ProfileView.swift
//  CurrencyTracker
//
//  Created by Said Çankıran on 23.09.2020.
//  Copyright © 2020 Said Çankıran. All rights reserved.
//

import UIKit
import FirebaseAuth
class ProfileView: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    //fotoğraf cacheleme yapılacak

    func checkUser() {
        if let user = Auth.auth().currentUser {
            //google butonu hesabı sil
            //apple butonu yatırımları sıfırla
            //giriş yap kaldır
            //hesap oluştur çıkış yap
            //fotoğrafı ata
        } else {
            //bildirim kısmı kapalı kalacak.
        }
    }
    
    func createAccountView() {
        //username ve mail istenecek
        //şifre iki defa sorulacak
    }
    
    @IBAction func backButton(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
}
