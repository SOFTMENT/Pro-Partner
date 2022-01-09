//
//  Extensions.swift
//  My Breeders Store
//
//  Created by Apple on 07/11/21.
//


import UIKit
import FirebaseAuth
import Firebase
import MBProgressHUD




extension UITextView {
    
    func centerVerticalText() {
        
        let fitSize = CGSize(width: bounds.width, height: CGFloat.greatestFiniteMagnitude)
        let size = sizeThatFits(fitSize)
        let calculate = (bounds.size.height - size.height * zoomScale) / 2
        let offset = max(1, calculate)
        contentOffset.y = -offset
    }
}

extension UITextField {
    func setLeftPaddingPoints(_ amount:CGFloat){
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: amount, height: self.frame.size.height))
        self.leftView = paddingView
        self.leftViewMode = .always
    }
    func setRightPaddingPoints(_ amount:CGFloat) {
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: amount, height: self.frame.size.height))
        self.rightView = paddingView
        self.rightViewMode = .always
    }
    

 
    func changePlaceholderColour()  {
            attributedPlaceholder = NSAttributedString(string: placeholder ?? "",
                                                       attributes: [NSAttributedString.Key.foregroundColor: UIColor(red: 153/255, green: 153/255, blue: 153/255, alpha: 1)])
        }
        
        func addBorder() {
            layer.borderWidth = 1.5
            layer.borderColor = UIColor.white.cgColor
            setLeftPaddingPoints(12)
            setRightPaddingPoints(12)
        }
        
}

extension AuthErrorCode {
    
    var errorMessage: String {
        switch self {
        case .emailAlreadyInUse:
            return "The email is already in use with another account"
        case .userNotFound:
            return "Account not found for the specified user. Please check and try again"
        case .userDisabled:
            return "Your account has been disabled. Please contact support."
        case .invalidEmail, .invalidSender, .invalidRecipientEmail:
            return "Please enter a valid email"
        case .networkError:
            return "Network error. Please try again."
        case .weakPassword:
            return "Your password is too weak. The password must be 6 characters long or more."
        case .wrongPassword:
            return "Your password is incorrect. Please try again or use 'Forgot password' to reset your password"
        case .accountExistsWithDifferentCredential:
            return "An account already exists with the same email address but different sign-in method."
            
        default:
            return "Unknown error occurred"
        }
    }
}

extension Date {
    
    func timeAgoSinceDate() -> String {
        
        // From Time
        let fromDate = self
        
        // To Time
        let toDate = Date()
        
        // Estimation
        // Year
        if let interval = Calendar.current.dateComponents([.year], from: fromDate, to: toDate).year, interval > 0  {
            
            return interval == 1 ? "\(interval)" + " " + "year ago" : "\(interval)" + " " + "years ago"
        }
        
        // Month
        if let interval = Calendar.current.dateComponents([.month], from: fromDate, to: toDate).month, interval > 0  {
            
            return interval == 1 ? "\(interval)" + " " + "month ago" : "\(interval)" + " " + "months ago"
        }
        
        // Day
        if let interval = Calendar.current.dateComponents([.day], from: fromDate, to: toDate).day, interval > 0  {
            
            return interval == 1 ? "\(interval)" + " " + "day ago" : "\(interval)" + " " + "days ago"
        }
        
        // Hours
        if let interval = Calendar.current.dateComponents([.hour], from: fromDate, to: toDate).hour, interval > 0 {
            
            return interval == 1 ? "\(interval)" + " " + "hour ago" : "\(interval)" + " " + "hours ago"
        }
        
        // Minute
        if let interval = Calendar.current.dateComponents([.minute], from: fromDate, to: toDate).minute, interval > 0 {
            
            return interval == 1 ? "\(interval)" + " " + "minute ago" : "\(interval)" + " " + "minutes ago"
        }
        
        return "a moment ago"
    }
}



extension UIViewController {
    
    func addFav(by dogId : String, uid : String,completion : @escaping (Bool) -> Void)  {
        
        Firestore.firestore().collection("Users").document(uid).collection("Favorites").document(dogId).setData(["id" : dogId,"date" : FieldValue.serverTimestamp()]) { error in
            if error == nil {
                completion(true)
            }
            else {
                completion(false)
            }
        }
 
    }
    
    
    func deleteFav(by dogId : String, uid : String,completion : @escaping (Bool) -> Void)  {
        
        Firestore.firestore().collection("Users").document(uid).collection("Favorites").document(dogId).delete { error in
            if error == nil {
                completion(true)
            }
            else {
                completion(false)
            }
        }
        
    }
    
    public func checkFavoritesStatus(uid : String, dogId : String,completion : @escaping (Bool) -> Void){
        
        
        let docRef = Firestore.firestore().collection("Users").document(uid).collection("Favorites").document(dogId)
        
        docRef.getDocument { (document, error) in
            if error == nil {
                if let document  = document {
                    if document.exists {
                        
                        completion(true)
                        
                    }
                    else{
                        completion(false)
                    }
                    
                }
                else {
                    completion(false)
                }
            }
        }
        
        
    }
    
    func getUserData(uid : String, showProgress : Bool)  {
        if showProgress {
            ProgressHUDShow(text: "")
        }
        
        Firestore.firestore().collection("Users").document(uid).getDocument { (snapshot, error) in
            if showProgress {
                MBProgressHUD.hide(for: self.view, animated: true)
            }
            
            if error != nil {
                
                self.showError(error!.localizedDescription)
            }
            else {
                
                if let snapshot = snapshot {
                    if snapshot.exists {
                        do {
                            if let user = try snapshot.data(as: UserModel.self){
                                UserModel.data = user
                                if user.uid == "Y5kT88R3oFMyIkD1anEh6WBl0kE2" {
                                  //  self.beRootScreen(mIdentifier: Constants.StroyBoard.adminViewController)
                                }
                                else if user.gender == "" {
                                    self.beRootScreen(mIdentifier: Constants.StroyBoard.setupUserProfileViewController)
                                }
                                else {
                                    self.beRootScreen(mIdentifier: Constants.StroyBoard.userTabBarViewController)
                                }
        
                                
                            }
                            else {
                                if let user = Auth.auth().currentUser {
                                    user.delete { error in
                                        if error != nil {
                                            print(error!.localizedDescription)
                                        }
                                        
                                    }
                                    self.showError("Your account is not available. Please register your account.")
                                }
                            }
                        }
                        catch {
                            print(error.localizedDescription)
                        }
                        
                    }
                    else {
                        if let user = Auth.auth().currentUser {
                            user.delete { error in
                                if error != nil {
                                    print(error!.localizedDescription)
                                }
                                
                            }
                            self.showError("Your account is not available. Please register your account.")
                        }
                    }
                    
                }
                
                
                
            }
        }
        
    }
    
    
    func sendEmailVerificationLink(goBack : Bool) {
        
        
        Auth.auth().currentUser!.sendEmailVerification(completion: nil)
        
        let alert = UIAlertController(title: "Verify Your Email", message: "We have sent email verification link on your mail address.Please Verify email and continue to Sign In.", preferredStyle: .alert)
        
        let okAction = UIAlertAction(title: "Ok", style: .default) { (action) in
            self.dismiss(animated: true) {
                if goBack {
                    self.beRootScreen(mIdentifier: Constants.StroyBoard.signInViewController)
                }
                
            }
            
        }
        
        alert.addAction(okAction)
        
        self.present(alert, animated: true, completion: nil)
    }
    
    
   
    func ProgressHUDShow(text : String) {
        let loading = MBProgressHUD.showAdded(to: self.view, animated: true)
        loading.mode = .indeterminate
        loading.label.text =  text
        loading.label.textColor = UIColor(red: 52/255, green: 52/255, blue: 52/255, alpha: 1)
        loading.label.font = UIFont(name: "RobotoCondensed-Regular", size: 13)
    }
    
    func ProgressHUDHide(){
        MBProgressHUD.hide(for: self.view, animated: true)
    }
    
    func showToast(message : String) {
        
        let toastLabel = UILabel(frame: CGRect(x: self.view.frame.size.width/2 - 115, y: self.view.frame.size.height/2, width: 240, height: 36))
        toastLabel.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        toastLabel.textColor = UIColor.white
        toastLabel.font = UIFont(name: "RobotoCondensed-Regular", size: 13)
        toastLabel.textAlignment = .center;
        toastLabel.text = message
        toastLabel.alpha = 1.0
        toastLabel.layer.cornerRadius = 10;
        toastLabel.clipsToBounds  =  true
        self.view.addSubview(toastLabel)
        UIView.animate(withDuration: 5.0, delay: 0.1, options: .curveEaseIn, animations: {
            toastLabel.alpha = 0.0
        }, completion: {(isCompleted) in
            toastLabel.removeFromSuperview()
        })
    }
    
    func authWithFirebase(credential : AuthCredential, type : String,displayName : String) {
        
        ProgressHUDShow(text: "Loading...")
        
        Auth.auth().signIn(with: credential) { (authResult, error) in
            MBProgressHUD.hide(for: self.view, animated: true)
            if error != nil {
                
                self.handleError(error: error!)
            }
            else {
                let user = authResult!.user
                let ref =  FirebaseStoreManager.db.collection("Users").document(user.uid)
                ref.getDocument { (snapshot, error) in
                    if error != nil {
                        self.showError(error!.localizedDescription)
                    }
                    else {
                        if let doc = snapshot {
                            if doc.exists {
                                self.getUserData(uid: user.uid, showProgress: true)
                                
                            }
                            else {
                                
                                var profilepic = ""
                                var emailId = ""
                                let provider =  user.providerData
                                var name = ""
                                for firUserInfo in provider {
                                    if let email = firUserInfo.email {
                                        emailId = email
                                    }
                                }
                                
                                if type == "apple" {
                                    name = displayName
                                }
                                else {
                                    name = user.displayName!.capitalized
                                }
                                
                               
                                if type == "facebook" {
                                    profilepic = user.photoURL!.absoluteString + "?type=large"
                                }
                                else if type == "google"{
                                    profilepic = user.photoURL!.absoluteString.replacingOccurrences(of: "s96-c", with: "s512-c")
                                }
                                let data = ["name" : name, "email" : emailId, "uid" :  user.uid, "registredAt" :  user.metadata.creationDate!,"profile" : profilepic,"regiType" : type] as [String : Any]
                                self.addUserData(data:data , uid: user.uid, type: type)
                            }
                        }
                        
                    }
                }
                
            }
            
        }
    }
    
    func getBusinessData(by uid : String, completion : @escaping (UserModel?) -> Void) {
        
       
        
        FirebaseStoreManager.db.collection("Users").document(uid).getDocument { snapshot, error in
            if error == nil {
                if let snapshot = snapshot, snapshot.exists {
                    if let businessModel = try? snapshot.data(as: UserModel.self, decoder: nil) {
                        completion(businessModel)
                    }
                    else {
                        completion(nil)
                    }
                }
                else {
                    completion(nil)
                }
            }
            else {
                completion(nil)
            }
            
        }
    }
    
    func addUserData(data : [String : Any], uid : String,type : String) {
        
        ProgressHUDShow(text: "Wait...")
        
        FirebaseStoreManager.db.collection("Users").document(uid).setData(data) { (error) in
            
            self.ProgressHUDHide()
            
            if error != nil {
                self.showError(error!.localizedDescription)
            }
            else {
                if type == "password" {
                    self.sendEmailVerificationLink(goBack: false)
                }
                else {
                    self.getUserData(uid: uid, showProgress: true)
                }
               
            }
        }
        
    }
    
    func sendPushNotification() {
        
        //1. Create the alert controller.
        let alert = UIAlertController(title: "Notification", message: "Send Notification to All Users", preferredStyle: .alert)
        
        //2. Add the text field. You can configure it however you need.
        alert.addTextField { (textField) in
            textField.placeholder = "Enter Title"
        }
        //2. Add the text field. You can configure it however you need.
        alert.addTextField { (textField) in
            textField.placeholder = "Enter Message"
        }
        
        // 3. Grab the value from the text field, and print it when the user clicks OK.
        alert.addAction(UIAlertAction(title: "Send", style: .default, handler: { [weak alert] (_) in
            let textField = alert?.textFields![0].text?.trimmingCharacters(in: .whitespacesAndNewlines) // Force unwrapping because we know it exists.
            let textField1 = alert?.textFields![1].text?.trimmingCharacters(in: .whitespacesAndNewlines)
            if (!textField!.isEmpty && !textField1!.isEmpty) {
                PushNotificationSender().sendPushNotificationToTopic(title: textField!, body: textField1!)
                self.showToast(message: "Notification has been sent")
            }
            else {
                self.showToast(message: "Please Enter Title & Message")
            }
        }))
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (action) in
            
            alert.dismiss(animated: true, completion: nil)
        }))
        
        // 4. Present the alert.
        self.present(alert, animated: true, completion: nil)
        
    }
    
  
    
    func navigateToAnotherScreen(mIdentifier : String)  {
        
        let destinationVC = getViewControllerUsingIdentifier(mIdentifier: mIdentifier)
        destinationVC.modalPresentationStyle = .fullScreen
        present(destinationVC, animated: true) {
            
        }
        
    }
    
    func myPerformSegue(mIdentifier : String)  {
        performSegue(withIdentifier: mIdentifier, sender: nil)
        
    }
    
    
    
    func getViewControllerUsingIdentifier(mIdentifier : String) -> UIViewController{
        
        let mainStoryboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        switch mIdentifier {
        case Constants.StroyBoard.signInViewController:
            return (mainStoryboard.instantiateViewController(identifier: mIdentifier) as? LoginViewController)!
            
        case Constants.StroyBoard.signUpViewController:
            return (mainStoryboard.instantiateViewController(identifier: mIdentifier) as? SignUpViewController)!
            
        case Constants.StroyBoard.entryViewController:
            return (mainStoryboard.instantiateViewController(identifier: mIdentifier) as? EntryViewController)!
            
        case Constants.StroyBoard.setupUserProfileViewController:
            return (mainStoryboard.instantiateViewController(identifier: mIdentifier) as? SetupUserProfileViewController)!
            
        case Constants.StroyBoard.userTabBarViewController:
            return (mainStoryboard.instantiateViewController(identifier: mIdentifier) as? UITabBarController)!
            

        default:
            return (mainStoryboard.instantiateViewController(identifier: Constants.StroyBoard.signInViewController) as? LoginViewController)!
        }
    }
    
    func beRootScreen(mIdentifier : String) {
        
        
        guard let window = self.view.window else {
            self.view.window?.rootViewController = getViewControllerUsingIdentifier(mIdentifier: mIdentifier)
            self.view.window?.makeKeyAndVisible()
            return
        }
        
        window.rootViewController = getViewControllerUsingIdentifier(mIdentifier: mIdentifier)
        window.makeKeyAndVisible()
        UIView.transition(with: window,
                          duration: 0.3,
                          options: .transitionCrossDissolve,
                          animations: nil,
                          completion: nil)
        
    }
    
    
    
    func convertDateAndTimeFormater(_ date: Date) -> String
    {
        let df = DateFormatter()
        df.dateFormat = "dd-MMM-yyyy hh:mm a"
        df.timeZone = TimeZone(abbreviation: "UTC")
        df.timeZone = TimeZone.current
        return df.string(from: date)
        
    }
    
    func convertDateFormater(_ date: Date) -> String
    {
        let df = DateFormatter()
        df.dateFormat = "dd-MMM-yyyy"
        df.timeZone = TimeZone(abbreviation: "UTC")
        df.timeZone = TimeZone.current
        return df.string(from: date)
        
    }
    
    func handleError(error: Error) {
        if let errorCode = AuthErrorCode(rawValue: error._code) {
            
            showError(errorCode.errorMessage)
        }
    }
    
    func showError(_ message : String) {
        let alert = UIAlertController(title: "ERROR", message: message, preferredStyle: .alert)
        
        let okAction = UIAlertAction(title: "Ok", style: .default, handler: nil)
        
        alert.addAction(okAction)
        
        self.present(alert, animated: true, completion: nil)
        
    }
    
    func showMessage(title : String,message : String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        let okAction = UIAlertAction(title: "Ok", style: .default) { alert in
            if title == "Thank You" {
                self.dismiss(animated: true, completion: nil)
            }
        }
        
        alert.addAction(okAction)
        
        self.present(alert, animated: true, completion: nil)
        
    }


    
    public func logout(){
        do {
            try Auth.auth().signOut()
            self.beRootScreen(mIdentifier: Constants.StroyBoard.signInViewController)
        }
        catch {
            
        }
    }
    
}



extension NSLayoutConstraint {
    
    override public var description: String {
        let id = identifier ?? ""
        return "id: \(id), constant: \(constant)" //you may print whatever you want here
    }
}


extension UIImageView {
    func makeRounded() {
        
        //self.layer.borderWidth = 1
        self.layer.masksToBounds = false
        // self.layer.borderColor = UIColor.gray.cgColor
        self.layer.cornerRadius = self.frame.height / 2
        self.clipsToBounds = true
        
    }
    
    
    
    
}


extension UIView {
    func dropShadow(scale: Bool = true) {
        layer.masksToBounds = false
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.2
        layer.shadowOffset = .zero
        
        layer.shadowRadius = 1
        layer.shouldRasterize = true
        layer.rasterizationScale = scale ? UIScreen.main.scale : 1
    }
    
    public var safeAreaFrame: CGFloat {
        if #available(iOS 13.0, *) {
            let window = UIApplication.shared.windows[0]
            return window.safeAreaInsets.bottom
        }
        else  {
            let window = UIApplication.shared.keyWindow
            return window!.safeAreaInsets.bottom
        }
    }
}
