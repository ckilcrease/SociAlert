//
//  User.swift
//  SociAlert
//
//  Created by Celina Kilcrease on 4/15/18.
//  Copyright © 2018 nyu.edu. All rights reserved.
//

import Foundation
import UIKit

class User: NSObject {
    var messageCreateAlarm: String?
    var messageCancelAlarm: String?
    
    init(dictionary: [String: Any]){
        messageCreateAlarm = dictionary["mssgCreate"] as? String
        messageCancelAlarm = dictionary["mssgCancel"] as? String
    }
    
    override init(){
        super.init()
    }
    
}
