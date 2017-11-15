//
//  ReminderSettingsViewController.swift
//  StudyBuddy
//
//  Created by Abbey Thorpe on 7/6/16.
//  Copyright © 2016 Abbey Thorpe. All rights reserved.
//  Copyright © 2016,2017 Yong Lu. All rights reserved.
//

import UIKit

class ReminderSettingsViewController: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate {
    
    // MARK: Properties
    
    @IBOutlet weak var dayPickerView: UIPickerView!
    @IBOutlet weak var hourPickerView: UIPickerView!
    @IBOutlet weak var minPickerView: UIPickerView!
    
    var days = 0;
    var hours = 0;
    var mins = 0;
    
    var optionsDays  = ["0","1","2","3","4","5","6","7"];
    var optionsHours = ["0","1","2","3","4","5","6","7","8","9",
                           "10","11","12","13","14","15","16","17","18","19",
                           "20","21","22","23"];
    var optionsMins  = ["0","15","30","45"];
    // MARK: Actions
    
    override func viewDidLoad() {
        super.viewDidLoad()
        days = User.notifyDaysBefore!
        hours = User.notifyHoursBefore!
        mins = User.notifyMinsBefore!
        self.dayPickerView.dataSource = self;
        self.dayPickerView.delegate = self;
        dayPickerView.selectRow(User.notifyDaysBefore!, inComponent:0, animated:false)
        self.hourPickerView.dataSource = self;
        self.hourPickerView.delegate = self;
        hourPickerView.selectRow(User.notifyHoursBefore!, inComponent:0, animated:false)
        self.minPickerView.dataSource = self;
        self.minPickerView.delegate = self;
        minPickerView.selectRow(User.notifyMinsBefore!/15, inComponent:0, animated:false)
    }
    
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
      if (pickerView.tag == 1){
          return optionsDays.count
      }else{
        if (pickerView.tag == 2){
          return optionsHours.count
        } else {
          return optionsMins.count
        }
      }
    }
    
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String! {
        if (pickerView.tag == 1){
            return "\(optionsDays[row])"
        }else{
            if (pickerView.tag == 2){
                return "\(optionsHours[row])"
            } else {
                return "\(optionsMins[row])"
            }
        }
    }
    
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if (pickerView.tag == 1){
            days = row
        }else{
            if (pickerView.tag == 2){
                hours = row
            } else {
                mins = row * 15
            }
        }
    }
    
    
    //
    
    
    @IBAction func savePressed(sender: UIButton) {
        let msg = String(format:"%d days %d@ hours %d mins", days, hours, mins)
        let alertBox = UIAlertController(title: "", message: msg, preferredStyle: UIAlertControllerStyle.Alert)
      
        alertBox.addAction(UIAlertAction(title: "Ok", style: .Default, handler: { (action: UIAlertAction!) in
            print("Handle Ok logic here")
            User.notifyDaysBefore = self.days
            User.notifyHoursBefore = self.hours
            User.notifyMinsBefore = self.mins
            User.saveConfig()
            // need to re-register notifications
            if let navController = self.navigationController {
                navController.popViewControllerAnimated(true)
            }
        }))
        
        presentViewController(alertBox, animated: true, completion: nil )
    }
}
