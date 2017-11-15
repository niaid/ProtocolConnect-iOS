//
//  StudyBuddyTests.swift
//  StudyBuddyTests
//
//  Created by Abbey Thorpe on 6/9/16.
//  Copyright © 2016 Abbey Thorpe. All rights reserved.
//  Copyright © 2016,2017 Yong Lu. All rights reserved.
//

import XCTest
@testable import LSB_StudyBuddy

class LSB_StudyBuddyTests: XCTestCase {
    
    // MARK: StudyBuddyTests
    
    // Tests to confirm that the event initializer returns when no name is given.
    
    func testEventInitialization(){
        
        // Success case.
        let potentialItem = Event(name: "NIH Registration", location: "", time: "May 2, 2016, 6:00 PM", notes: "")
        XCTAssertNotNil(potentialItem)
        
        // Fail cases.
        let noName = Event(name: "", location: "", time: "May 2, 2016, 6:00 PM", notes: "")
        XCTAssertNil(noName, "Empty name is invalid")
        
        let noTime = Event(name: "NIH Registration", location: "", time: "", notes: "")
        XCTAssertNil(noTime, "Empty time is invalid")
        
    }
    
}
