//
//  ViewController.swift
//  SociAlert
//
//  Created by Celina Kilcrease on 3/19/18.
//  Copyright © 2018 nyu.edu. All rights reserved.
//

import UIKit


class ViewController: UIViewController {
    
    @IBOutlet weak var safeTrekBtn: UIButton!
    var redirectURI = "com.ckilcrease.socialert://oauth"//"http://localhost:3000/callback"
    var clientID = Key.clientID
    var clientSecret = Key.clientSecret
    
    @IBAction func safeTrekAuth(_ sender: Any) {
        
        //build auth URL with appropriate query parameters:
        var reqUrl = URLComponents(string: "https://account-sandbox.safetrek.io/authorize?")
        reqUrl?.queryItems = [
            URLQueryItem(name: "client_id", value: clientID),
            URLQueryItem(name: "scope", value: "openid phone offline_access"),
            URLQueryItem(name: "state", value: "state"),
            URLQueryItem(name: "response_type", value: "code"),
            URLQueryItem(name: "redirect_uri", value: redirectURI)
        ]
        //format URL:
        reqUrl!.percentEncodedQuery = reqUrl?.percentEncodedQuery?.replacingOccurrences(of: "+", with: "%2B")
        
        //open auth URL in mobile browser:
        UIApplication.shared.open((reqUrl?.url)!, options: [:], completionHandler: nil)
 
    }

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let btnImg = UIImage(named: "SafeTrek_Brand_API_Assets-01")
        safeTrekBtn.tintColor = .clear
        safeTrekBtn.setBackgroundImage(btnImg, for: .normal)
        safeTrekBtn.setImage(btnImg, for: .normal)
        safeTrekBtn.imageView?.contentMode = .scaleAspectFit
        safeTrekBtn.imageEdgeInsets = UIEdgeInsetsMake(0.0, 0.0, 0.0, 0.0)
        
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

