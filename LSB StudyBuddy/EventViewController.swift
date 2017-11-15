//
//  EventViewController.swift
//  StudyBuddy
//
//  Created by Abbey Thorpe on 6/9/16.
//  Copyright © 2016 Abbey Thorpe. All rights reserved.
//  Copyright © 2016,2017 Yong Lu. All rights reserved.
//

import UIKit

class EventViewController: UITableViewController, UINavigationControllerDelegate {
    
    // MARK: Properties
    var response_changed = false  // flag indicating we should send data to the server
    var param: [String:String]?   // data to send to sever
    var curSelectedResponse: Int?
    var prevSelectedResponse: Int?
    
    @IBOutlet weak var eventNameLabel: UILabel!
    @IBOutlet weak var eventLocationLabel: UILabel!
    @IBOutlet weak var eventDateLabel: UILabel!
    @IBOutlet weak var eventNotes: UITextView!
    
    @IBOutlet weak var questionLabel: UILabel!
    @IBOutlet weak var noneCheck: UILabel!
    
    @IBOutlet weak var option1: UITableViewCell!
    @IBOutlet weak var option1Label: UILabel!
    @IBOutlet weak var option1Check: UILabel!
    
    @IBOutlet weak var option2: UITableViewCell!
    @IBOutlet weak var option2Label: UILabel!
    @IBOutlet weak var option2Check: UILabel!
    
    @IBOutlet weak var option3Label: UILabel!
    @IBOutlet weak var option3: UITableViewCell!
    @IBOutlet weak var option3Check: UILabel!
    
    var event: Event?
    var questions = [Question]()
    var firstOptions = [Answer]()
    var numberOptions = 0
    var selectedAnswer: Answer?
    
    var alertLoading = UIAlertController(title: "", message: "Loading ...", preferredStyle: UIAlertControllerStyle.Alert)
    var dataLoaded = false
    var alertLoadingDismissed = false
    var minQID : String?
    var checked_any = false
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set up views.
        
        if let event = event {
            
            let formatter = NSDateFormatter()
            formatter.dateFormat = "EEEE, MMMM dd, yyyy' at 'h:mm a"
            let eventDate = formatter.stringFromDate(event.time)
            
            // navigationItem.title = event.name
            eventNameLabel.text = event.name
            eventLocationLabel.text = event.location
            eventDateLabel.text = eventDate
            eventNotes.text = event.notes
            
            if param == nil {
                param = [
                    "event_id"           : event._id,
                    "event_name"         : event.name,
                    "event_location"     : event.location,
                    "event_time"         : User.dateFormatter.stringFromDate(event.time),
                    "studyflow_id"  : event.studyflow_id,
                    "subject_email" : User.email!,
                    "subject_name" : User.name!
                ]
            }
            // let alertBox = UIAlertController(title: "", message: "Loading ...", preferredStyle: UIAlertControllerStyle.Alert)
      
            // presentViewController(alertBox, animated: true, completion: nil)
            // // retrieve current response
            let delegate = ApiRequestDelegate()
            delegate.restGet(String(format:"patient_responses/%@/latest", event._id)) {
                success,_json,_ in
                if(success) {
                  let json: NSDictionary = _json!
                  if((json["data"] != nil)) {
                    event.response = json["data"]!["response_ID"] as? String
                    if(event.response != nil) {
                      print(String(format:"event.response = %@", event.response!))  // may be nil
                      self.alertLoading.message = "Data received from server"
                      self.param!["response_ID"] = event.response
                      self.param!["response_text"] = json["data"]!["response_text"] as? String
                      self.param!["curReasonID"]   = json["data"]!["reason_ID"] as? String
                      self.param!["est_arrival"]   = json["data"]!["est_arrival"] as? String
                      self.param!["additional_response"] = json["data"]!["response_details"] as? String
                           
                      // [Warning: current solution may have race conditions]
                      // (1) If self.firstOptions is already initialized,
                      //     update the selected choice.
                      // (2) Otherwise (i.e. restGet finishes before self.firstOptions is
                      //     filled in) there is no guarantee that viewDidLoad will see the
                      //     selected response.
                      if(true) {
                        let options = self.firstOptions
                        for (index, option) in options.enumerate(){
                            if index == 0 {
                                if option.AID == event.response {
                                    self.option1Check.hidden = false
                                    self.curSelectedResponse = 0
                                    self.checked_any = true
                                } else {
                                    self.option1Check.hidden = true
                                }
                                if option.next != "" && option.next != "end"{
                                    self.option1.accessoryType = UITableViewCellAccessoryType.DisclosureIndicator
                                }
                            } else if index == 1 {
                                self.option2Label.text = option.text
                                if option.AID == event.response {
                                    self.option2Check.hidden = false
                                    self.curSelectedResponse = 1
                                    self.checked_any = true
                                } else {
                                    self.option2Check.hidden = true
                                }
                                if option.next != "" && option.next != "end"{
                                    self.option2.accessoryType = UITableViewCellAccessoryType.DisclosureIndicator
                                }
                            } else if index == 2 {
                                self.option3Label.text = option.text
                                if option.AID == event.response {
                                    self.option3Check.hidden = false
                                    self.curSelectedResponse = 2
                                    self.checked_any = true
                                } else {
                                    self.option3Check.hidden = true
                                }
                                if option.next != "" && option.next != "end"{
                                    self.option3.accessoryType = UITableViewCellAccessoryType.DisclosureIndicator
                                }
                            }
                        }
                        if self.checked_any {
                            self.noneCheck.hidden = true
                        } else {
                            self.curSelectedResponse = -1
                            self.noneCheck.hidden = false
                        }
                      }
                    }
                  }
                  self.dataLoaded = true
                  self.alertLoading.dismissViewControllerAnimated(true, completion:{
                        self.alertLoadingDismissed = true
                  })
                } else {
                  self.alertLoading.message = "Error contacting server"
                  self.alertLoading.addAction(UIAlertAction(title: "Ok", style: .Default, handler: { (action: UIAlertAction!) in
                        self.alertLoadingDismissed = true
                  }))
                }
        
            }
            // TODO: update param based on results from the server before displaying the scene
            print(String(format:"param: %@", param!))
            //print(String(format:"event.response: %@", event.response!))
            
                /*
            // for upcoming events
            if event.flag! == "" {
                option1Label.textColor = UIColor.redColor()
                option2Label.textColor = UIColor.blackColor()
                answerLabel.textColor = UIColor.blackColor()
            }
            if event.flag! == "confirmed" {
                option1Label.textColor = UIColor.blackColor()
                option2Label.textColor = UIColor.redColor()
                answerLabel.textColor = UIColor.blackColor()
            }
            if event.flag! == "missed" {
                option1Label.textColor = UIColor.blackColor()
                option2Label.textColor = UIColor.blackColor()
                answerLabel.textColor = UIColor.redColor()
            }*/
            
            // Set up questions.
            if event.question == "yes"{
                loadQuestionsFromFile() // If event is actionable, load questions.
                var minQIDnum = UInt.max
                for question in questions{
                    let x = question.QID.componentsSeparatedByString("Q")
                    print(x[1])
                    let y = UInt(x[1])
                    if y! < minQIDnum {
                        minQIDnum = y!
                    }
                }
                minQID = String(format:"Q%d", minQIDnum)
                for question in questions{
                    // Find the first question.
                    if question.QID == minQID {
                        // Display the first question.
                        questionLabel.text = question.text
                        // Find possible answers.
                        if let options = question.options {
                            numberOptions = options.count // For determining number of rows in section.
                            for (index, option) in options.enumerate(){
                                // Add this option to the "firstOptions" array to be accessed later.
                                firstOptions += [option]
                                // Assign correct label to each option and add disclosure indicator if it has follow-up questions.
                                if index == 0 {
                                    option1Label.text = option.text
                                    if option.AID == event.response {
                                        option1Check.hidden = false
                                        curSelectedResponse = 0
                                        checked_any = true
                                    } else {
                                        option1Check.hidden = true
                                    }
                                    if option.next != "" && option.next != "end"{
                                        option1.accessoryType = UITableViewCellAccessoryType.DisclosureIndicator
                                    }
                                } else if index == 1 {
                                    option2Label.text = option.text
                                    if option.AID == event.response {
                                        option2Check.hidden = false
                                        curSelectedResponse = 1
                                        checked_any = true
                                    } else {
                                        option2Check.hidden = true
                                    }
                                    if option.next != "" && option.next != "end"{
                                        option2.accessoryType = UITableViewCellAccessoryType.DisclosureIndicator
                                    }
                                } else if index == 2 {
                                    option3Label.text = option.text
                                    if option.AID == event.response {
                                        option3Check.hidden = false
                                        curSelectedResponse = 2
                                        checked_any = true
                                    } else {
                                        option3Check.hidden = true
                                    }
                                    if option.next != "" && option.next != "end"{
                                        option3.accessoryType = UITableViewCellAccessoryType.DisclosureIndicator
                                    }
                                }
                            }
                        }
                        if checked_any {
                            noneCheck.hidden = true
                        } else {
                            curSelectedResponse = -1
                            noneCheck.hidden = false
                        }
                    }
                }
            }
            
        }
        
        
        // Allow autolayout to control cell height
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 50
        //tableView.reloadData()
        
    }
    
    override func viewDidAppear(animated: Bool) {
        if(!dataLoaded && !alertLoadingDismissed) {
            presentViewController(alertLoading, animated: true, completion: nil)
        }
    }
    
    // Override heightForRow delegate.
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        
        return UITableViewAutomaticDimension
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        if event?.question == "no" {
            return 1 // Don't show question if event is not actionable.
        }else if event?.flag == ""{
            // always display 2 sections regardless whether event is in the past
            return 2
           // let nowTime = NSDate()
           // if nowTime.compare((event?.time)!) == NSComparisonResult.OrderedDescending{
           //     // If event in is the past and has no flags, don't display questions.
           //     return 1
           // } else {
           //     // If event is in the future, is actionable, and has no flags, display "soon" questions.
           //     return 2
           // }
        }
        return 2 // Assume questions displayed for all other situations, because event should have a flag.
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 1{
            // For questions section, number of rows needed is number of options plus one for question and one for "no selection".
            return numberOptions+2
        }
        // Section 0, the details section, has two rows.
        return 2
    }
    
    func selectResponse(choice: Int) {
        // Code to give selected cell a red checkmark.
        var selectedCell: UILabel?
        var answerID: String?
        var answerText: String?
        
        let labelArray = [option1Check, option2Check, option3Check]
        let i = choice
        // Find the selected cell.
        if i < -1 {
            return
        }
        if i == -1 {
            selectedCell = noneCheck
            answerID = "none"
            param!["response_text"] = ""
            param!["response_ID"] = ""
            if curSelectedResponse != -1 {
                response_changed = true
                prevSelectedResponse = curSelectedResponse
                curSelectedResponse = -1
            }
        } else {
            selectedCell = labelArray[i]  // option1Check
            answerID = firstOptions[i].AID
            answerText = firstOptions[i].text
            param!["response_text"] = String(format:"%@: %@", answerID!, answerText!)
            param!["response_ID"] = answerID
            // always update because we may lose track of past
            // selections if the user selected detailed reason from 
            // another screen
            //if curSelectedResponse != i {
                response_changed = true
                prevSelectedResponse = curSelectedResponse
                print("selecteResponse")
                print(prevSelectedResponse)
                print(curSelectedResponse)
                curSelectedResponse = i
            //}
        }
        
        // Display the checkmark for the selected cell.
        selectedCell?.hidden = false
        
        // Hide all other checkmarks.
        for label in [noneCheck, option1Check, option2Check, option3Check]{
            if label != selectedCell{
                label.hidden = true
            }
        }
        
        // Code to trigger segue if answer has further questions.
        
        // Find the answer that was selected.
        for option in firstOptions{
            if option.AID == answerID{
                if option.next != "end" && option.next != ""{
                    selectedAnswer = option
                    performSegueWithIdentifier("moreQuestions", sender: self)
                } else {
                    // Selected option has no further questions so don't trigger segue.
                }
            }else {
                // Selected option was "no selection" so there will be no stored option.
            }
        }
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        selectResponse(indexPath.row - 2)
    }                  

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: Data
    
    // reads questions from the local files
    func loadQuestionsFromFile(){
        let filePath = NSBundle.mainBundle().pathForResource("sampleevents", ofType: "json")
        let data = try! NSData(contentsOfFile: filePath!,
            options: NSDataReadingOptions.DataReadingUncached)
        questions = []
        do {
            let json = try NSJSONSerialization.JSONObjectWithData(data, options: .AllowFragments)
            //print("finding questions")
            if let questionsArray = json["questions"] as? [String: AnyObject]{
                if event!.flag != ""{
                    //If the event has a flag for type of question, like that the user missed the 
                    // appointment, display the questions for that flag.
                    // right now the only scenario that we ask for feedbacks is when event!.flag == "missed"
                    
                    //print(NSString(format:"finding questions step 1: %d sections found", questionsArray.count))
                    if true {
                        if let array = questionsArray[event!.flag!] as? [[String: AnyObject]]{
                            for question in array{
                                if let QID = question["QID"] as? String, text = question["text"] as? String{
                                    if let options = question["options"] {
                                        if options as? String == ""{
                                            let newQuestion = Question(QID: QID, text: text, options: nil)!
                                            questions += [newQuestion]
                                        } else if let answerArray = options as? [[String: AnyObject]]{
                                            var answers = [Answer]()
                                            for answer in answerArray{
                                                if let flag = answer["flag"] as? String, AID = answer["AID"] as? String, text = answer["text"] as? String, next = answer["next"] as? String{
                                                    let newAnswer = Answer(AID: AID, flag: flag, next: next, text: text)!
                                                    answers += [newAnswer]
                                                }
                                            }
                                            let newQuestion = Question(QID: QID, text: text, options: answers)!
                                            questions += [newQuestion]
                                        }
                                    }
                                }
                            }
                        }
                    }
                } else {
                    // Check if the event has already passed and if not, display the questions for an upcoming event.
                    //let todayDate = NSDate()
                    if true {
                    //if todayDate.compare((event?.time)!) == NSComparisonResult.OrderedDescending{
                    //    // If event in is the past and has no flags, don't display any questions.
                    //    //print("event is in the past")
                    //} else {
                        // If event is in the future, display "soon" questions
                        //print("event is in the future")
                        if let array = questionsArray["soon"] as? [[String: AnyObject]]{
                            for question in array{
                                if let QID = question["QID"] as? String, text = question["text"] as? String{
                                    if let options = question["options"] {
                                        if options as? String == ""{
                                            let newQuestion = Question(QID: QID, text: text, options: nil)!
                                            questions += [newQuestion]
                                        } else if let answerArray = options as? [[String: AnyObject]]{
                                            var answers = [Answer]()
                                            for answer in answerArray{
                                                if let flag = answer["flag"] as? String, AID = answer["AID"] as? String, text = answer["text"] as? String, next = answer["next"] as? String{
                                                    let newAnswer = Answer(AID: AID, flag: flag, next: next, text: text)!
                                                    answers += [newAnswer]
                                                }
                                            }
                                            let newQuestion = Question(QID: QID, text: text, options: answers)!
                                            questions += [newQuestion]
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
            //print(NSString(format:"questions found: %d", questions.count))
        }catch{
            print("error serializing JSON: \(error)")
        }
    }
    
    // MARK: Navigation
    
    @IBAction func cancelEventResponse(sender: AnyObject) {
        //self.dismissViewControllerAnimated(true, completion: nil)
        navigationController?.popViewControllerAnimated(true)
    }
    
    @IBAction func submitEventResponse(sender: AnyObject) {
        let delegate = ApiRequestDelegate()
        if response_changed {
            let alertBox = UIAlertController(title: "", message: "Submitting response ...", preferredStyle: UIAlertControllerStyle.Alert)
            //alertBox.addAction(UIAlertAction(title: "Ok", style: .Default, handler: { (action: UIAlertAction!) in
            //    print("Handle Ok logic here")
            //}))
            presentViewController(alertBox, animated: true, completion: nil)
            
            print("Submitting response ...")
            param!["submit_time"] =  User.dateFormatter.stringFromDate(NSDate())
            delegate.post(param!, apiPath: "patient_responses") {
                (success, server_response, error, jsonDict, jsonString) in
                if(success) {
                  alertBox.message = "Your response has been submitted!"
                  alertBox.addAction(UIAlertAction(title: "Ok", style: .Default, handler: { (action: UIAlertAction!) in
                      self.navigationController?.popViewControllerAnimated(true)
                      print("Handle Ok logic here")
                  }))
                } else {
                  alertBox.message = "Error submitting the response."
                  alertBox.addAction(UIAlertAction(title: "Ok", style: .Default, handler: { (action: UIAlertAction!) in
                      self.navigationController?.popViewControllerAnimated(true)
                      print("Handle Ok logic here")
                  }))
                }
            }
        }
        //self.dismissViewControllerAnimated(true, completion: nil)
        navigationController?.popViewControllerAnimated(true)
    }
    
    
    
    // This method lets you configure a view controller before it's presented.
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        let navigationController = segue.destinationViewController as! UINavigationController
        if let firstQuestionViewController = navigationController.topViewController as? FirstQuestionTableViewController {
        
            // Send questions array to next view controller.
            firstQuestionViewController.questions = questions
            firstQuestionViewController.firstQID = selectedAnswer?.next
            firstQuestionViewController.event = event
            
            print(param)
            // the user have visited the detailed reason screen and made her choice.
            // we will select that choice even though it is not submitted
            if let curReason = param!["curReasonID"] {
                firstQuestionViewController.selectedResponseID = curReason
            }
            if let text = param!["additional_response"] {
                firstQuestionViewController.curText = text
            } else {
                if let text = event!.additional_response {
                    firstQuestionViewController.curText = text
                }
            }
            if let date = param!["est_arrival"] {
                firstQuestionViewController.prevSelectedArrivalTime = User.dateFormatter.dateFromString(date)
            } else {
                if let date = event!.est_arrival {
                    firstQuestionViewController.prevSelectedArrivalTime = date
                }
            }
            
            firstQuestionViewController.onDiscardUserResponse = {[weak self]
                (data) in
                if let weakSelf = self {
                    // force to forget the current selection
                    if weakSelf.prevSelectedResponse != nil {
                        print("onDiscard")
                        print(weakSelf.prevSelectedResponse)
                        print(weakSelf.curSelectedResponse)
                        weakSelf.curSelectedResponse = weakSelf.prevSelectedResponse
                        // simulate previous selection
                        weakSelf.selectResponse(weakSelf.prevSelectedResponse!)
                    }
                }
            }
            firstQuestionViewController.onSaveUserResponse = {[weak self]
                (data) in
                if let weakSelf = self {
                    if let val = data["est_arrival"] {
                        weakSelf.param!["est_arrival"] = val
                    }
                    if let val = data["reason"] {
                        weakSelf.param!["reason"] = val
                    }
                    if let val = data["curReasonID"] {
                        weakSelf.param!["curReasonID"] = val
                    }
                    if let val = data["additional_response"] {
                        weakSelf.param!["additional_response"] = val
                    }
                }
            }
        }
    }


    
}

