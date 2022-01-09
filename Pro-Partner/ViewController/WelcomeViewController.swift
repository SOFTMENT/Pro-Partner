//
//  ViewController.swift
//  My Breeders Store
//
//  Created by Apple on 04/11/21.
//

import UIKit
import Firebase
import FirebaseFirestoreSwift

class WelcomeViewController: UIViewController {
    let userDefaults = UserDefaults.standard
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //SUBSCRIBE TO TOPIC
        Messaging.messaging().subscribe(toTopic: "propartner"){ error in
            if error == nil{
                print("Subscribed to topic")
            }
            else{
                print("Not Subscribed to topic")
            }
        }
        
        if userDefaults.value(forKey: "appFirstTimeOpend") == nil {
            //if app is first time opened then it will be nil
            userDefaults.setValue(true, forKey: "appFirstTimeOpend")
            // signOut from FIRAuth
            do {
                try Auth.auth().signOut()
            }catch {
                
            }
            // go to beginning of app
        }
        
        if let user = Auth.auth().currentUser {
            var providerID = ""
            if let providerId = Auth.auth().currentUser!.providerData.first?.providerID {
                providerID = providerId
            }
            
            
            if providerID == "password"  {
                if !user.isEmailVerified {
                    self.beRootScreen(mIdentifier: Constants.StroyBoard.signInViewController)
                    return
                }
            }
                
            self.getUserData(uid: user.uid,showProgress: false)
            
        }
        else {
            DispatchQueue.main.async {
                self.beRootScreen(mIdentifier: Constants.StroyBoard.entryViewController)
            }
        }

    }


}

