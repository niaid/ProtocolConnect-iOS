//
//  User.swift
//  StudyBuddy
//
//  Created by Abbey Thorpe on 7/1/16.
//  Copyright © 2016 Abbey Thorpe. All rights reserved.
//  Copyright © 2016,2017 Yong Lu. All rights reserved.
//

import UIKit

class User {
    
    static var name: String?
    static var email: String?
    static var password: String?
    static var dateFormatter = NSDateFormatter()
    static var notifyDaysBefore : Int?;
    static var notifyHoursBefore : Int?;
    static var notifyMinsBefore : Int?;
    
    init?(email: String, name: String, password: String){
        User.name = name
        User.email = email
        User.password = password
        User.dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        
        User.loadConfig()
        if email.isEmpty{
            return nil
        }
    }
    
    // load local config
    static func loadConfig() {
        User.notifyDaysBefore = 0;
        User.notifyHoursBefore = 0;
        User.notifyMinsBefore = 30;
    }
    
    // save local config
    static func saveConfig() {
    }
    
}
