//
//  MessageViewController.swift
//  StudyBuddy
//
//  Created by Abbey Thorpe on 6/29/16.
//  Copyright © 2016 Abbey Thorpe. All rights reserved.
//  Copyright © 2016,2017 Yong Lu. All rights reserved.
//

import UIKit

class MessageViewController: UIViewController {
    
    // MARK: Properties
    
    @IBOutlet weak var fromLabel: UILabel!
    @IBOutlet weak var toLabel: UILabel!
    @IBOutlet weak var subjectLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var contentsLabel: UITextView!
    
    var message: Message?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set up views.
        
        if let message = message {
            fromLabel.text = "From: " + message.from
            toLabel.text = "To: " + message.to
            subjectLabel.text = message.subjectLine
            timeLabel.text = message.time
            contentsLabel.text = message.contents
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    
}
