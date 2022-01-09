//
//  UserModel.swift
//  My Breeders Store
//
//  Created by Apple on 11/11/21.
//

import UIKit

class UserModel : NSObject, Codable {
    
    var name : String?
    var email : String?
    var date : Date?
    var gender : String?
    var age : Int?
    var profilePic : String?
    var uid : String?
    var notificationToken : String?
    
    
    private static var userModel : UserModel?
    
    static var data : UserModel? {
        set(userModel) {
            self.userModel = userModel
        }
        get {
            return userModel
        }
    }
    
    
    override init() {
        
    }
    
}
