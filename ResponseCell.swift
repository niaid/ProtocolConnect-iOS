//
//  ResponseCell.swift
//  StudyBuddy
//
//  Created by Yong Lu on 7/25/16.
//  Copyright © 2016 Abbey Thorpe. All rights reserved.
//  Copyright © 2016,2017 Yong Lu. All rights reserved.
//

import UIKit

class ResponseCell: UITableViewCell {
    
    // MARK: Properties
    
    @IBOutlet weak var ResponseLabel: UILabel!
    @IBOutlet weak var ResponseCheck: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
}
