//
//  EventTableViewController.swift
//  StudyBuddy
//
//  Created by Abbey Thorpe on 6/13/16.
//  Copyright © 2016 Abbey Thorpe. All rights reserved.
//  Copyright © 2016,2017 Yong Lu. All rights reserved.
//

import UIKit

class EventTableViewController: UITableViewController {
    
    // MARK: Properties
    
    //var user: User?
    var events : [Event]?
    var sections = [NSDate: [Event]]() //A dictionary where the keys are days and the values are arrays of events on that day.
    var sortedDays = [NSDate]()
    var todayDate: NSDate?
    var nextEvent: Event?
    
    override func viewWillAppear(animated: Bool) {
        let delegate = ApiRequestDelegate()
        delegate.getEventsBasedOnUserEmail(User.email!) {
            (successful:Bool, req_status: Int, events:[Event]) in
            if(successful){
                self.events = events
                self.sortEvents()
                UIApplication.sharedApplication().cancelAllLocalNotifications()
                self.createReminders()
                //self.tableView.rowHeight = UITableViewAutomaticDimension
                //self.tableView.estimatedRowHeight = 160.0
                self.tableView.reloadData()  // notify tableView to reload data
                print(String(format:"Number of events loaded: %d",self.events!.count))
                if(events.count>0) {
                    self.formatTable()
                }
            }
        }
        super.viewWillAppear(animated)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Schedule"
        self.navigationItem.title = User.name!+"'s Schedule"

        // Load the hardcoded sample data.
        // loadSampleEvents()
        
        /*
        let delegate = ApiRequestDelegate()
        delegate.getEventsBasedOnUserEmail(User.email!) {
            (successful:Bool, req_status: Int, events:[Event]) in
            if(successful){
                self.events = events
                self.sortEvents()
                UIApplication.sharedApplication().cancelAllLocalNotifications()
                self.createReminders()
                //self.tableView.rowHeight = UITableViewAutomaticDimension
                //self.tableView.estimatedRowHeight = 160.0
                self.tableView.reloadData()  // notify tableView to reload data
                print(String(format:"Number of events loaded: %d",self.events!.count))
                if(events.count>0) {
                    self.formatTable()
                }
            }
        }
        */
        
        self.refreshControl?.addTarget(self, action: "handleRefresh:", forControlEvents: UIControlEvents.ValueChanged)

        /*
        // Load the sample JSON data.
        loadDataFromFile()
        
        // Load data from a URL.
        //loadDataFromUrl()
        
        // Sort events.
        sortEvents()
        
        // Clear old reminders and set up reminders for each event in the current list.
        UIApplication.sharedApplication().cancelAllLocalNotifications()
        createReminders()
        
        // Format event order to center display on upcoming events.
        formatTable()
        
        // Access list of scheduled notifications for debugging purposes.
        /*
        let scheduledNotifications: [UILocalNotification]? = UIApplication.sharedApplication().scheduledLocalNotifications
        for notification in scheduledNotifications!{
            print(notification.userInfo!["UUID"])
        }*/
        
        // Archive the events.
        //saveEvents() */
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // for explanation/demo of refreshing, see
    // https://www.andrewcbancroft.com/2015/03/17/basics-of-pull-to-refresh-for-swift-developers/#tvc-handle-refresh-function
    func handleRefresh(refreshControl: UIRefreshControl) {
        let delegate = ApiRequestDelegate()
        delegate.getEventsBasedOnUserEmail(User.email!) {
            (successful:Bool, req_status: Int, events:[Event]) in
            if(successful){
                self.events = events
                self.sortEvents()
                UIApplication.sharedApplication().cancelAllLocalNotifications()
                self.createReminders()
                //self.tableView.rowHeight = UITableViewAutomaticDimension
                //self.tableView.estimatedRowHeight = 160.0
                self.tableView.reloadData()  // notify tableView to reload data
                refreshControl.endRefreshing()
                print(String(format:"Number of events loaded: %d",self.events!.count))
                if(events.count>0) {
                    self.formatTable()
                }
            }
        }
    }
    
    // MARK: Sort events by date
    func findSectionForDate(query_date:NSDate) -> Int {
        var res = 0
        
        // binary search
        //var lower = 0
        //var upper = sortedDays.count
        //
        //while lower<upper {
        //    let i = Int((upper+lower-1)/2)
        //    res = i
        //    let cmp = sortedDays[i].compare(query_date)
        //    if cmp == NSComparisonResult.OrderedAscending {
        //        upper = i
        //    } else if cmp == NSComparisonResult.OrderedDescending {
        //        lower = i+1
        //    } else {
        //        return i
        //    }
        //}
        //return res
        
        for (k1, day) in sortedDays.enumerate() {
            if day.compare(query_date) == NSComparisonResult.OrderedSame {
               res = k1
            }
        }
        return res
    }
    
    func sortEvents(){
        sections.removeAll()
        for event in events! {
            
            // Convert time string to a usable NSDate.
            //let formatter = NSDateFormatter()
            //formatter.dateFormat = "M/dd/yy h:mm a"
            //let eventDate = formatter.dateFromString(event.time)
            
            // Break NSDate into components and recombine to only date components.
            let cal = NSCalendar(calendarIdentifier: NSCalendarIdentifierGregorian)!
            let components = cal.components([.Day, .Month, .Year], fromDate: event.time)
            let newDate = cal.dateFromComponents(components)
            
            // If no array for events on this day, create one.
            if sections[newDate!] == nil{
                sections[newDate!] = [Event]()
            }
            
            // Add the event to the array for this day.
            sections[newDate!]?.append(event)
            
        }
        
        // Create a sorted array of the keys for each day.
        sortedDays = Array(sections.keys).sort({ $0.compare($1) == NSComparisonResult.OrderedAscending})
        
        // Sort the events within each day.
        for section in sections{
            let sortedEvents = section.1.sort({$0.time.compare($1.time) == NSComparisonResult.OrderedAscending})
            sections[section.0] = sortedEvents
        }
        
    }
    
    // MARK: Reminders setup
    
    func createReminders(){
        
        for date in sortedDays{
            
            // Break today's date into components and recombine to only date components.
            let cal = NSCalendar(calendarIdentifier: NSCalendarIdentifierGregorian)!
            let components = cal.components([.Day, .Month, .Year], fromDate: NSDate())
            todayDate = cal.dateFromComponents(components)
            
            if todayDate!.compare(date) == NSComparisonResult.OrderedDescending{
                // If event in is the past, don't set up any reminders.
                //print("event is in the past")
            } else{
                
                if todayDate != date{
                    // If the events array is not for today (is therefore for tomorrow or later), set up day-before reminder for these events.
                    
                    // Calculate time for day-before reminder.  Default is 7 pm the day before the event (19:00).
                    var dayBeforeDate = NSCalendar.currentCalendar().dateByAddingUnit(NSCalendarUnit.Day, value: -1, toDate: date, options: NSCalendarOptions.init(rawValue: 0))
                    dayBeforeDate = NSCalendar.currentCalendar().dateBySettingHour(15, minute: 17, second: 0, ofDate: dayBeforeDate!, options: NSCalendarOptions.init(rawValue: 0))
                    
                    if sections[date]!.count > 1{
                        // Schedule a group reminder for the day before these events.
                        let reminder = Reminder(deadline: dayBeforeDate!, title: "Reminder: You have \"\(sections[date]![0].name)\" and \(sections[date]!.count - 1) other events tomorrow", UUID: NSUUID().UUIDString, event: sections[date]![0])
                        ReminderList.sharedInstance.addItem(reminder)
                    } else{
                        
                        // Extract time of event from NSDate.
                        let eventTime = sections[date]![0].time
                        let formatter = NSDateFormatter()
                        formatter.timeStyle = .ShortStyle
                        let eventDate = formatter.stringFromDate(eventTime)
                        
                        // Schedule a reminder for the event giving the event name and time.
                        let reminder = Reminder(deadline: dayBeforeDate!, title: "Reminder: \"\(sections[date]!.first!.name)\" is tomorrow at \(eventDate)", UUID: NSUUID().UUIDString, event: sections[date]![0])
                        ReminderList.sharedInstance.addItem(reminder)
                    }
                    
                    //print("day-before reminder set up")
                } else{
                    //print("events are today")
                }
                
                for event in sections[date]!{
                    
                    // Calculate time for an hours-before reminder. Default is 1 hour before event.
                    let hoursBeforeDate = NSCalendar.currentCalendar().dateByAddingUnit(NSCalendarUnit.Hour, value: -1, toDate: event.time, options: NSCalendarOptions.init(rawValue: 0))
                    
                    // Check whether this time is in the past.
                    if hoursBeforeDate!.timeIntervalSinceNow.isSignMinus {
                        
                        // Event is too soon for a reminder.
                        //print("Event is very soon or already passed")
                        
                    } else{
                        // Get event time from the NSDate.
                        let eventTime = event.time
                        let formatter = NSDateFormatter()
                        formatter.timeStyle = .ShortStyle
                        let eventDate = formatter.stringFromDate(eventTime)
                        
                        if event.question == "no"{
                            
                            // If event does not require a response, schedule a simple reminder.
                            let reminder = Reminder(deadline: hoursBeforeDate!, title: "Reminder: \"\(event.name)\" is today at \(eventDate)", UUID: NSUUID().UUIDString, event: event)
                            ReminderList.sharedInstance.addItem(reminder)
                            
                        } else{
                            
                            // If event needs a response, prompt user to RSVP.
                            let reminder = Reminder(deadline: hoursBeforeDate!, title: "\"\(event.name)\" is today at \(eventDate).  Will you be able to attend?", UUID: NSUUID().UUIDString, event: event)
                            ReminderList.sharedInstance.addItem(reminder)
                        }
                        
                        
                        
                        //print("day of reminder scheduled")
                    }

                }
            }
        }
        
        // Create reminders from an unsorted list of events.
        /*
        for event in events{
            print(event.time)
            
            // Convert time string to a usable NSDate.
            
            let formatter = NSDateFormatter()
            formatter.dateFormat = "M/dd/yy h:mm a"
            let eventDate = formatter.dateFromString(event.time)
            
            if eventDate!.timeIntervalSinceNow.isSignMinus {
                // If event is in the past, don't set up reminders.
                // Eventually add check for whether event is completed.
                print("event is in the past")
            } else{
                
                // Calculate time for an hours-before reminder.  Default is 1 hour before event.
                let hoursBeforeDate = NSCalendar.currentCalendar().dateByAddingUnit(NSCalendarUnit.Hour, value: -1, toDate: eventDate!, options: NSCalendarOptions.init(rawValue: 0))
                
                // Check whether this time is in the past.
                if hoursBeforeDate!.timeIntervalSinceNow.isSignMinus {
                    
                    // Event is too soon for a reminder.
                    print("Event is very soon")
                    
                } else{
                    
                    // Schedule a reminder for shortly before this event.
                    let reminder = Reminder(deadline: hoursBeforeDate!, title: event.name + " is tomorrow.", UUID: NSUUID().UUIDString)
                    ReminderList.sharedInstance.addItem(reminder) // Schedule a local notification to persist this item.
                    
                    // Calculate time for day-before reminder.  Default is 7 pm the day before the event.
                    var dayBeforeDate = NSCalendar.currentCalendar().dateByAddingUnit(NSCalendarUnit.Day, value: -1, toDate: eventDate!, options: NSCalendarOptions.init(rawValue: 0))
                    dayBeforeDate = NSCalendar.currentCalendar().dateBySettingHour(7, minute: 0, second: 0, ofDate: dayBeforeDate!, options: NSCalendarOptions.init(rawValue: 0))
                    
                    // Check whether this time is in the past.
                    if dayBeforeDate!.timeIntervalSinceNow.isSignMinus {
                        
                        // Event is too soon for a reminder.
                        
                        print("Event is too soon for a day-before reminder.")
                    } else{
                        
                        // Schedule a reminder for the day before this event.
                        let reminder = Reminder(deadline: dayBeforeDate!, title: event.name + " is coming soon.", UUID: NSUUID().UUIDString)
                        ReminderList.sharedInstance.addItem(reminder) // Schedule a local notification to persist this item.
                        
                        print("both reminders scheduled")
                    }
                }
                
                
            }
        }*/
        
    }
    
    func formatTable(){
        
        // Find the next event that will occur (for centering tableview on upcoming events).
        //var nextRow = 0
        var nextSection = 0
        
        for (k1, section) in sections.enumerate(){
            if todayDate!.compare(section.0) == NSComparisonResult.OrderedDescending{
                // Event is in the past.
                print(String(format:"date in the past: %@, section %d", section.0, k1))
            } else {
                for (row, event) in section.1.enumerate(){
                    if let soonestEvent = nextEvent{
                        // Find the event with the smallest interval between then and now.
                        //if event.time.timeIntervalSinceNow <= soonestEvent.time.timeIntervalSinceNow{
                        if event.time.compare(soonestEvent.time) != NSComparisonResult.OrderedDescending{
                            nextEvent = event
                            nextSection = findSectionForDate(section.0)
                            print(String(format: "nextEvent: %@, section %d, row %d", section.0, nextSection, row))
                        //for (sect, day) in sortedDays.enumerate(){
                            //nextRow = row
                            //for (sect, day) in sortedDays.enumerate(){
                            //    if day == section.0{
                            //        nextSection = sect
                            //    }
                            //}
                        }
                    }else{
                        nextEvent = event
                        //nextRow = row
                        nextSection = findSectionForDate(section.0)
                        print(String(format: "nextEvent: %@, section %d, row %d", section.0, nextSection, row))
                        //for (sect, day) in sortedDays.enumerate(){
                        //    if day == section.0{
                        //        nextSection = sect
                        //    }
                        //}
                    }
                    
                }
            }
        }
        
        //let indexPath = NSIndexPath(forRow: nextRow, inSection: nextSection)
        let indexPath = NSIndexPath(forRow: 0, inSection: nextSection)
        // Scroll to this cell.
        dispatch_async(dispatch_get_main_queue(), {
            print(String(format:"scrolling to: section %d, row %d", indexPath.section, indexPath.row))
            self.tableView.scrollToRowAtIndexPath(indexPath, atScrollPosition: UITableViewScrollPosition.Top, animated: true)
        })
    }

    // MARK: - Table view data source
    
    /*
    func loadDataFromFile(){
        
        let filePath = NSBundle.mainBundle().pathForResource("sampleevents", ofType: "json")
        let data = try! NSData(contentsOfFile: filePath!,
            options: NSDataReadingOptions.DataReadingUncached)
        
        do{
            let json = try NSJSONSerialization.JSONObjectWithData(data, options: .AllowFragments)
            
            if let eventArray = json["events"] as? [[String: AnyObject]] {
                for event in eventArray {
                    if let _id = event["_id"] as? String, name = event["name"] as? String, location = event["location"] as? String, time = event["time"] as? String, notes = event["notes"] as? String, question = event["question"] as? String, flag = event["flag"] as? String{
                        
                        let formatter = NSDateFormatter()
                        formatter.dateFormat = "M/dd/yy h:mm a"
                        let eventDate = formatter.dateFromString(time)
                        
                        let newEvent = Event(_id: _id, name: name, location: location, time: eventDate!, notes: notes, question: question, flag: flag)!
                        events += [newEvent]
                    }
                }
            }
        } catch {
            print("error serializing JSON: \(error)")
        }
    }
    */

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // Make one section for each day that has events.
        return sections.count
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // Each section should have one row for each event that day.
        let rows = sections[sortedDays[section]]!.count
        print(String(format:"Number of rows in section %d: %d", section, rows))
        return rows
    }
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        // Set header to that day's date in the format "Tuesday, July 12, 2016"
        let formatter = NSDateFormatter()
        formatter.dateFormat = "EEEE, MMMM dd, yyyy"
        let formattedHeader = formatter.stringFromDate(sortedDays[section])
        return formattedHeader
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        // Table view cells are reused and should be dequeued using a cell identifier.
        let cellIdentifier = "EventTableViewCell"
        
        let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier, forIndexPath: indexPath) as! EventTableViewCell
        
        let now = NSDate()
        // Fetches the appropriate event for the data source layout.
        let day = sortedDays[indexPath.section]
        let eventsOfDay = sections[day]
        let event = eventsOfDay![indexPath.row]
        
        let formatter = NSDateFormatter()
        formatter.timeStyle = .ShortStyle
        let eventDate = formatter.stringFromDate(event.time)

        cell.eventNameLabel.text = event.name
        cell.eventDateLabel.text = eventDate
        if(now.compare(event.time) == NSComparisonResult.OrderedDescending) {
            cell.eventNameLabel.textColor = UIColor.grayColor()
            cell.eventDateLabel.textColor = UIColor.grayColor()
        } else {
            cell.eventNameLabel.textColor = UIColor.blackColor()
            cell.eventDateLabel.textColor = UIColor.blueColor()
        }
        // Show location if there are no notes for this event.
        if event.notes == ""{
            cell.notesPreview.text = event.location
        }else{
            cell.notesPreview.text = event.notes
        }
        
        // Change disclosure indicator to question mark if user needs to answer a question.
        /*if event.flag == "missed"{
            let questionMark = UIImage(named: "questionmark")
            let questionImageView = UIImageView(image: questionMark)
            cell.accessoryView = questionImageView
            cell.accessoryView?.frame = CGRect(x: 0, y: 0, width: 24, height: 24)
        }*/

        return cell
    }

    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        let eventDetailViewController = segue.destinationViewController as! EventViewController
        
        // Get the cell that generated this segue.
        if let selectedEventCell = sender as? EventTableViewCell {
            
            let indexPath = tableView.indexPathForCell(selectedEventCell)!
            let selectedDay = sortedDays[indexPath.section]
            let selectedEvent = sections[selectedDay]![indexPath.row]
            eventDetailViewController.event = selectedEvent
            
            //let alertBox = UIAlertController(title: "", message: "Loading ...", preferredStyle: UIAlertControllerStyle.Alert)
      
            //presentViewController(alertBox, animated: true, completion: nil)
            //// retrieve current response
            //let delegate = ApiRequestDelegate()
            //delegate.restGet(String(format:"patient_responses/%@/latest", selectedEvent._id)) {
            //    success,json,_ in
            //    if(success) {
            //      selectedEvent.response = json["response_ID"] as? String
            //      alertBox.message = "Data received from server"
            //      //alertBox.addAction(UIAlertAction(title: "Ok", style: .Default, handler: { (action: UIAlertAction!) in
            //      //    print("Handle Ok logic here")
            //      //}))
            //      alertBox.dismissViewControllerAnimated(true, completion: nil)
            //    } else {
            //      alertBox.message = "Error contacting server"
            //      alertBox.addAction(UIAlertAction(title: "Ok", style: .Default, handler: { (action: UIAlertAction!) in
            //        print("Handle Ok logic here")
            //      }))
            //    }
        
            //}
            
        }
        print("prepareForSegue done")
        
    }
    
    // MARK: NSCoding
    /*
    func saveEvents(){
        let isSuccessfulSave = NSKeyedArchiver.archiveRootObject(events, toFile: Event.ArchiveURL.path!)
        if !isSuccessfulSave{
            print("failed to save")
        }
    }
    
    func loadEvents() -> [Event]?{
        return NSKeyedUnarchiver.unarchiveObjectWithFile(Event.ArchiveURL.path!) as? [Event]
    }
*/

}
