//
//  Reminder.swift
//  StudyBuddy
//
//  Created by Abbey Thorpe on 7/5/16.
//  Copyright © 2016 Abbey Thorpe. All rights reserved.
//  Copyright © 2016,2017 Yong Lu. All rights reserved.
//

import UIKit

struct Reminder{
    var title: String
    var deadline: NSDate
    var UUID: String
    var event: Event
    
    init(deadline: NSDate, title: String, UUID: String, event: Event){
        self.deadline = deadline
        self.title = title
        self.UUID = UUID
        self.event = event
    }
}
