//
//  EntryViewController.swift
//  Pro-Partner
//
//  Created by Apple on 17/12/21.
//

import UIKit
import Lottie

class EntryViewController : UIViewController {
    
    @IBOutlet weak var stackViewSignUpIn: UIStackView!
    @IBOutlet weak var signInView: UIView!
    @IBOutlet weak var registerView: UIView!
    @IBOutlet weak var backOfAnimationView: UIView!
    @IBOutlet weak var animationView: AnimationView!
    
    override func viewDidLoad() {
        
        animationView.loopMode = .loop
        animationView.play(completion: nil)
        backOfAnimationView.layer.cornerRadius = 16
        backOfAnimationView.dropShadow()
        
        stackViewSignUpIn.layer.cornerRadius = 16
        stackViewSignUpIn.layer.borderColor = UIColor.white.cgColor
        stackViewSignUpIn.layer.borderWidth = 1.5
        registerView.layer.cornerRadius = 16
        
        registerView.isUserInteractionEnabled = true
        registerView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(signUpViewClicked)))
        
        signInView.isUserInteractionEnabled = true
        signInView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(signInViewClicked)))
        
    }
    
    @objc func signInViewClicked(){
        beRootScreen(mIdentifier: Constants.StroyBoard.signInViewController)
    }
    
    @objc func signUpViewClicked(){
        beRootScreen(mIdentifier: Constants.StroyBoard.signUpViewController)
    }
}
