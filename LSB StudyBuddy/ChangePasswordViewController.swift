//
//  ChangePasswordViewController.swift
//  Clinical Study Buddy
//
//  Created by Abbey Thorpe on 15/11/16.
//  Copyright © 2016 Abbey Thorpe. All rights reserved.
//  Copyright © 2016,2017 Yong Lu. All rights reserved.
//

import UIKit

class ChangePasswordViewController: UIViewController{
    
    @IBOutlet weak var currentPasswordTextField: UITextField!
    @IBOutlet weak var newPasswordTextField: UITextField!
    @IBOutlet weak var verifyPasswordTextField: UITextField!
    // MARK: Actions
    
    @IBAction func cancelChangePassword(sender: AnyObject) {
        
        self.dismissViewControllerAnimated(true, completion: nil)
    }

    
    @IBAction func confirmPasswordChange(sender: AnyObject) {
        var msg : String?;
        if(currentPasswordTextField.text == nil || currentPasswordTextField.text != User.password) {
            msg = "Mistake in your current password"
        } else {
          if(newPasswordTextField.text == nil ||  verifyPasswordTextField.text == nil) {
            msg = "New password is empty"
          } else {
            if(newPasswordTextField.text!.characters.count < 6) {
              msg = "Password should be at least 6 characters long"
            } else {
              if(newPasswordTextField.text! != verifyPasswordTextField.text!) {
                msg = "New passwords do not match"
              }
            }
          }
        }
        if(msg != nil){
            let alertBox = UIAlertController(title: "Warning", message: msg!, preferredStyle: UIAlertControllerStyle.Alert)
          
            alertBox.addAction(UIAlertAction(title: "Ok", style: .Default, handler: { (action: UIAlertAction!) in
                print("Handle Ok logic here")
            }))
            
            presentViewController(alertBox, animated: true, completion: nil)
        } else {
            // show a message: "Updating ..."
            let alertBox = UIAlertController(title: "", message: "Updating password ...", preferredStyle: UIAlertControllerStyle.Alert)
            presentViewController(alertBox, animated: true, completion: nil)
            
            // submit the password change
            let delegate = ApiRequestDelegate()
            delegate.updatePassword(User.email!, old_pass: currentPasswordTextField.text!, new_pass: newPasswordTextField.text!) {
              (successful:Bool) in
                // if successful segue back, otherwise show error
                if(successful) {
                    print("successful return from password update")
                   alertBox.message = "Password has been updated!"
                   
                   alertBox.addAction(UIAlertAction(title: "Ok", style: .Default, handler: { (action: UIAlertAction!) in
                        self.dismissViewControllerAnimated(true, completion: nil)
                   }))
                } else {
                    print("password update failed")
                   alertBox.message = "Error while updating password"
                   alertBox.addAction(UIAlertAction(title: "Ok", style: .Default, handler: { (action: UIAlertAction!) in
                       print("Handle Ok logic here")
                   }))
                }
            }
        }

    }
    
    
}
