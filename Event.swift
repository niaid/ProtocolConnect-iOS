//
//  Event.swift
//  StudyBuddy
//
//  Created by Abbey Thorpe on 6/9/16.
//  Copyright © 2016 Abbey Thorpe. All rights reserved.
//  Copyright © 2016,2017 Yong Lu. All rights reserved.
//

import UIKit

class Event: NSObject, NSCoding {
    
    // MARK: Properties
    
    var _id: String
    var studyflow_id: String
    var name: String
    var location: String
    var time: NSDate // see this page for info on datetime in swift: http://www.globalnerdy.com/2015/01/26/how-to-work-with-dates-and-times-in-swift-part-one/
    var rel_date: Int
    var notes: String?
    var question: String // If "yes" then a question is expected, if "no" then the event does not need confirmation.
    
    var flag: String?  // For passed events: "missed" or "attended"
    var response: String? // Response from subject. Could be one of:
                          //   confirmed_on_time, will_be_late, will_miss
    
    var reason: String? // one of the following:
                         //   not_well, transportation, previous_appointment, others
    var est_arrival: NSDate? // Estimated arrival time when the subject indicates she'll be late
    var additional_response: String?  // additional details
    
    // MARK: Archiving Paths
    
    static let DocumentsDictionary = NSFileManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask).first!
    static let ArchiveURL = DocumentsDictionary.URLByAppendingPathComponent("events")
    
    // MARK: Types
    
    struct PropertyKey {
        static let _idKey = "_id"
        static let studyflow_idKey = "studyflow_id"
        static let nameKey = "name"
        static let locationKey = "location"
        static let timeKey = "time"
        static let rel_dateKey = "rel_date"
        static let notesKey = "notes"
        static let questionKey = "question"
        static let flagKey = "flag"
        static let responseKey = "response"
        static let reasonKey = "reason"
        static let est_arrivalKey = "est_arrival"
        static let additional_responseKey = "additional_response"
    }
    
    // MARK: Initialization
    
    init?(_id: String, studyflow_id: String, name: String, location: String, time: NSDate, rel_date: Int, notes: String?, question: String, flag: String?, response: String?, reason: String?, est_arrival: NSDate?, additional_response: String?){
        
        // Intialize stored properties.
        self._id = _id
        self.studyflow_id = studyflow_id
        self.name = name
        self.location = location
        self.time = time
        self.rel_date = rel_date
        self.notes = notes
        self.question = question
        self.flag = flag
        self.response = response
        self.reason = reason
        self.est_arrival = est_arrival
        self.additional_response = additional_response
        
        super.init()
        
        // Initialization should fail if there is no event name.
        if name.isEmpty || question.isEmpty {
            return nil
        }
        
    }
    
    // MARK: NSCoding
    func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(_id, forKey: PropertyKey._idKey)
        aCoder.encodeObject(studyflow_id, forKey: PropertyKey.studyflow_idKey)
        aCoder.encodeObject(name, forKey: PropertyKey.nameKey)
        aCoder.encodeObject(location, forKey: PropertyKey.locationKey)
        aCoder.encodeObject(time, forKey: PropertyKey.timeKey)
        aCoder.encodeObject(rel_date, forKey: PropertyKey.rel_dateKey)
        aCoder.encodeObject(notes, forKey: PropertyKey.notesKey)
        aCoder.encodeObject(question, forKey: PropertyKey.questionKey)
        aCoder.encodeObject(flag, forKey: PropertyKey.flagKey)
        aCoder.encodeObject(response, forKey: PropertyKey.responseKey)
        aCoder.encodeObject(reason, forKey: PropertyKey.reasonKey)
        aCoder.encodeObject(est_arrival, forKey: PropertyKey.est_arrivalKey)
        aCoder.encodeObject(additional_response, forKey: PropertyKey.additional_responseKey)
    }
    
    required convenience init?(coder aDecoder:NSCoder){
        let _id = aDecoder.decodeObjectForKey(PropertyKey._idKey) as! String
        let studyflow_id = aDecoder.decodeObjectForKey(PropertyKey.studyflow_idKey) as! String
        let name = aDecoder.decodeObjectForKey(PropertyKey.nameKey) as! String
        let location = aDecoder.decodeObjectForKey(PropertyKey.locationKey) as! String
        let time = aDecoder.decodeObjectForKey(PropertyKey.timeKey) as! NSDate
        let rel_date = aDecoder.decodeObjectForKey(PropertyKey.rel_dateKey) as! Int
        let notes = aDecoder.decodeObjectForKey(PropertyKey.notesKey) as? String
        let question = aDecoder.decodeObjectForKey(PropertyKey.questionKey) as! String
        let flag = aDecoder.decodeObjectForKey(PropertyKey.flagKey) as? String
        let response = aDecoder.decodeObjectForKey(PropertyKey.responseKey) as? String
        let reason = aDecoder.decodeObjectForKey(PropertyKey.reasonKey) as? String
        let est_arrival = aDecoder.decodeObjectForKey(PropertyKey.est_arrivalKey) as? NSDate
        let additional_response = aDecoder.decodeObjectForKey(PropertyKey.additional_responseKey) as? String
        
        self.init(_id: _id, studyflow_id: studyflow_id, name: name, location: location, time: time, rel_date: rel_date, notes: notes, question: question, flag: flag, response: response, reason: reason, est_arrival: est_arrival, additional_response: additional_response)
    }
}
