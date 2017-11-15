//
//  DatePickerCell.swift
//  StudyBuddy
//
//  Created by Yong Lu on 8/8/16.
//  Copyright © 2016 Abbey Thorpe. All rights reserved.
//  Copyright © 2016,2017 Yong Lu. All rights reserved.
//

import UIKit

class DatePickerCell: UITableViewCell {
    @IBOutlet weak var myDatePicker: UIDatePicker!
    var dateSelected: NSDate?

    // MARK: Properties
    
     @IBAction func datePickerAction(sender: AnyObject) {
        // save the selected date/time
        dateSelected = myDatePicker.date
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
}
