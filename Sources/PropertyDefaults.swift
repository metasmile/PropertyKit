//
//  PropertyDefaults.swift
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

import Foundation

public protocol PropertyDefaults {}
public extension PropertyDefaults where Self:Defaults{
    
    /// Sets a newValue automatically associated with the current function(key) name.
    /// If newValue is nil, the key in UserDefaults will be deleted.
    ///
    /// - Parameters:
    ///   - newValue: The value to set.
    ///   - or: default value. Non-Optional.
    ///   - key: private key name. it will set automatically via #function macro.
    func set<ValueType:Codable>(_ newValue:ValueType?=nil, or:ValueType, key:String=#function){
        set(newValue ?? or, key: key)
    }
    
    func set<ValueType:Codable>(_ newValue:ValueType?=nil, key:String=#function){
        if let newValue = newValue{
            set(newValue, for: Property<ValueType>(key))
        }else{
            clear(Property<ValueType>(key))
        }
    }
    
    /// Returns the value or default value associated with the specified key.
    ///
    /// - Parameter
    ///   - or: default value.
    ///   - key: private key name. it will set automatically via #function macro.
    /// - Returns a value of `ValueType` if matched value by key and its type was found. Otherwise, nil.
    func get<ValueType:Codable>(or:ValueType?=nil, key:String=#function) -> ValueType?{
        // value is available
        if let gotValue = get(for: Property<ValueType>(key)){
            return gotValue
        }
        // persists default value
        if let gotOr = or{
            set(nil, or:gotOr, key: key) // set to guarantee
            return gotOr
        }
        // no value + no pre-defined default value
        return nil
    }
    
    func get<ValueType:Codable>(or:ValueType, key:String=#function) -> ValueType{
        if let _or = get(or:Optional<ValueType>(or), key: key){
            return _or
        }
        assert(false, "the default value \(String(describing:or)) of 'or' was not persisted.")
        return or
    }
}


final class Property<ValueType: Codable> {
    fileprivate let _key: String
    init(_ key: String) {
        _key = key
    }
}

public final class Defaults {
    private var userDefaults: UserDefaults
    
    public static let shared = Defaults()
    
    public init(suiteName:String?=nil) {
        self.userDefaults = UserDefaults(suiteName: suiteName) ?? UserDefaults.standard
    }
    
    internal func clear<ValueType>(_ key: Property<ValueType>) {
        userDefaults.set(nil, forKey: key._key)
        userDefaults.synchronize()
    }
    
    internal func has<ValueType>(_ key: Property<ValueType>) -> Bool {
        return userDefaults.value(forKey: key._key) != nil
    }
    
    internal func get<ValueType>(for key: Property<ValueType>) -> ValueType? {
        if isSwiftCodableType(ValueType.self) || isFoundationCodableType(ValueType.self) {
            return userDefaults.value(forKey: key._key) as? ValueType
        }
        
        guard let data = userDefaults.data(forKey: key._key) else {
            return nil
        }
        
        do {
            let decoder = JSONDecoder()
            let decoded = try decoder.decode(ValueType.self, from: data)
            return decoded
        } catch {
            #if DEBUG
            print(error)
            #endif
        }
        
        return nil
        
    }
    
    internal func set<ValueType>(_ value: ValueType, for key: Property<ValueType>) {
        if isSwiftCodableType(ValueType.self) || isFoundationCodableType(ValueType.self) {
            userDefaults.set(value, forKey: key._key)
            return
        }
        
        do {
            let encoder = JSONEncoder()
            let encoded = try encoder.encode(value)
            userDefaults.set(encoded, forKey: key._key)
            userDefaults.synchronize()
        } catch {
            #if DEBUG
            print(error)
            #endif
        }
    }
    
    private func isSwiftCodableType<ValueType>(_ type: ValueType.Type) -> Bool {
        switch type {
        case is String.Type, is Bool.Type, is Int.Type, is Float.Type, is Double.Type:
            return true
        default:
            return false
        }
    }
    
    /// Foundation framework.
    private func isFoundationCodableType<ValueType>(_ type: ValueType.Type) -> Bool {
        switch type {
        case is Date.Type:
            return true
        default:
            return false
        }
    }
    
}


