//
//  SignUpViewController.swift
//  My Breeders Store
//
//  Created by Apple on 11/11/21.
//

import UIKit
import Firebase
import FirebaseFirestoreSwift

class SignUpViewController : UIViewController {
    
    
    @IBOutlet weak var signUp: UIButton!
    @IBOutlet weak var login: UILabel!
    @IBOutlet weak var password: UITextField!
    @IBOutlet weak var emailAddress: UITextField!
    @IBOutlet weak var lastName: UITextField!
    @IBOutlet weak var firstName: UITextField!
 

    
    
    override func viewDidLoad() {
        
        signUp.layer.cornerRadius = 12
        
        login.isUserInteractionEnabled = true
        login.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(loginBtnClicked)))
        
        password.delegate = self
        password.layer.cornerRadius = 12
        password.addBorder()
        password.changePlaceholderColour()
        
        emailAddress.delegate = self
        emailAddress.layer.cornerRadius = 12
        emailAddress.addBorder()
        emailAddress.changePlaceholderColour()
        
        firstName.delegate = self
        lastName.delegate = self
        
        firstName.addBorder()
        lastName.addBorder()
        
        firstName.changePlaceholderColour()
        lastName.changePlaceholderColour()
        
        firstName.layer.cornerRadius = 12
        lastName.layer.cornerRadius = 12
        
        view.isUserInteractionEnabled = true
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(hideKeyboard)))
        
        
        
        
    }
    
    @objc func hideKeyboard(){
        self.view.endEditing(true)
    }
    
 
    @objc func loginBtnClicked(){
        beRootScreen(mIdentifier: Constants.StroyBoard.signInViewController)
    }
    
    @IBAction func signUpBtnClicked(_ sender: Any) {
        
        if let sFirstName = firstName.text?.trimmingCharacters(in: .whitespacesAndNewlines), !sFirstName.isEmpty {
            if let sLastName = lastName.text?.trimmingCharacters(in: .whitespacesAndNewlines), !sLastName.isEmpty {
                if let sEmailAddress = emailAddress.text?.trimmingCharacters(in: .whitespacesAndNewlines), !sEmailAddress.isEmpty {
                    if let sPassword = password.text?.trimmingCharacters(in: .whitespacesAndNewlines), !sPassword.isEmpty {
                        self.ProgressHUDShow(text: "Creating An Account...")
                        Auth.auth().createUser(withEmail: sEmailAddress, password: sPassword) { result, error in
                            self.ProgressHUDHide()
                            if let error = error {
                                self.showError(error.localizedDescription)
                            }
                            else {
                                if let user = Auth.auth().currentUser {
                                    self.addUserData(data: ["name" : "\(sFirstName) \(sLastName)","email" : sEmailAddress,"date" : FieldValue.serverTimestamp(),"uid" : user.uid], uid: user.uid, type: "password")
                                }
                               
                            }
                        }
                    }
                    else {
                        self.showToast(message: "Enter First Name")
                    }
                }
                else {
                    self.showToast(message: "Enter First Name")
                }
            }
            else {
                self.showToast(message: "Enter First Name")
            }
        }
        else {
            self.showToast(message: "Enter First Name")
        }
    }
}

extension SignUpViewController : UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return true
    }
}
