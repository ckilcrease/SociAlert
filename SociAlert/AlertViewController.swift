//
//  AlertViewController.swift
//  SociAlert
//
//  Created by Celina Kilcrease on 3/19/18.
//  Copyright © 2018 nyu.edu. All rights reserved.
//

import UIKit
import FacebookLogin
import FacebookCore
import FacebookShare
import CoreLocation


class AlertViewController: UIViewController, CLLocationManagerDelegate {

    var accessTokenInfo: String?
    var currentAlarmID: String?
    var auth: String?
    
    let locationManager = CLLocationManager()
    let baseURL = URL(string: "https://api-sandbox.safetrek.io/v1/alarms")
 
    @IBOutlet weak var alertButton: UIButton!
    
    @IBAction func alertAction(_ sender: Any) {
        if (alertButton.currentTitle! == "Alert"){
            //change alert button text & issue alert
            alertButton.setTitle("Cancel Alert", for: .normal)
            issueAlert()
        }
        else{
            //change alert button text & cancel existing alert
            alertButton.setTitle("Alert", for: .normal)
            cancelAlert()
        }
    }
    
    
    func issueAlert(){
        //parse SafeTrek access token information (from appdelegate) into dictionary:
        var dictionary: NSDictionary
        //convert access token into data, then into dictionary
        if let data = accessTokenInfo?.data(using: String.Encoding.utf8){
            do{
                dictionary = try! JSONSerialization.jsonObject(with: data, options: []) as! NSDictionary
                
                //build the access token string:
                var authStr = dictionary.value(forKey: "token_type") as! String
                authStr += " "
                authStr += dictionary.value(forKey: "access_token") as! String
                
                self.auth = authStr
                
                //create & send POST request that creates alert
                var postReq = URLRequest(url: baseURL!)
                postReq.httpMethod = "POST"
                postReq.setValue(authStr, forHTTPHeaderField: "Authorization")
                postReq.setValue("application/json", forHTTPHeaderField: "Content-Type")
                
                //create http body with location info and default services:
                let httpBodyDict = [
                    "services": [
                        "police": true,
                        "fire": false,
                        "medical": false
                    ],
                    "location.coordinates": [
                        "lat": locationManager.location?.coordinate.latitude,
                        "lng": locationManager.location?.coordinate.longitude,
                        "accuracy": 5
                    ]
                ] as [String: Any]
                
                //convert httpBodyDict to json and assign to body of POST request:
                let jsonData = try! JSONSerialization.data(withJSONObject: httpBodyDict)
                postReq.httpBody = jsonData
                
                //Send POST Request
                let task = URLSession.shared.dataTask(with: postReq){
                    data, res, error in
                    guard let data = data, error == nil else{
                        print("error: ", error)
                        return
                    }
                    //responseStr will hold newly created SafeTrek alarm, sent back as HTTP response
                    let responseStr = String(data: data, encoding: .utf8)
                    
                    if let resData = responseStr?.data(using: String.Encoding.utf8){
                        do{
                            let alarmDict = try! JSONSerialization.jsonObject(with: resData, options: []) as! NSDictionary
                            //store alarm ID for use in cancellation
                            self.currentAlarmID = alarmDict.value(forKey: "id") as! String
                        }
                    }
                }
                task.resume()
                
                //set and send Facebook alert message:
                let params = ["message":"This is an automatic message signalling that I've issued a SafeTrek alarm."]
                self.shareAlert(withParams: params)
            }
        }
    }
    
    
    func cancelAlert(){
        let statURL = URL(string: "https://api-sandbox.safetrek.io/v1/alarms/" + self.currentAlarmID! + "/status")
        
        //create & send PUT request that cancels alert
        var putReq = URLRequest(url: statURL!)
        putReq.httpMethod = "PUT"
        putReq.setValue(self.auth, forHTTPHeaderField: "Authorization")
        putReq.setValue("application/json", forHTTPHeaderField: "Content-Type")
        let httpBodyDict = [
            "status": "CANCELED"
        ]
        
        let jsonData = try! JSONSerialization.data(withJSONObject: httpBodyDict)
        putReq.httpBody = jsonData
        
        //send PUT request
        let task = URLSession.shared.dataTask(with: putReq){
            data, res, error in
            guard let data = data, error == nil else{
                print("error: ", error)
                return
            }
            
            let responseStr = String(data: data, encoding: .utf8)
            print("responseStr :", responseStr ?? "")
            
        }
        task.resume()
        
        //set and send Facebook alert message:
        let params = ["message":"This is an automatic message signalling that I've CANCELED a SafeTrek alarm."]
        self.shareAlert(withParams: params)
    }
    
    
    func shareAlert(withParams: [String: String]){
        if let fbAccessToken = AccessToken.current {
            // User is logged in, use 'fbAccessToken' here.
    
            //create graph request to post to user's Facebook news feed:
            let connection = GraphRequestConnection()
            let graphReq = GraphRequest(graphPath: "/me/feed", parameters: withParams, accessToken: fbAccessToken, httpMethod: .POST, apiVersion: .defaultVersion)
            
            connection.add(graphReq){
                httpResponse, result in
                switch result{
                case .success(let response):
                    print("Graph req succeeded: \(response)")
                case .failed(let error):
                    print("Error: \(error)")
                }
            }
            connection.start()
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Request location authorization from user:
        self.locationManager.requestAlwaysAuthorization()
        
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.startUpdatingLocation()
        }

        //set up from Facebook SDK guide:
        let loginButton = LoginButton(publishPermissions: [.publishActions])
        //position login button:
        loginButton.center.x = view.center.x
        loginButton.center.y = 50
        view.addSubview(loginButton)
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

}
