//
//  AppDelegate.swift
//  SociAlert
//
//  Created by Celina Kilcrease on 3/19/18.
//  Copyright © 2018 nyu.edu. All rights reserved.
//

import UIKit
import Firebase

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var tokenURL = URL(string: "https://login-sandbox.safetrek.io/oauth/token")
    var redirectURI = "com.ckilcrease.socialert://oauth"
    var clientID = Key.clientID
    var clientSecret = Key.clientSecret
    
    var response: String?
    var window: UIWindow?
    
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        FirebaseApp.configure()
        
        return true
    }
   
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any] = [:]) -> Bool {
        //called when SafeTrek auth redirects to app
        
        var code = ""
        //get auth code from redirect url:
        if let urlComps = URLComponents(url: url, resolvingAgainstBaseURL: true), let query = urlComps.queryItems {
                code = query[0].value!
        }
        
        
        //Create POST request to complete SafeTrek login:
        var postReq = URLRequest(url: tokenURL!)
        postReq.httpMethod = "POST"
        postReq.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let httpBodyDict = [
            "grant_type":"authorization_code",
            "code": code,
            "client_id": clientID,
            "client_secret": clientSecret,
            "redirect_uri": redirectURI
        ] as [String: Any]
        
        let jsonData = try! JSONSerialization.data(withJSONObject: httpBodyDict)
        postReq.httpBody = jsonData
        
        //Make POST request:
        let task = URLSession.shared.dataTask(with: postReq){ data, res, error in
            guard let data = data, error == nil else{
                print("error:", error)
                return
            }

            //store access token information (from http response):
            let responseStr = String(data: data, encoding: .utf8)
            self.response = responseStr
            
            DispatchQueue.main.async{
                //Display alertViewController:
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let alertVC = storyboard.instantiateViewController(withIdentifier: "aVC") as! AlertViewController
                //send over access token information:
                alertVC.accessTokenInfo = self.response
                self.window?.rootViewController = alertVC
                
            }
        }
        task.resume()
      
        
        return true
    }

   
    
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}

