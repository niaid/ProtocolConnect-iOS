//
//  Message.swift
//  StudyBuddy
//
//  Created by Abbey Thorpe on 6/30/16.
//  Copyright © 2016 Abbey Thorpe. All rights reserved.
//  Copyright © 2016,2017 Yong Lu. All rights reserved.
//

import UIKit

class Message {
    
    // MARK: Properties
    var is_to_patient: Bool
    var patient_email: String  // used as ID of the patient
    var date: NSDate
    var epoch: Double
    var content: String
    
        
    // MARK: Initialization
    
    init?(is_to_patient: Int, patient_email: String, epoch: Double, content: String){
        self.is_to_patient = (is_to_patient == 1)
        self.patient_email = patient_email
        self.epoch = epoch
        self.date = NSDate(timeIntervalSince1970: epoch)
        self.content = content
        // Initialize stored properties.
        
        // Initialization should fail if a value is missing.
        //if from.isEmpty || to.isEmpty || subjectLine.isEmpty || time.isEmpty || contents.isEmpty {
        //    return nil
        //}
        
    }
    
}
