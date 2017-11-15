//
//  ForgotPasswordViewController.swift
//  StudyBuddy
//
//  Created by Abbey Thorpe on 6/22/16.
//  Copyright © 2016 Abbey Thorpe. All rights reserved.
//  Copyright © 2016,2017 Yong Lu. All rights reserved.
//

import UIKit

class ForgotPasswordViewController: UIViewController{
    
    @IBOutlet weak var userEmail: UITextField!
    
    @IBOutlet var resetPasswordMessage: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        // Set up views.
        
    }
    
    // MARK: Actions
    
    
    @IBAction func resetPassword(sender: AnyObject) {
        // use RESTful api to reset password
        let delegate = ApiRequestDelegate();
        if(userEmail.text == "") {
            // print warning
        } else {
            print(userEmail.text);
            let url = "resetPassword/" + userEmail.text!;
            delegate.restGet(url) {
                (success,json: NSDictionary?,JsonString:String?) in
                if(success) {
                    self.resetPasswordMessage.text = "Check your email for new password."
                } else {
                    self.resetPasswordMessage.text = "Error resetting password"
                }
            };
        }
    }
    
    @IBAction func cancelPasswordReset(sender: AnyObject) {
        
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    
}
