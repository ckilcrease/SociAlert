//
//  faceBookLoginControllerViewController.swift
//  SociAlert
//
//  Created by Celina Kilcrease on 4/6/18.
//  Copyright © 2018 nyu.edu. All rights reserved.
//

import UIKit
import FacebookLogin
import FacebookCore
import FacebookShare


class faceBookLoginControllerViewController: UIViewController {
    @IBOutlet weak var fbBtn: UIButton!
    
    
    
    
    @IBAction func fbLoginClicked(_ sender: Any) {
        
        let loginManager = LoginManager()
        
        loginManager.logIn(publishPermissions: [.publishActions], viewController: self) { (loginResult) in
            
            switch loginResult{
            case .failed(let error):
                print(error)
            case .cancelled:
                print("User cancelled login")
            case .success(let grantedPermissions, let declinedPermissions, let accessToken):
                print("logged in")
                
                
                DispatchQueue.main.async{
                 //Display viewController:
                 let storyboard = UIStoryboard(name: "Main", bundle: nil)
                 let viewC = storyboard.instantiateViewController(withIdentifier: "viewC") as! ViewController
                 //send over access token information:
                 // alertVC.accessTokenInfo = self.response
                
                 self.present(viewC, animated: true, completion: nil)
                 
                 }
    
                
            }
            
         
            
        }
  
    }
    
    
   
    override func viewDidLoad() {
        super.viewDidLoad()

        let btnImg = UIImage(named: "fblogin")
        fbBtn.tintColor = .clear
        fbBtn.setBackgroundImage(btnImg, for: .normal)
        fbBtn.setImage(btnImg, for: .normal)
       // fbBtn.imageView?.contentMode = .scaleAspectFit
        fbBtn.imageEdgeInsets = UIEdgeInsetsMake(0.0, 0.0, 0.0, 0.0)
        
        // Do any additional setup after loading the view.
    }
    
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

}