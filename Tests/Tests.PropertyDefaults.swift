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

struct PersonMock: Codable {
    let name: String
    let age: Int
    let children: [PersonMock]
}

struct CustomValueType: Codable{
    var key:String = "value"
}

extension Defaults: PropertyDefaults {
    
    var autoStringProperty: String? {
        set{ set(newValue) } get{ return get() }
    }
    var autoDateProperty: Date? {
        set{ set(newValue) } get{ return get() }
    }
    
    // default value with 'or'
    var autoStringPropertyWithDefaultValue: String? {
        set{ set(newValue) } get{ return get() }
    }
    // non-optional - must define lazily default value with the keyword 'or'
    var autoCustomNonOptionalProperty: CustomValueType {
        set{ set(newValue) } get{ return get(or: CustomValueType()) }
    }
    // optional - there are 4 ways with/without default value
    var autoCustomOptionalProperty: CustomValueType? {
        set{ set(newValue) } get{ return get() }
    }
    var autoCustomOptionalPropertySetterDefaultValue: CustomValueType? {
        set{ set(newValue, or: CustomValueType()) } get{ return get() }
    }
    var autoCustomOptionalPropertyGetterDefaultValue: CustomValueType? {
        set{ set(newValue) } get{ return get() }
    }
    var autoCustomOptionalPropertySetterGetterDefaultValue: CustomValueType? {
        set{ set(newValue, or: CustomValueType()) } get{ return get() }
    }
}

class PropertyDefaultsTests: XCTestCase {
    
    var defaults: Defaults!
    
    override func setUp() {
        super.setUp()
        self.defaults = Defaults()
        continueAfterFailure = false
    }

    override func tearDown() {
        super.tearDown()
        self.defaults = nil
    }

    func testProperty(){
        
        let localDefaults = Defaults(suiteName: "local")
        localDefaults.autoStringProperty = "1"
        
        //basic test
        defaults.autoStringProperty = "string value"
        XCTAssertTrue(Defaults.shared.autoStringProperty != localDefaults.autoStringProperty)
        
        XCTAssertTrue(defaults.has(Property<String>("autoStringProperty")))
        XCTAssertEqual(Defaults.shared.autoStringProperty,"string value")

        //test default value
        Defaults.shared.autoStringPropertyWithDefaultValue = "new string value"
        XCTAssertTrue(Defaults.shared.autoStringPropertyWithDefaultValue != nil)
        XCTAssertTrue(defaults.has(Property<String>("autoStringPropertyWithDefaultValue")))
        XCTAssertTrue(defaults.autoStringPropertyWithDefaultValue == "new string value")

        //test custom value type with optional
        XCTAssertTrue(defaults.autoCustomOptionalProperty == nil)
        XCTAssertFalse(defaults.has(Property<CustomValueType>("autoCustomOptionalProperty")))

        //test for a case without default value
        defaults.autoCustomOptionalProperty = CustomValueType()
        XCTAssertTrue(defaults.autoCustomOptionalProperty != nil)
        defaults.autoCustomOptionalProperty = nil
        XCTAssertTrue(defaults.autoCustomOptionalProperty == nil)

        //test for a case with default setter's value
        defaults.autoCustomOptionalPropertySetterDefaultValue = nil
        XCTAssertTrue(defaults.autoCustomOptionalPropertySetterDefaultValue != nil)

        //test custom value type with non optional
        XCTAssertTrue(defaults.autoCustomNonOptionalProperty.key == "value")
        XCTAssertTrue(defaults.has(Property<CustomValueType>("autoCustomNonOptionalProperty")))
    }
    
    // Internal Tests

    let integerKey = Property<Int>("integerKey")
    let arrayOfIntegersKey = Property<[Int]>("arrayOfIntegersKey")
    let floatKey = Property<Float>("floatKey")
    let doubleKey = Property<Double>("doubleKey")
    let stringKey = Property<String>("stringKey")
    let boolKey = Property<Bool>("boolKey")
    let dateKey = Property<Date>("dateKey")
    let personMockKey = Property<PersonMock>("personMockKey")
    
    func testInternalInteger() {
        
        // Given
        let value = 123
        
        // When
        defaults.set(value, for: integerKey)
        
        // Then
        let hasKey = defaults.has(integerKey)
        XCTAssertTrue(hasKey)
        
        let savedValue = defaults.get(for: integerKey)
        XCTAssertEqual(savedValue, value)
        
    }
    
    func testInternalFloat() {
        
        // Given
        let value: Float = 123.1
        
        // When
        defaults.set(value, for: floatKey)
        
        // Then
        let hasKey = defaults.has(floatKey)
        XCTAssertTrue(hasKey)
        
        let savedValue = defaults.get(for: floatKey)
        XCTAssertEqual(savedValue, value)
        
    }
    
    func testInternalDouble() {
        
        // Given
        let value: Double = 123.1
        
        // When
        defaults.set(value, for: doubleKey)
        
        // Then
        let hasKey = defaults.has(doubleKey)
        XCTAssertTrue(hasKey)
        
        let savedValue = defaults.get(for: doubleKey)
        XCTAssertEqual(savedValue, value)
        
    }
    
    func testInternalString() {
        
        // Given
        let value = "a string"
        
        // When
        defaults.set(value, for: stringKey)
        
        // Then
        let hasKey = defaults.has(stringKey)
        XCTAssertTrue(hasKey)
        
        let savedValue = defaults.get(for: stringKey)
        XCTAssertEqual(savedValue, value)
        
    }
    
    func testInternalBool() {
        
        // Given
        let value = true
        
        // When
        defaults.set(value, for: boolKey)
        
        // Then
        let hasKey = defaults.has(boolKey)
        XCTAssertTrue(hasKey)
        
        let savedValue = defaults.get(for: boolKey)
        XCTAssertEqual(savedValue, value)
        
    }
    
    func testInternalDate() {
        
        // Given
        let value = Date()
        
        // When
        defaults.set(value, for: dateKey)
        
        // Then
        let hasKey = defaults.has(dateKey)
        XCTAssertTrue(hasKey)
        
        let savedValue = defaults.get(for: dateKey)
        XCTAssertEqual(savedValue, value)
        
    }
    
    func testInternalSet() {
        
        // Given
        let values = [1,2,3,4]
        
        // When
        defaults.set(values, for: arrayOfIntegersKey)
        
        // Then
        let hasKey = defaults.has(arrayOfIntegersKey)
        XCTAssertTrue(hasKey)
        
        let savedValues = defaults.get(for: arrayOfIntegersKey)
        XCTAssertNotNil(savedValues)
        savedValues?.forEach({ (value) in
            XCTAssertTrue(savedValues?.contains(value) ?? false)
        })
        //reset for next test (e.g. testClear())
        defaults.clear(arrayOfIntegersKey)
    }
    
    func testInternalClear() {
        
        // Given
        let values = [1,2,3,4]
        
        // When
        defaults.set(values, for: arrayOfIntegersKey)
        defaults.clear(arrayOfIntegersKey)
        
        // Then
        let hasKey = defaults.has(arrayOfIntegersKey)
        XCTAssertFalse(hasKey)
        
        let savedValues = defaults.get(for: arrayOfIntegersKey)
        XCTAssertNil(savedValues)
        
    }
    
    func testInternalSetObject() {
     
        // Given
        let child = PersonMock(name: "Anne Greenwell", age: 30, children: [])
        let person = PersonMock(name: "Bonnie Greenwell", age: 80, children: [child])
        
        // When
        defaults.set(person, for: personMockKey)
        
        // Then
        let hasKey = defaults.has(personMockKey)
        XCTAssertTrue(hasKey)
        
        let savedPerson = defaults.get(for: personMockKey)
        XCTAssertEqual(savedPerson?.name, "Bonnie Greenwell")
        XCTAssertEqual(savedPerson?.age, 80)
        XCTAssertEqual(savedPerson?.children.first?.name, "Anne Greenwell")
        XCTAssertEqual(savedPerson?.children.first?.age, 30)
    }
}
