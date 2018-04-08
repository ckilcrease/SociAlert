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

    @IBOutlet weak var locationSwitch: UISwitch!
    
    var accessTokenInfo: String?
    var currentAlarmID: String?
    var auth: String?
    var placeName: String?
    var cityName: String?
    var paramsForStatus: [String: Any]?
    let locationManager = CLLocationManager()
    let baseURL = URL(string: "https://api-sandbox.safetrek.io/v1/alarms")
 
    @IBOutlet weak var alertButton: UIButton!
    
    @IBAction func alertAction(_ sender: Any) {
        if (alertButton.currentTitle! == "Alert"){
            //change alert button text & issue alert
            alertButton.setTitle("Cancel Alert", for: .normal)
            if (accessTokenInfo != nil){ //user connected to SafeTrek
                issueAlert()
            }
            
            if (locationSwitch.isOn){
                //Share with location data
                lookUpCurrentLocation(completionHandler: compHandler)
            }
            else{
                //set and send Facebook alert message without location:
                let params = ["message":"This is an automatic message signalling that I've issued an alarm."]
                self.shareAlert(withParams: params)
            }
            
        }
        else{
            //change alert button text & cancel existing alert
            alertButton.setTitle("Alert", for: .normal)
            if (accessTokenInfo != nil){
                cancelAlert()
            }
            //set and send Facebook alert message:
            let params = ["message":"This is an automatic message signalling that I've CANCELED an alarm."]
            self.shareAlert(withParams: params)
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
        
        if (accessTokenInfo != nil){
            //user is connected to SafeTrek
            //display Powered By SafeTrek img under alert button:
            let pwrByST = UIImage(named: "SafeTrek_Brand_API_Assets-03")
            let imageVw = UIImageView(image: pwrByST)
            imageVw.frame = CGRect(x: 30, y: 350, width: 300, height: 100)
            
            view.addSubview(imageVw)
        }
        
        //Request location authorization from user:
        self.locationManager.requestAlwaysAuthorization()
        
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.startUpdatingLocation()
        }

        
    }
    
    func compHandler(place: CLPlacemark?) -> Void {
       
        self.placeName = place?.name!
        self.cityName = place?.locality!
        let params = ["message":"This is an automatic message signalling that I've issued an alarm near \(self.placeName!) in \(self.cityName!)"]
        //print(params)
        self.shareAlert(withParams: params)
        
    }
    
    func lookUpCurrentLocation(completionHandler: @escaping (CLPlacemark?)
        -> Void ){
        // Use the last reported location.
        if let lastLocation = self.locationManager.location {
            let geocoder = CLGeocoder()
            
            // Look up the location and pass it to the completion handler
            geocoder.reverseGeocodeLocation(lastLocation,
                    completionHandler: { (placemarks, error) in
                            if error == nil {
                                let firstLocation = placemarks?[0]
                                self.placeName = firstLocation?.name
                                self.cityName = firstLocation?.locality
                                print("loc is \(firstLocation)")
                                completionHandler(firstLocation)
                            }
                            else {
                                print("An error occurred during geocoding.")
                            }
            })
        }
        else {
            print("No location was available.")
            //completionHandler(nil)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

}
