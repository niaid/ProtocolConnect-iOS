//
//  MorePageTableViewController.swift
//  StudyBuddy
//
//  Created by Abbey Thorpe on 6/24/16.
//  Copyright © 2016 Abbey Thorpe. All rights reserved.
//  Copyright © 2016,2017 Yong Lu. All rights reserved.
//

import UIKit

class MorePageTableViewController: UITableViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
    }
    
    // MARK: Actions
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
            
        if indexPath.row == 0{
            // change password
        }
        if indexPath.row == 1{
            // reminder setting
        }
        // When the third row is selected (logout), give action sheet.
        if indexPath.row == 2{
            
            //print("logout selected!")
            
            let optionMenu = UIAlertController(title: nil, message: "Are you sure you want to log out?", preferredStyle: .Alert)
            
            let logoutAction = UIAlertAction(title: "Log out", style: .Default, handler: { (alert: UIAlertAction!) -> Void in
                self.performSegueWithIdentifier("unwindToLogin", sender: self)
            })
            
            let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel, handler: { (alert: UIAlertAction!) -> Void in
            })
            
            optionMenu.addAction(logoutAction)
            optionMenu.addAction(cancelAction)
            
            self.presentViewController(optionMenu, animated: true, completion: nil)
        }
    }
    
}
