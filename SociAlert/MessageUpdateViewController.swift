//
//  MessageUpdateViewController.swift
//  SociAlert
//
//  Created by Celina Kilcrease on 4/15/18.
//  Copyright © 2018 nyu.edu. All rights reserved.
//

import UIKit
import FacebookCore
import FacebookLogin
import Firebase
import FirebaseAuth


class MessageUpdateViewController: UIViewController {

    @IBOutlet weak var createAlertMssg: UITextView!
    @IBOutlet weak var newCreateMssg: UITextField!
    @IBOutlet weak var cancelAlertMssg: UITextView!
    @IBOutlet weak var newCancelMssg: UITextField!
    var currentUserRef: DatabaseReference?
    
    @IBAction func dismissVC(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    @IBAction func updateButton(_ sender: Any) {
        
        //if create mssg present:
        if newCreateMssg.text != nil {
            //update in db:
            self.currentUserRef?.updateChildValues(["mssgCreate" : newCreateMssg.text])
            
            self.currentUserRef?.child("mssgCreate").observe(.value, with: { (snapshot) in
                if let val = snapshot.value as? String{
                    self.createAlertMssg.text = val
                }
            })
            
        }
        if newCancelMssg.text != nil{
            //update in db
            self.currentUserRef?.updateChildValues(["mssgCancel" : newCancelMssg.text])
            
            self.currentUserRef?.child("mssgCancel").observe(.value, with: { (snapshot) in
                if let val = snapshot.value as? String{
                    self.cancelAlertMssg.text = val
                }
            })
        }

        
        
       
        
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        self.hideKeyboardOnTap()

        let dbRef = Database.database().reference(fromURL:"https://socialert-c286d.firebaseio.com/")
        
        //authenticate with firebase:
        let fireBaseCredential =  FacebookAuthProvider.credential(withAccessToken: (AccessToken.current?.authenticationToken)!)
        
        Auth.auth().signIn(with: fireBaseCredential) { (user, error) in
            if let error = error {
                print(error)
                return
            }
            // User is signed in
            guard let uid = user?.uid else{return}
            let userReference = dbRef.child("users").child(uid)
            self.currentUserRef = userReference
            
            userReference.child("mssgCreate").observe(.value, with: { (snapshot) in
                if let val = snapshot.value as? String{
                    self.createAlertMssg.text = val
                }
            })
            
            userReference.child("mssgCancel").observe(.value, with: { (snapshot) in
                if let val = snapshot.value as? String{
                    self.cancelAlertMssg.text = val
                }
            })
            
        }
        
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

}



extension UIViewController {
    func hideKeyboardOnTap() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        view.addGestureRecognizer(tap)
        
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
}
