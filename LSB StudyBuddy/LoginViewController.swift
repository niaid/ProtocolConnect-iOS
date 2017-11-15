//
//  LoginViewController.swift
//  StudyBuddy
//
//  Created by Abbey Thorpe on 6/20/16.
//  Copyright © 2016 Abbey Thorpe. All rights reserved.
//  Copyright © 2016,2017 Yong Lu. All rights reserved.
//

import UIKit
import LocalAuthentication

class LoginViewController: UIViewController, UITextFieldDelegate {
    
    // MARK: Properties
    
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var warningLabel: UILabel!
    
    var currentUser: User!
    
    // Keychain code from https://www.raywenderlich.com/92667/securing-ios-data-keychain-touch-id-1password
    let MyKeychainWrapper = KeychainWrapper()
    let createLoginButtonTag = 0
    let loginButtonTag = 1
    var context = LAContext()
    
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var touchIDButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Handle the text field's user input through delegate callbacks.
        usernameTextField.delegate = self
        passwordTextField.delegate = self
        
        // If device supports Touch ID then show touchIDButton
        touchIDButton.hidden = true
        if context.canEvaluatePolicy(LAPolicy.DeviceOwnerAuthenticationWithBiometrics, error: nil){
            touchIDButton.hidden = false
        }
        
        
        // If user info is already available, fill in fields automatically.
        if let storedEmail = NSUserDefaults.standardUserDefaults().valueForKey("username") as? String {
            usernameTextField.text = storedEmail as String
        }
        
        // Call TouchID function -- disabled for now.
        
        // The proper logic should be:
        // 1. The first time a user properly logs in, ask her whether she wants to use finger print in the future
        //   1.1 if the answer is yes, then save the answer along with username/password in a local preference file
        // 2. When the app is launched next time, check the setting to see if we should use finger print to login
        
        // authenticateUser()
        
    }
    
    // MARK: UITextFieldDelegate
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        // Hide the keyboard when user taps "done" or "return" on keyboard.
        textField.resignFirstResponder()
        return true
    }
    
    
    // MARK: Actions
    
    @IBAction func touchIDLoginAction(sender: UIButton) {
        
        // Make sure device is Touch ID capable
        if context.canEvaluatePolicy(LAPolicy.DeviceOwnerAuthenticationWithBiometrics, error: nil){
            
            // Prompt user to login with Touch ID
            context.evaluatePolicy(LAPolicy.DeviceOwnerAuthenticationWithBiometrics, localizedReason: "Logging in with Touch ID", reply: { (success : Bool, error: NSError?) -> Void in
                
                dispatch_async(dispatch_get_main_queue(), {
                    if success {
                        // Retrieve username and password and check login.
                        if let loadedUsername = NSUserDefaults.standardUserDefaults().stringForKey("username") {
                            print("Username: \(loadedUsername)")
                            if let retrievedPassword = self.MyKeychainWrapper.myObjectForKey(kSecValueData){
                                print(retrievedPassword)
                                
                                let alertBox = UIAlertController(title: "", message: "Logging in ...", preferredStyle: UIAlertControllerStyle.Alert)
                                self.presentViewController(alertBox, animated: true, completion: nil)
                                let delegate = ApiRequestDelegate()
                                delegate.checkLogin(loadedUsername, password: retrievedPassword as! String) {
                                    (successful: Bool, req_status: Int, email: String, name: String) in
                                    
                                    if successful{
                                        self.warningLabel.text = ""
                                        let user = User(email: email, name: name, password: retrievedPassword as! String)!
                                        self.currentUser = user
                                        alertBox.dismissViewControllerAnimated(true, completion: {
                                            self.performSegueWithIdentifier("login", sender: self)
                                        })
                                    } else {
                                        if req_status == 1 {
                                            alertBox.message = "Server not reachable. Please make sure you're online."
                                        }
                                        if req_status == 2 {
                                            alertBox.message = "Incorrect email or password."
                                        }
                                        if req_status == 3 {
                                            alertBox.message = "Error communicating with the server."
                                        }
                                        if req_status > 3 || req_status < 0{
                                            alertBox.message = String(format:"An unknown error occured: %@.", req_status)
                                        }
                                        alertBox.addAction(UIAlertAction(title: "Ok", style: .Default, handler: { (action: UIAlertAction!) in
                                        }))

                                    }
                                }
                            }
                            
                        }
                    }
                    
                    if error != nil {
                        var message : NSString
                        var showAlert: Bool
                        
                        switch(error!.code) {
                        case LAError.AuthenticationFailed.rawValue:
                            message = "There was a problem verifying your identity."
                            showAlert = true
                            break;
                        case LAError.UserCancel.rawValue:
                            message = "You pressed cancel."
                            showAlert = true
                            break;
                        case LAError.UserFallback.rawValue:
                            message = "You pressed password."
                            showAlert = true
                            break;
                        default:
                            showAlert = true
                            message = "Touch ID may not be configured."
                            break;
                        }
                        
                        let alertView = UIAlertController(title: "Error", message: message as String, preferredStyle: .Alert)
                        let okAction = UIAlertAction(title: "Darn!", style: .Default, handler: nil)
                        alertView.addAction(okAction)
                        if showAlert{
                            self.presentViewController(alertView, animated: true, completion: nil)
                        }
                    }
                })
            })
        } else{
            let alertView = UIAlertController(title: "Error", message: "Touch ID not available" as String, preferredStyle: .Alert)
            let okAction = UIAlertAction(title: "Darn!", style: .Default, handler: nil)
            alertView.addAction(okAction)
            self.presentViewController(alertView, animated: true, completion: nil)
        }
        
    }
    
    @IBAction func login(sender: UIButton) {
        
        // Print error messages if one of the text fields is not filled.
        
        guard let text = usernameTextField.text where !text.isEmpty else{
            warningLabel.text = "Please enter an email and password."
            return
        }
        guard let password = passwordTextField.text where !password.isEmpty else{
            warningLabel.text = "Please enter an email and password."
            return
        }
        
        // Hide keyboard when login button is pressed.
        
        usernameTextField.resignFirstResponder()
        passwordTextField.resignFirstResponder()
        
        /*
        let authString = "Basic \(base64EncodedCredential)"
        config.HTTPAdditionalHeaders = ["Authorization" : authString]
        let session = NSURLSession(configuration: config)
        var running = false
        var dataString: NSString?
        let task = session.dataTaskWithURL(url!) {
            (let data, let response, let error) in
            if let _ = response as? NSHTTPURLResponse {
                dataString = NSString(data: data!, encoding: NSUTF8StringEncoding)
                print(dataString)
            }
            running = false
        }
        running = true
        task.resume()
        
        while running{
            sleep(1)
        }
        print(dataString)
*/
        let alertBox = UIAlertController(title: "", message: "Logging in ...", preferredStyle: UIAlertControllerStyle.Alert)
        presentViewController(alertBox, animated: true, completion: nil)
        let delegate = ApiRequestDelegate()
        delegate.checkLogin(usernameTextField.text!, password: passwordTextField.text!) {
            (successful:Bool, req_status: Int, email:String, name: String) in
            // always save username
            NSUserDefaults.standardUserDefaults().setValue(self.usernameTextField.text, forKey: "username")
            print("username saved to NSUserDefaults")
            
            if successful {
                self.warningLabel.text = ""
                let user = User(email: email, name: name, password: password)!
                self.currentUser = user
                
                // If this is the first time user is logging in
                if sender.tag == self.createLoginButtonTag {
                    print("first login")
                    
                    // Check whether a username has been saved to the Keychain already
                    //let hasLoginKey = NSUserDefaults.standardUserDefaults().boolForKey("hasLoginKey")
                    //if hasLoginKey == false{
                    //}
                    
                    // Save password to Keychain (for info on using keychain wrapper read KeychainWrapper.m)
                    self.MyKeychainWrapper.mySetObject(self.passwordTextField.text, forKey: kSecValueData)
                    self.MyKeychainWrapper.writeToKeychain()
                    NSUserDefaults.standardUserDefaults().setBool(true, forKey: "hasLoginKey")
                    NSUserDefaults.standardUserDefaults().synchronize()
                    self.loginButton.tag = self.loginButtonTag
                    
                }else if sender.tag == self.loginButtonTag{
                    print("has logged in before")
                    
                    // Make sure stored password matches password used and update if password has changed
                    let retrievedPassword = self.MyKeychainWrapper.myObjectForKey(kSecValueData)
                    if retrievedPassword as? String != self.passwordTextField.text {
                        self.MyKeychainWrapper.mySetObject(self.passwordTextField.text, forKey: kSecValueData)
                        self.MyKeychainWrapper.writeToKeychain()
                    }
                }
                
                alertBox.dismissViewControllerAnimated(true, completion: {
                    self.performSegueWithIdentifier("login", sender: self)
                })
            } else {
                if req_status == 1 {
                    alertBox.message = "Server not reachable. Please make sure you're online."
                }
                if req_status == 2 {
                    alertBox.message = "Incorrect email or password."
                }
                if req_status == 3 {
                    alertBox.message = "Error communicating with the server."
                }
                if req_status > 3 || req_status < 0{
                    alertBox.message = String(format:"An unknown error occured: %@.", req_status)
                }
                alertBox.addAction(UIAlertAction(title: "Ok", style: .Default, handler: { (action: UIAlertAction!) in
                }))
            }
        }
        //checkLogin(usernameTextField.text!, password: passwordTextField.text!)
        
        
        //Load data and check if password and username are correct.
        /* Abbey's code; commented out on 8/2/2016 [yong.lu@nih]
        
        let filePath = NSBundle.mainBundle().pathForResource("sampleevents", ofType: "json")
        let data = try! NSData(contentsOfFile: filePath!,
            options: NSDataReadingOptions.DataReadingUncached)
        
        do{
            let json = try NSJSONSerialization.JSONObjectWithData(data, options: .AllowFragments)
            var login = 0
            
            if let userArray = json["users"] as? [[String: AnyObject]] {
                for user in userArray {
                    if let email = user["email"] as? String, password = user["password"] as? String, name = user["username"] as? String {
                        
                        if email == usernameTextField.text && passwordTextField.text == password{
                            
                            // If the password and email are correct, store the email for use in loading the events page and perform the login segue.
                            
                            let user = User(email: email, name: name)!
                            currentUser = user
                            performSegueWithIdentifier("login", sender: self)
                            login = 1 // User has logged in successfully.
                        }
                    }else{
                        print("error accessing user information")
                    }
                }
                if login == 0{
                    warningLabel.text = "Incorrect email or password."
                } else {
                    // If the user is logging in, dismiss the warning label.  (This is 1. for aesthetics during login segue and 2. so that the warning doesn't remain when the user logs out.)
                    warningLabel.text = ""
                }
            }
        } catch {
            print("error serializing JSON: \(error)")
        }
*/

    }
    /*
    func authenticateUser(){
        // Touch ID code taken from https://www.appcoda.com/touch-id-api-ios8/
        
        // Get the local authentication context.
        let context = LAContext()
        
        // Declare an NSError variable.
        var error: NSError?
        
        // Set the reason string that will appear on the authentication alert.
        var reasonString = "Login using Touch ID?"
        
        // Check if the device can evaluate the policy.
        if context.canEvaluatePolicy(LAPolicy.DeviceOwnerAuthenticationWithBiometrics, error: &error){
            [context .evaluatePolicy(LAPolicy.DeviceOwnerAuthenticationWithBiometrics, localizedReason: reasonString, reply: { (success: Bool, evalPolicyError: NSError?) -> Void in
                
                if success {
                    
                }
                else{
                    // If authentication failed then show a message to the console with a short description.
                    // In case that the error is a user fallback, then show the password alert view.
                    print(evalPolicyError?.localizedDescription)
                    
                    switch evalPolicyError!.code {
                        
                    case LAError.SystemCancel.rawValue:
                        print("Authentication was cancelled by the system.")
                        
                    case LAError.UserCancel.rawValue:
                        print("Authentication was cancelled by the user.")
                        
                    case LAError.UserFallback.rawValue:
                        print("User selected to enter custom password.")
                        /*NSOperationQueue.mainQueue().addOperationWithBlock({ () -> Void in
                            self.showPasswordAlert()
                        })*/
                        
                    default:
                        print("Authentication failed.")
                        /*NSOperationQueue.mainQueue().addOperationWithBlock({ () -> Void in
                            self.showPasswordAlert()
                        })*/
                    }
                }
            })]
        }
        else{
            // If the security policy cannot be evaluated then show a short messaged depending on the error.
            switch error!.code{
                
            case LAError.TouchIDNotEnrolled.rawValue:
                print("TouchID is not enrolled.")
                
            case LAError.PasscodeNotSet.rawValue:
                print("A passcode has not been set.")
                
            default:
                // The LAError.TouchIDNotAvailable case.
                print("TouchID not available.")
            }
            
            // Optionally the error description can be displayed on the console.
            print(error?.localizedDescription)
            
            // Show the custom alert view to allow users to enter the password.
            //self.showPasswordAlert()
        }
    }*/
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "login"{
            /*
            // The destination of the segue is the EventTableViewController class, which is buried in a tabBarContoller and navigationController.
            let tabBarController = segue.destinationViewController as! UITabBarController
            let navigationController = tabBarController.viewControllers![0] as! UINavigationController
            let eventScheduleViewController = navigationController.topViewController as! EventTableViewController
            
            // The currentUser should be the user whose schedule in loaded on the event tableview.
            eventScheduleViewController.user = currentUser
*/
            
        }
    }
    
    @IBAction func unwindToThisViewController(segue: UIStoryboardSegue) {
    }
    
}
