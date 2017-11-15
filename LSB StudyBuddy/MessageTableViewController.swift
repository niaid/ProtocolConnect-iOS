//
//  MessageTableViewController.swift
//  StudyBuddy
//
//  Created by Abbey Thorpe on 6/30/16.
//  Copyright © 2016 Abbey Thorpe. All rights reserved.
//  Copyright © 2016,2017 Yong Lu. All rights reserved.
//

import UIKit

class MessageTableViewController: UITableViewController {
    
    // MARK: Properties
    
    var messages = [Message]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadSampleMessages()
        
        self.tableView.reloadData()
        self.tableView.rowHeight = 80
    }
    
    func loadSampleMessages(){
        
        let message1 = Message(from: "Study", to: "You", subjectLine: "Welcome to our study!", time: "April 30, 2016, 3:00 PM", contents: "Larry, welcome to the ____ Study.  We will be using this app to send you updates about your schedule and confirm appointments.  Feel free to send us a message if you are having any problems or are unable to attend an appointment.  You can find emergency contact information under on the \"Contact\" page.")!
        let message2 = Message(from: "Study", to: "You", subjectLine: "Your May 2nd phlebotomy appointment has been moved", time: "May 2, 2016, 8:00 AM", contents: "Hi Larry, your phlebotomy appointment scheduled for today, May 2nd, at 1:00 PM has been rescheduled to 5:00 PM.  Please let us know if you are unable to attend this appointment.")!
        
        messages += [message1, message2]
    }
    
    // MARK: TableView data source
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        // Table view cells are reused and should be dequeued using a cell identifier.
        let cellIdentifier = "messageTableViewCell"
        
        let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier, forIndexPath: indexPath) as! MessageTableViewCell
        
        // Fetches the appropriate event for the data source layout.
        let message = messages[indexPath.row]
        
        // Format time string
        let formatter = NSDateFormatter()
        formatter.dateFormat = "MMMM dd, yyyy, h:mm a"
        let date = formatter.dateFromString(message.time)
        formatter.dateStyle = .ShortStyle
        let time = formatter.stringFromDate(date!)
        
        cell.subjectLabel.text = message.subjectLine
        cell.timeLabel.text = time
        cell.contentsPreview.text = message.contents
        
        return cell
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        let messageDetailViewController = segue.destinationViewController as! MessageViewController
        
        // Get the cell that generated this segue.
        if let selectedMessageCell = sender as? MessageTableViewCell {
            
            let indexPath = tableView.indexPathForCell(selectedMessageCell)!
            let selectedMessage = messages[indexPath.row]
            messageDetailViewController.message = selectedMessage
            
        }
        
    }
}
