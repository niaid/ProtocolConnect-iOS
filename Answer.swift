//
//  Answer.swift
//  StudyBuddy
//
//  Created by Abbey Thorpe on 7/18/16.
//  Copyright © 2016 Abbey Thorpe. All rights reserved.
//  Copyright © 2016,2017 Yong Lu. All rights reserved.
//

import UIKit

class Answer{
    
    // MARK: Properties
    var AID: String
    var flag: String?
    var next: String?
    var text: String
    
    init?(AID: String, flag: String?, next: String?, text: String){
        
        // Initialize stored properties.
        self.AID = AID
        self.flag = flag
        self.next = next
        self.text = text
        
        if AID.isEmpty || text.isEmpty{
            return nil
        }
    }
}
