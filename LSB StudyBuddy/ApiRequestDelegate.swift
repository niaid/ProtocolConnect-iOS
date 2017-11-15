//
//  ApiRequestDelegate.swift
//  StudyBuddy
//
//  Created by Yong Lu on 8/2/16.
//  Copyright © 2016 Abbey Thorpe. All rights reserved.
//  Copyright © 2016,2017 Yong Lu. All rights reserved.
//

import Foundation;

class ApiRequestDelegate: NSObject, NSURLSessionDelegate {

    static let sharedInstance = ApiRequestDelegate()
    //static let baseUrl = "https://cshannon.niaid.nih.gov/"
    //static let baseUrl = "https://127.0.0.1:4433/"
    static let baseUrl = "https://np-p.net/"
    static var session : NSURLSession?
            //let userPasswordString:NSString = NSString(format: "%@:%@", email, password)
    
    func setupSession() -> NSURLSession {
        if ApiRequestDelegate.session == nil {
            let globalCredential:NSString = "a:b"
            let userPasswordData = globalCredential.dataUsingEncoding(NSUTF8StringEncoding)!
            let base64EncodedCredential = userPasswordData.base64EncodedStringWithOptions([])
            let authString = "Basic \(base64EncodedCredential)"
            let config = NSURLSessionConfiguration.defaultSessionConfiguration()
        
            config.HTTPAdditionalHeaders = ["Authorization" : authString]
            ApiRequestDelegate.session = NSURLSession(configuration: config, delegate:self, delegateQueue:NSOperationQueue.mainQueue())
        }
        return ApiRequestDelegate.session!
    }
    

    // yong.lu
    // Goal: try authenticate the user
    // How: two levels of authentication
    //   1. HTTP auth using a 'global' credential
    //   2. user email + password.  the server will return one of the following
    //       1.1 {} if the user is not found, or
    //       1.2 [...] : a list of studyflows the user participated in
    // for completion handler, see https://thatthinginswift.com/completion-handlers/
    func checkLogin(email: String, password: String, completion:(successful: Bool, req_status: Int, email: String, name: String)->Void) -> Void {
        let session = self.setupSession()
        let urlString = NSString(format: "%@/api/v1/subjects/%@:%@", ApiRequestDelegate.baseUrl, email, password)
        let escapedUrlString = urlString.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())
        //let urlString = "https://cshannon.niaid.nih.gov/api/v1/subjects"
        let url = NSURL(string: escapedUrlString!) // larry@email.com:b88dd585fb46068ea12a5889dcd45805")
        let request = NSMutableURLRequest(URL: url!)
        request.HTTPMethod = "GET"
        //request.setValue("Basic \(base64EncodedCredential)", forHTTPHeaderField: "Authorization")
        //print("Basic \(base64EncodedCredential)")
        //var running = false
        var dataString: NSString?
        //let task = NSURLSession.sharedSession().dataTaskWithRequest(request) {
        //let task = session.dataTaskWithURL(url!) {
        let task = session.dataTaskWithRequest(request, completionHandler: {
            data, response, error -> Void in
            //print("info")
            var successful: Bool = false
            var req_status: Int = -1
            var name = ""
            if error != nil {
                print("error=\(error)")
                req_status = 1  // error in request
            } else {
                //let responseString = NSString(data: data!, encoding:NSUTF8StringEncoding)
                //print("responseString = \(responseString)")
                if let _ = response as? NSHTTPURLResponse{
                    dataString = NSString(data: data!, encoding: NSUTF8StringEncoding)
                    //print(dataString)
                    do {
                        let data = dataString?.dataUsingEncoding(NSUTF8StringEncoding)
                        let json = try NSJSONSerialization.JSONObjectWithData(data!, options: .AllowFragments)
                        print(json)
                        let json_status = json["status"] as? String
                        print(json_status)
                        /* TODO: verify user info */
                        if (json_status!.compare("success") == NSComparisonResult.OrderedSame) {
                            successful = true
                            req_status = 0
                            let firstname = json["data"]!![0]["firstname"] as? String
                            let lastname  = json["data"]!![0]["lastname"]  as? String
                            name = String(format:"%@ %@", firstname!, lastname!)
                        } else {
                            req_status = 2  // user not found, or failed to authenticate
                        }
                    } catch{
                        req_status = 3
                        print("Error serializing json")
                    }
                    //print(json)
                }
            }
            print(name)
            completion(successful: successful, req_status: req_status, email: email, name: name)
        })

        task.resume()
    }
    
    func updatePassword(email: String, old_pass: String, new_pass: String, completion:(success: Bool)->Void) -> Void {
        let apiString = String(format: "updatePassword/%@/%@/%@", email, old_pass, new_pass)
        restGet(apiString) {
            success,jsonDict, jsonString -> Void in
            if(success) {
                print("password change successful")
            } else {
                print("password change failed")
            }
            completion(success: success)
        }
    }
    
    func getMessagesForUserEmail(email: String, since: Double, completion:(success: Bool, [Message]) -> Void) -> Void {
        let apiString = String(format: "subjects/%@/messages/get/%.0f", email, since)
        restGet(apiString) {
            success, jsonDict, jsonString -> Void in
            if(!success) {
                print("problem receiving messages")
                completion(success: false, [])
            } else {
                print("messages received successfully")
                // convert jsonDict to [Message]
                var messages : [Message] = []
                if let msgArray = jsonDict!["data"] as? [[String: AnyObject]] {
                    for msg in msgArray {
                        if let newMessage = Message(is_to_patient: msg["is_to_patient"] as! Int, patient_email: msg["email"] as! String, epoch: msg["epoch"] as! Double, content: msg["content"] as! String) {
                            messages += [newMessage]
                        }
                    }
                }
                // sort messages by time
                messages = messages.sort({ $0.epoch < $1.epoch} )
                completion(success: success, messages)
            }
        }
    }
    // email is used as user ID
    func sendMessageToUser(email: String, content: String, completion:(success: Bool) -> Void) -> Void {
        let apiString = String(format: "subjects/%@/messages/send", email)
        var params : [ String:String] = [:]
        params["is_to_patient"] = "0"
        params["content"] = content
        params["epoch"] = String(format: "%.0f", NSDate().timeIntervalSince1970)
        post(params, apiPath: apiString) {
            (success, response, error, jsonDict, jsonString) in
            if(success) {
                print("messages received successfully")
            } else {
                print("problem receiving messages")
            }
            // convert jsonDict to [Message]
            completion(success: success)
        }
    }
    
    func getEventsBasedOnUserEmail(email: String, completion:(successful: Bool, req_status: Int, [Event]) -> Void)->Void {
        let session = self.setupSession()
        let urlString = String(format: "%@/api/v1/events/subject_email:%@", ApiRequestDelegate.baseUrl, email)
        let url = NSURL(string: urlString) // larry@email.com:b88dd585fb46068ea12a5889dcd45805")
        let request = NSMutableURLRequest(URL: url!)
        request.HTTPMethod = "GET"
        //request.setValue("Basic \(base64EncodedCredential)", forHTTPHeaderField: "Authorization")
        //print("Basic \(base64EncodedCredential)")
        //var running = false
        //let task = NSURLSession.sharedSession().dataTaskWithRequest(request) {
        //let task = session.dataTaskWithURL(url!) {
        let task = session.dataTaskWithRequest(request, completionHandler: {
            data, response, error -> Void in
            var successful: Bool = false
            var req_status: Int = -1
            var events : [Event] = []
            if error != nil {
                print("error=\(error)")
            } else {
                let dataString = NSString(data: data!, encoding: NSUTF8StringEncoding)
                print(dataString)
                do{
                    let json = try NSJSONSerialization.JSONObjectWithData(data!, options: .AllowFragments)
                    let json_status = json["status"] as? String
                    if (json_status!.compare("success") == NSComparisonResult.OrderedSame) {
                      if let eventArray = json["data"] as? [[String: AnyObject]] {
                        for event in eventArray {
                            if let _id = event["_id"] as? String,
                               time = event["time"] as? String,
                               studyflow_id = event["studyflow_id"] as? String,
                               name = event["name"] as? String,
                               rel_date = event["rel_date"] as? Int
                            {
                                var location = ""
                                if let loc = event["location"] as? String {
                                    location = loc
                                }
                                var question = ""
                                if let q = event["question"] as? String {
                                    question = q
                                }
                                //let time_with_tz = time + " -0400"
                                let formatter = NSDateFormatter()
                                formatter.locale = NSLocale(localeIdentifier: "en_US_POSIX")
                                // formatter.timeZone = NSTimeZone(forSecondsFromGMT: 0)
                                formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
                                let notes = event["notes"] as? String
                                let flag = event["flag"] as? String
                                var response : String?
                                if let response_string = event["response"] as? String {
                                    let array = response_string.characters.split{$0 == ":"}.map(String.init)
                                    if array.count > 0 {
                                        response = array[0]
                                    }
                                }
                                var reason : String?
                                if let reason_string = event["reason"] as? String {
                                    let array = reason_string.characters.split{$0 == ":"}.map(String.init)
                                    if array.count > 0 {
                                        reason = array[0]
                                    }
                                }
                                let additional_response = event["additional_response"] as? String
                                
                                let eventDate = formatter.dateFromString(time)
                                var est_arrival : NSDate?
                                if let est_arrival_string = event["est_arrival"] as? String {
                                    est_arrival = formatter.dateFromString(est_arrival_string)
                                }
                                let newEvent = Event(_id: _id, studyflow_id: studyflow_id, name: name, location: location, time: eventDate!, rel_date: rel_date, notes: notes, question: question, flag: flag, response: response, reason: reason, est_arrival: est_arrival, additional_response: additional_response)
                                if let ev = newEvent {
                                  events += [ev]
                                } else {
                                    print("Missing info in events")
                                }
                            }
                        }
                        req_status = 0
                        successful = true
                      }
                    } else {
                        req_status = 2  // server returns status='fail'
                    }
                } catch {
                    req_status = 3
                    print("error serializing JSON: \(error)")
                }
            }
            completion(successful: successful, req_status: req_status, events)
        })
        task.resume()
    }
    
    func createStringFromDictionary(dict: [String:String]) -> String {
        var params = String()
        for (key, value) in dict {
            params += "&" + key + "=" + value
        }
        return params
    }

    func post(params : [String:String], apiPath : String, postCompleted : (success:Bool, response:NSURLResponse!, error:NSError!, JsonNSDictionary: NSDictionary,JsonString:String) -> ()) {
        let url = String(format:"%@/api/v1/%@", ApiRequestDelegate.baseUrl, apiPath)
        let request = NSMutableURLRequest(URL: NSURL(string: url)!)
        let session = self.setupSession()
        request.HTTPMethod = "POST"
        let params2 = createStringFromDictionary(params)
        let requestBodyData = (params2 as NSString).dataUsingEncoding(NSUTF8StringEncoding)
        let paramsLength = String(requestBodyData!.length)
        
        request.HTTPBody = requestBodyData
        request.addValue(paramsLength, forHTTPHeaderField: "Content-Length")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        
        let task = session.dataTaskWithRequest(request, completionHandler: {data, response, error -> Void in
            print("Response: \(response)")
            let strData = NSString(data: data!, encoding: NSUTF8StringEncoding)
            print("Body: \(strData)")
            //let err: NSError?
            var json : NSDictionary?
            do {
                try json = NSJSONSerialization.JSONObjectWithData(data!, options: .MutableLeaves) as? NSDictionary
                
            }
            catch {
                
            }
            var success = false
            if((json?["status"])! as! String == "success") {
                success = true
            }
            postCompleted(success: success, response:response, error:error, JsonNSDictionary: json!, JsonString:strData! as String)
        })
        
        task.resume()
    }
    
    func restGet(apiPath:String, completion: (success:Bool, JsonNSDictionary: NSDictionary?,JsonString:String?) -> ())
    {
        let path = String(format:"%@/api/v1/%@", ApiRequestDelegate.baseUrl, apiPath)
        let request = NSMutableURLRequest(URL: NSURL(string: path)!)
        let session = self.setupSession()
        let task = session.dataTaskWithRequest(request, completionHandler: {data, response, error -> Void in
            //let json:JSON = JSON(data: data!)
            //if let c = json["content"].string {
            //    print(c)
            //}
            if((error) != nil) {
              completion(success:false, JsonNSDictionary: nil, JsonString: "")
            } else {
              print("Response: \(response)")
              let strData = NSString(data: data!, encoding: NSUTF8StringEncoding)
              print("Body: \(strData)")
              //let err: NSError?
              var json : NSDictionary?
              do {
                  try json = NSJSONSerialization.JSONObjectWithData(data!, options: .MutableLeaves) as? NSDictionary
                  
              }
              catch {
                  
              }
              let status = json?["status"] as! String?
              var success:Bool = false
              if (status! == "success") {
                  success = true
              }
              completion(success:success, JsonNSDictionary: json!,JsonString:strData! as String)
            }
        })
        task.resume()
    }
    
    func URLSession(session: NSURLSession, task: NSURLSessionTask, didReceiveChallenge challenge: NSURLAuthenticationChallenge, completionHandler: (NSURLSessionAuthChallengeDisposition, NSURLCredential?) -> Void) {
        print("here")
        completionHandler(NSURLSessionAuthChallengeDisposition.UseCredential, NSURLCredential(forTrust: challenge.protectionSpace.serverTrust!))
    }
}
