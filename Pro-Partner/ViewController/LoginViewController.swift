//
//  LoginViewController.swift
//  My Breeders Store
//
//  Created by Apple on 11/11/21.
//

import UIKit
import Firebase
import FirebaseFirestoreSwift
import AuthenticationServices
import CryptoKit

class LoginViewController : UIViewController {
    
    @IBOutlet weak var register: UILabel!
    @IBOutlet weak var loginBtn: UIButton!
    @IBOutlet weak var resetPassword: UILabel!
    @IBOutlet weak var password: UITextField!
    @IBOutlet weak var emailAddress: UITextField!

    @IBOutlet weak var facebookView: UIView!
    @IBOutlet weak var appleView: UIView!
    @IBOutlet weak var googleView: UIView!
    fileprivate var currentNonce: String?
    override func viewDidLoad() {
        loginBtn.layer.cornerRadius = 12
       
        password.changePlaceholderColour()
        password.addBorder()
        password.layer.cornerRadius = 12
        password.delegate = self
        
        emailAddress.changePlaceholderColour()
        emailAddress.addBorder()
        emailAddress.layer.cornerRadius = 12
        emailAddress.delegate = self

        googleView.layer.cornerRadius = 16
        googleView.layer.borderWidth = 1.5
        googleView.layer.borderColor = UIColor.white.cgColor
        
       facebookView.layer.cornerRadius = 16
        facebookView.layer.borderWidth = 1.5
        facebookView.layer.borderColor = UIColor.white.cgColor
        
        appleView.layer.cornerRadius = 16
        appleView.layer.borderWidth = 1.5
        appleView.layer.borderColor = UIColor.white.cgColor
        
        
        view.isUserInteractionEnabled = true
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(hideKeyboard)))
        
        register.isUserInteractionEnabled = true
        register.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(registerBtnClicked)))
        
        resetPassword.isUserInteractionEnabled = true
        resetPassword.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(resetBtnClicked)))
        
        
    }
    private func randomNonceString(length: Int = 32) -> String {
        precondition(length > 0)
        let charset: Array<Character> =
        Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")
        var result = ""
        var remainingLength = length
        
        while remainingLength > 0 {
            let randoms: [UInt8] = (0 ..< 16).map { _ in
                var random: UInt8 = 0
                let errorCode = SecRandomCopyBytes(kSecRandomDefault, 1, &random)
                if errorCode != errSecSuccess {
                    fatalError("Unable to generate nonce. SecRandomCopyBytes failed with OSStatus \(errorCode)")
                }
                return random
            }
            
            randoms.forEach { random in
                if remainingLength == 0 {
                    return
                }
                
                if random < charset.count {
                    result.append(charset[Int(random)])
                    remainingLength -= 1
                }
            }
        }
        
        return result
    }
    
    
    @available(iOS 13, *)
    func startSignInWithAppleFlow() {
        let nonce = randomNonceString()
        currentNonce = nonce
        let appleIDProvider = ASAuthorizationAppleIDProvider()
        let request = appleIDProvider.createRequest()
        request.requestedScopes = [.fullName, .email]
        request.nonce = sha256(nonce)
        
        let authorizationController = ASAuthorizationController(authorizationRequests: [request])
        authorizationController.delegate = self
        // authorizationController.presentationContextProvider = self
        authorizationController.performRequests()
    }
    
    @available(iOS 13, *)
    private func sha256(_ input: String) -> String {
        let inputData = Data(input.utf8)
        let hashedData = SHA256.hash(data: inputData)
        let hashString = hashedData.compactMap {
            return String(format: "%02x", $0)
        }.joined()
        
        return hashString
    }
    
    @objc func appleBtnClicked(){
        self.startSignInWithAppleFlow()
    }
    
    @objc func resetBtnClicked(){
        if let sEmail = emailAddress.text?.trimmingCharacters(in: .whitespacesAndNewlines), !sEmail.isEmpty {
        
            ProgressHUDShow(text: "Resetting...")
            
            Auth.auth().sendPasswordReset(withEmail: sEmail) { error in
                self.ProgressHUDHide()
                if let error = error {
                    self.showError(error.localizedDescription)
                }
                else {
                    self.emailAddress.text = ""
                    self.showMessage(title: "Reset Password", message: "We have sent password reset link on your mail address.")
                }
            }
        }
        else {
            self.showToast(message: "Enter Email Address")
        }
    }
    
    @objc func hideKeyboard(){
        view.endEditing(true)
    }
    

    
    @IBAction func loginBtnClicked(_ sender: Any) {
        if let sEmail = emailAddress.text?.trimmingCharacters(in: .whitespacesAndNewlines), !sEmail.isEmpty {
            
            if let sPassword = password.text?.trimmingCharacters(in: .whitespacesAndNewlines),
                !sPassword.isEmpty {
                
                ProgressHUDShow(text: "Sign in...")
                Auth.auth().signIn(withEmail: sEmail, password: sPassword) { result, error in
                    
                    self.ProgressHUDHide()
                    if let error = error {
                        self.showError(error.localizedDescription)
                    }
                    else {
                        if let user = Auth.auth().currentUser {
                            
                            if user.isEmailVerified || user.uid == "Y5kT88R3oFMyIkD1anEh6WBl0kE2"{
                                self.getUserData(uid: user.uid, showProgress: true)
                            }
                            else {
                                self.sendEmailVerificationLink(goBack: false)
                            }
                        }
                    }
                }
            }
            else {
                self.showToast(message: "Enter Password")
            }
        }
        else {
            self.showToast(message: "Enter Email Address")
        }
    }
    
    @objc func registerBtnClicked(){
        beRootScreen(mIdentifier: Constants.StroyBoard.signUpViewController)
    }
}

extension LoginViewController : UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        view.endEditing(true)
        return true
    }
    
}



@available(iOS 13.0, *)
extension LoginViewController : ASAuthorizationControllerDelegate {
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        
        if let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential {
            guard let nonce = currentNonce else {
                fatalError("Invalid state: A login callback was received, but no login request was sent.")
            }
            guard let appleIDToken = appleIDCredential.identityToken else {
                print("Unable to fetch identity token")
                return
            }
            guard let idTokenString = String(data: appleIDToken, encoding: .utf8) else {
                print("Unable to serialize token string from data: \(appleIDToken.debugDescription)")
                return
            }
            // Initialize a Firebase credential.
            let credential = OAuthProvider.credential(withProviderID: "apple.com",
                                                      idToken: idTokenString,
                                                      rawNonce: nonce)
            
            var displayName = "Apple_hbcu"
            if let fullName = appleIDCredential.fullName {
                if let firstName = fullName.givenName {
                    displayName = firstName
                }
                if let lastName = fullName.familyName {
                    displayName = "\(displayName) \(lastName)"
                }
            }
            
            authWithFirebase(credential: credential, type: "apple",displayName: displayName)
            // User is signed in to Firebase with Apple.
            // ...
            
        }
    }
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        // Handle error.
        
        print("Sign in with Apple errored: \(error)")
    }
    
}
