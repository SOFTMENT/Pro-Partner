//
//  TabBarViewController.swift
//  My Breeders Store
//
//  Created by Apple on 07/11/21.
//

import UIKit


class TabBarViewController: UITabBarController, UITabBarControllerDelegate {
  
    var tabBarItems = UITabBarItem()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.delegate  = self

        let selectedImage1 = UIImage(named: "icons8-home-100-2")?.withRenderingMode(.alwaysOriginal)
        let deSelectedImage1 = UIImage(named: "icons8-home-100")?.withRenderingMode(.alwaysOriginal)
        tabBarItems = self.tabBar.items![0]
        tabBarItems.image = deSelectedImage1
        tabBarItems.selectedImage = selectedImage1
        
        let selectedImage2 = UIImage(named: "icons8-shop-local-100-2")?.withRenderingMode(.alwaysOriginal)
        let deSelectedImage2 = UIImage(named: "icons8-shop-local-100")?.withRenderingMode(.alwaysOriginal)
        tabBarItems = self.tabBar.items![1]
        tabBarItems.image = deSelectedImage2
        tabBarItems.selectedImage = selectedImage2
        
        let selectedImage3 = UIImage(named: "icons8-location-100-2")?.withRenderingMode(.alwaysOriginal)
        let deSelectedImage3 = UIImage(named: "icons8-location-100")?.withRenderingMode(.alwaysOriginal)
        tabBarItems = self.tabBar.items![2]
        tabBarItems.image = deSelectedImage3
        tabBarItems.selectedImage = selectedImage3
        
        
        let selectedImage4 = UIImage(named: "icons8-chat-room-100-2")?.withRenderingMode(.alwaysOriginal)
        let deSelectedImage4 = UIImage(named: "icons8-chat-room-100")?.withRenderingMode(.alwaysOriginal)
        tabBarItems = self.tabBar.items![3]
        tabBarItems.image = deSelectedImage4
        tabBarItems.selectedImage = selectedImage4
        
        let selectedImage5 = UIImage(named: "icons8-male-user-100-2")?.withRenderingMode(.alwaysOriginal)
        let deSelectedImage5 = UIImage(named: "icons8-male-user-100")?.withRenderingMode(.alwaysOriginal)
        tabBarItems = self.tabBar.items![4]
        tabBarItems.image = deSelectedImage5
        tabBarItems.selectedImage = selectedImage5
        
        
     
    }
    
    
}


