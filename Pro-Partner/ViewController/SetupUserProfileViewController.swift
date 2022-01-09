//
//  SetupUserProfileViewController.swift
//  Pro-Partner
//
//  Created by Apple on 18/12/21.
//

import UIKit
import CropViewController
import Firebase
import FirebaseFirestoreSwift

class SetupUserProfileViewController : UIViewController {
    
    
    var gender : String = ""
    @IBOutlet weak var profilepic: UIImageView!
    @IBOutlet weak var maleBtn: UIButton!
    @IBOutlet weak var femaleBtn: UIButton!
    @IBOutlet weak var submitBtn: UIButton!
    @IBOutlet weak var age: UITextField!
    var downloadURL : String = ""
    
    override func viewDidLoad() {
       
        self.ProgressHUDShow(text: "Profile Updating...")
        
        profilepic.makeRounded()
        
        maleBtn.layer.cornerRadius = 12
        femaleBtn.layer.cornerRadius = 12
        
        age.addBorder()
        age.layer.cornerRadius = 12
        age.changePlaceholderColour()
        age.delegate = self
        
        submitBtn.layer.cornerRadius = 12
        
        profilepic.isUserInteractionEnabled = true
        profilepic.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(imageViewClicked)))
        
        view.isUserInteractionEnabled = true
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(hideKeyboard)))
    }
    
    
    
    @objc func hideKeyboard(){
        self.view.endEditing(true)
    }
    
    @IBAction func maleBtnClicked(_ sender: Any) {
        gender = "Male"
        maleBtn.isSelected = true
        femaleBtn.isSelected = false
    }
    
    @IBAction func femaleBtnClicked(_ sender: Any) {
        gender = "Female"
        maleBtn.isSelected = false
        femaleBtn.isSelected = true
    }
    
    @IBAction func submitBtnClicked(_ sender: Any) {
        
        if downloadURL == "" {
            self.showToast(message: "Upload Proflie Pic")
            return
        }
        
        if gender == "" {
            self.showToast(message: "Select Gender")
            return
        }
        if let sAge = age.text, !sAge.isEmpty {
            
            if let iAge = Int(sAge) {
                self.ProgressHUDShow(text: "Profile Updating...")
                Firestore.firestore().collection("Users").document(Auth.auth().currentUser!.uid).setData(["age" : iAge,"profilePic" : downloadURL,"gender" : gender],merge: true) { error in
                    
                    self.ProgressHUDHide()
                    
                }
            }
            
        }
        else {
            self.showToast(message: "Enter Age")
        }
        
    }
    
    
    @objc func imageViewClicked(){
        chooseImageFromPhotoLibrary()
    }
    
    func chooseImageFromPhotoLibrary(){
        
        let image = UIImagePickerController()
        image.delegate = self
        image.title = title
        image.sourceType = .photoLibrary
        self.present(image,animated: true)
    }
    
    
}

extension SetupUserProfileViewController : UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return true
    }
    
}

extension SetupUserProfileViewController : UIImagePickerControllerDelegate, UINavigationControllerDelegate,CropViewControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let editedImage = info[.originalImage] as? UIImage {
            
            
            
            self.dismiss(animated: true) {
                
                let cropViewController = CropViewController(image: editedImage)
                cropViewController.title = picker.title
                cropViewController.delegate = self
                cropViewController.customAspectRatio = CGSize(width: 1  , height: 1)
                cropViewController.aspectRatioLockEnabled = true
                cropViewController.aspectRatioPickerButtonHidden = true
                self.present(cropViewController, animated: true, completion: nil)
            }
            
            
            
        }
        
        self.dismiss(animated: true, completion: nil)
    }
    
    func cropViewController(_ cropViewController: CropViewController, didCropToImage image: UIImage, withRect cropRect: CGRect, angle: Int) {
        
        self.ProgressHUDShow(text: "Uploading...")
        
        profilepic.image = image
        profilepic.isHidden = false
    
        uploadImageOnFirebase(){ downloadURL in
            
            self.ProgressHUDHide()
            self.downloadURL = downloadURL
            
        }
        self.dismiss(animated: true, completion: nil)
    }
    
    
    func uploadImageOnFirebase(completion : @escaping (String) -> Void ) {
        
        let storage = Storage.storage().reference().child("UserProfile").child(Auth.auth().currentUser!.uid).child("\(Auth.auth().currentUser!.uid).png")
        var downloadUrl = ""
        
        var uploadData : Data!
        
        
        uploadData = (self.profilepic.image?.jpegData(compressionQuality: 0.4))!
        
        
        
        storage.putData(uploadData, metadata: nil) { (metadata, error) in
            
            if error == nil {
                storage.downloadURL { (url, error) in
                    if error == nil {
                        downloadUrl = url!.absoluteString
                    }
                    completion(downloadUrl)
                    
                }
            }
            else {
                completion(downloadUrl)
            }
            
        }
    }
}
