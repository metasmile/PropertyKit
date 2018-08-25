//
//  DefaultsTests.swift
//
//  Copyright (c) 2018 Taeho Lee (github.com/metasmile)
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//  SOFTWARE.
//

import XCTest
@testable import PropertyKit

class SampleWatcheeClass:NSObject, PropertyWatchable{
    @objc dynamic
    var testingProperty:String?
}

class PropertyWatchableTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        continueAfterFailure = false
    }
    override func tearDown() {
        super.tearDown()
    }
    
    func testSimpleCase(){

        let watcheeObject = SampleWatcheeClass()
        let newValue:String? = "newValue"
        watcheeObject.watch(\.testingProperty) {
            XCTAssertTrue(watcheeObject.testingProperty==newValue)
        }
        watcheeObject.testingProperty = newValue
    }
    
    func testSetNil(){
        //test nil
        let watcheeObject = SampleWatcheeClass()
        watcheeObject.watch(\.testingProperty) {
            XCTAssertTrue(watcheeObject.testingProperty==nil)
        }
        watcheeObject.testingProperty = nil
    }
    
    func testUnwatch(){
        
        let watcheeObject = SampleWatcheeClass()
        var watchedValue:String?
        watcheeObject.watch(\.testingProperty) {
            watchedValue = watcheeObject.testingProperty
        }
        watcheeObject.unwatch(\.testingProperty)
        watcheeObject.testingProperty = "new value after unwatched"
        
        let e = self.expectation(description: "unwatched")
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now()+1) {
            if watchedValue==nil{
                e.fulfill()
            }
        }
        
        waitForExpectations(timeout: 2) { (e) in
            XCTAssertTrue(watchedValue==nil)
        }
    } 
}
