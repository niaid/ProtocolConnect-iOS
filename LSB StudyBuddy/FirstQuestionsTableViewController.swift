//
//  FirstQuestionsTableViewController.swift
//  StudyBuddy
//
//  Created by Abbey Thorpe on 7/19/16.
//  Copyright © 2016 Abbey Thorpe. All rights reserved.
//  Copyright © 2016,2017 Yong Lu. All rights reserved.
//

import UIKit

class FirstQuestionTableViewController: UITableViewController {
    
    // MARK: Properties
    var onSaveUserResponse : ((data: [String:String]) -> ())?
    var onDiscardUserResponse : ((data: [String:String]) -> ())?
    var event: Event?
    var questions: [Question]?
    var firstQuestion: Question?
    var firstQID: String?
    var selectedResponseID: String?
    var selectedResponseText: String?
    var prevSelectedArrivalTime : NSDate?
    var datePickerIndexPath : NSIndexPath?
    var datePickerCell : DatePickerCell?
    //var curQuestion: Question?
    var textViewIndexPath : NSIndexPath?
    var curText : String?
    var textView : UITextView?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Find first question.
        for question in questions!{
            if question.QID == firstQID{
                firstQuestion = question
                // check selectedResponseID first because the user
                // may have specified (unsaved) reasons in this session
                var curReason = selectedResponseID
                if curReason == nil {
                    curReason = event!.reason
                }
                if curReason != nil {
                    for (i, opt) in (firstQuestion?.options!.enumerate())! {
                        if curReason == opt.AID {
                            selectedResponseID = opt.AID
                            selectedResponseID = opt.text
                            tableView.reloadData()
                            selectReason(i)
                        }
                    }
                }
            }
        }
        
        // Allow autolayout to control cell height
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 50
    }
   /*
    override func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerCell = tableView.dequeueReusableCellWithIdentifier("QuestionHeader") as! QuestionHeaderCell
        headerCell.questionLabel.text = firstQuestion?.text
        return headerCell
    }*/
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        var numberSections = 1
        
        // Add one section for each option with a flag.
        for option in (firstQuestion?.options)!{
            if option.flag != ""{
                numberSections += 1
            }
        }
        
        return numberSections
    }
    override func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 5.0
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        // Get the correct height if the cell is a DatePickerCell.
        // let cell = self.tableView(tableView, cellForRowAtIndexPath: indexPath)  // may cause infinite loop
        // var rowHeight = super.tableView(tableView, heightForRowAtIndexPath: indexPath)
        var rowHeight = tableView.rowHeight
        if datePickerIndexPath != nil && datePickerIndexPath!.row == indexPath.row && datePickerIndexPath!.section == indexPath.section   {
            let cell = tableView.dequeueReusableCellWithIdentifier("DatePickerCell")! 
            rowHeight = cell.frame.height
        } else if textViewIndexPath != nil && textViewIndexPath!.row == indexPath.row && textViewIndexPath!.section == indexPath.section   {
            let cell = tableView.dequeueReusableCellWithIdentifier("TextEditCell")!
            rowHeight = cell.frame.height
        }
        
        return rowHeight
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        // First section should have a row for each option + the question header.
        var numberRows = 1
        if section == 0 {
            for option in (firstQuestion?.options)!{
                if option.flag == ""{
                    numberRows += 1
                }
            }
            return numberRows
        }
        
        // All other sections, the special kinds, should only have two rows.
        return 2
    }

    

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        print("Row: \(indexPath.row), Section: \(indexPath.section)")
        if indexPath.section == 0{
            // First section, which will always be present, should have a header cell and then several selectable options.
            if indexPath.row == 0{
                // First cell should be header cell.
                let headerCell = tableView.dequeueReusableCellWithIdentifier("QuestionHeader") as! QuestionHeaderCell
                headerCell.questionLabel.text = firstQuestion?.text
                return headerCell
            } else{
                let cell = tableView.dequeueReusableCellWithIdentifier("ResponseCell", forIndexPath: indexPath) as! ResponseCell
                cell.ResponseLabel.text = firstQuestion?.options![indexPath.row-1].text
                return cell
            }
        } else {
            var customCells = [Answer]()
            
            // Make a section for each option with a flag.
            for option in (firstQuestion?.options)!{
                if option.flag != ""{
                    customCells += [option]
                }
            }
            if indexPath.row == 0{
                //First cell should be header cell.
                let headerCell = tableView.dequeueReusableCellWithIdentifier("QuestionHeader") as! QuestionHeaderCell
                headerCell.questionLabel.text = customCells[indexPath.section-1].text
                return headerCell
            } else {
                // Second and only other cell should be a custom cell.
                let flag = customCells[indexPath.section-1].flag
                if flag == "timepicker" {
                    datePickerIndexPath = indexPath
                    let cell = tableView.dequeueReusableCellWithIdentifier("DatePickerCell", forIndexPath: indexPath) as! DatePickerCell
                    let datePicker = cell.viewWithTag(1) as! UIDatePicker // set the tag of Date Picker to be 1 in the Attributes Inspector
                    if let date = prevSelectedArrivalTime {
                            datePicker.setDate(date, animated: true)
                    } else {
                        let now = NSDate()
                        if (now.compare(event!.time) == NSComparisonResult.OrderedAscending) {
                            datePicker.setDate(event!.time, animated: true)
                        } else {
                            datePicker.setDate(now, animated: true)
                        }
                    }
                    datePickerCell = cell
                    return cell
                } else if flag == "textbox" {
                    textViewIndexPath = indexPath
                    let cell = tableView.dequeueReusableCellWithIdentifier("TextEditCell", forIndexPath: indexPath) as! TextEditCell
                    textView = cell.viewWithTag(2) as? UITextView // set the tag of Text Field to be 2 in the Attributes Inspector
                    if let text = curText {
                        textView!.text = text
                    }
                    self.view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|-0.0-[textView]-0.0-|", options: [], metrics: nil, views: ["textView": textView!]))
                    return cell
                } else {
                    /* for all other flags currently not supported */
                    let cell = tableView.dequeueReusableCellWithIdentifier("ResponseCell", forIndexPath: indexPath) as! ResponseCell
                    cell.ResponseLabel.text = flag
                    return cell
                }
            }
        }
    }

    // choice \in {0,1,...}
    func selectReason(choice: Int) {
        // Code to give selected cell a red check if appropriate.

        let cells = self.tableView.visibleCells as! Array<ResponseCell>
        cells[choice+1].ResponseCheck.hidden = false
        
        let responseIndex = choice
        selectedResponseID = firstQuestion?.options![responseIndex].AID
        selectedResponseText = firstQuestion?.options![responseIndex].text

        // Find number of rows in the section.
        var optionCount = 0
        for option in (firstQuestion?.options)!{
            if option.flag == ""{
                optionCount += 1
            }
        }
        
        // Hide check for all cells that weren't selected.
        for i in 1...optionCount{
            if i != (choice+1){
                cells[i].ResponseCheck.hidden = true
            }
        }
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if indexPath.section == 0 && indexPath.row != 0{
            // Only cells in the first section should have checks, because the other sections have special response types.
            selectReason(indexPath.row-1)
        }
    }

    
    // MARK: Actions
    
    @IBAction func cancelResponse(sender: AnyObject) {
        let data = [
            "event_id": event!._id,
            "subject_email": User.email!,
            "studyflow_id": event!.studyflow_id,
            // "reason"
            // "est_arrival"
            // "additional_response"
        ]
        self.onDiscardUserResponse?(data: data)
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func submitResponse(sender: AnyObject) {
        print("Submit button clicked")
        let curDate = User.dateFormatter.stringFromDate(NSDate())
        print("Submission time: "+curDate)
        print("study flow id: "+event!.studyflow_id)
        print(event!._id)
        print(User.email!)
        print(event!.name)
        print(event!.location)
        print(event!.time)
        print("["+firstQID!+"] " + firstQuestion!.text)
        var data = [
            "event_id": event!._id,
            "subject_email": User.email!,
            "studyflow_id": event!.studyflow_id,
            // "est_arrival"
            // "additional_response"
        ]
        if selectedResponseID != nil {
            print("["+selectedResponseID!+"] "+selectedResponseText!)
            data["reason"] = String(format:"%@: %@", selectedResponseID!, selectedResponseText!)
            data["curReasonID"] = selectedResponseID
        }
        if let text = textView?.text {
            data["additional_response"] = text
        }
        if let date = datePickerCell?.dateSelected {
            let strDate = User.dateFormatter.stringFromDate(date)
            data["est_arrival"] = strDate
            print("Est. arrival time: "+strDate)
        }
        // TODO free text field
        
        self.onSaveUserResponse?(data: data)
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
}
