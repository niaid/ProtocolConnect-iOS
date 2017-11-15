//
//  Questions.swift
//  StudyBuddy
//
//  Created by Abbey Thorpe on 7/18/16.
//  Copyright © 2016 Abbey Thorpe. All rights reserved.
//  Copyright © 2016,2017 Yong Lu. All rights reserved.
//

import UIKit

class Question{
    // MARK: Properties
    var QID: String
    var text: String
    var options: [Answer]?
    
    init?(QID: String, text: String, options: [Answer]?){
        self.QID = QID
        self.text = text
        self.options = options
        
        if QID.isEmpty || text.isEmpty{
            return nil
        }
    }
}
