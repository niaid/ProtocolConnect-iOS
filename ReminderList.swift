//
//  ReminderList.swift
//  StudyBuddy
//
//  Created by Abbey Thorpe on 7/5/16.
//  Copyright © 2016 Abbey Thorpe. All rights reserved.
//  Copyright © 2016,2017 Yong Lu. All rights reserved.
//

import UIKit

class ReminderList {
    class var sharedInstance : ReminderList {
        struct Static {
            static let instance: ReminderList = ReminderList()
        }
        return Static.instance
    }
    
    private let ITEMS_KEY = "reminders"
    func addItem(item: Reminder) {
        
        let userDefaults = NSUserDefaults.standardUserDefaults()
        userDefaults.setObject(NSKeyedArchiver.archivedDataWithRootObject(item.event), forKey: "event")
        
        // Persist a representation of this reminder in NSUserDefaults
        var reminderDictionary = NSUserDefaults.standardUserDefaults().dictionaryForKey(ITEMS_KEY) ?? Dictionary() // If "reminders" hasn't been set in user defaults, initialize reminderDictionary to an empty dictionary using nil-coalescing operator "??".
        reminderDictionary[item.UUID] = ["deadline": item.deadline, "title": item.title, "UUID": item.UUID] // Store NSData representation of reminder in dictionary with UUID as key.
        NSUserDefaults.standardUserDefaults().setObject(reminderDictionary, forKey: ITEMS_KEY) // Save/overwrite reminder list.
        
        // Create a corresponding local notification.
        let notification = UILocalNotification()
        notification.alertBody = item.title // This is the text that will be displayed in the notification.
        notification.alertAction = "open" // The text that is displayed after "slide to..." on the lock screen.  Default is "slide to view".
        notification.fireDate = item.deadline // The item's due date, which is when the notification will be fired.
        notification.soundName = UILocalNotificationDefaultSoundName // Plays the default sound.
        notification.userInfo = ["title": item.title, "UUID": item.UUID] // Assign a unique identifier to the notification so that we can retrieve it later.
        
        UIApplication.sharedApplication().scheduleLocalNotification(notification)
    }
}
