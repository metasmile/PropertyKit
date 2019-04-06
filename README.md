<img width="447" alt="PropertyKit" src="https://github.com/metasmile/PropertyKit/raw/master/title.png?raw=true">

[![swift](https://img.shields.io/badge/Awesome-iOS-red.svg)](https://github.com/vsouza/awesome-ios#database)
[![cocoapods compatible](https://img.shields.io/badge/cocoapods-compatible-brightgreen.svg)](https://cocoapods.org/pods/PropertyKit)
[![carthage compatible](https://img.shields.io/badge/carthage-compatible-brightgreen.svg)](https://github.com/Carthage/Carthage)
[![language](https://img.shields.io/badge/spm-compatible-brightgreen.svg)](https://swift.org)
[![platform](https://img.shields.io/badge/platform-iOS%20%7C%20macOS%20%7C%20tvOS-lightgrey.svg)](https://developer.apple.com/develop/)
[![swift](https://img.shields.io/badge/swift-4.2,5.x-orange.svg)](https://github.com/metasmile/PropertyKit/releases)

Light-weight, strict protocol-first styled PropertyKit helps you to easily and safely handle guaranteed values, keys or types on various situations of the large-scale Swift project on iOS, macOS and tvOS.

## Installation

[Detail Guide](https://github.com/metasmile/PropertyKit/blob/master/INSTALL.md)


CocoaPods
```ruby
pod 'PropertyKit'
```

Carthage
```ogdl
github "metasmile/PropertyKit"
```

Swift Package Manager
```swift
.Package(url: "https://github.com/metasmile/PropertyKit.git")
```


## Modules

- [PropertyWatchable](https://github.com/metasmile/PropertyKit/blob/master/README.md#propertywatchable) *for NSKeyValueObservation*
- [PropertyDefaults](https://github.com/metasmile/PropertyKit/blob/master/README.md#propertydefaults) *for UserDefaults*
- ~



## PropertyDefaults

The simplest, but reliable way to manage UserDefaults. PropertyDefaults automatically binds value and type from Swift property to UserDefaults keys and values. It forces only protocol extension pattern that is focusing on syntax-driven value handling, so it helps to avoid unsafe String key use. Therefore, natually, Swift compiler will protect all of missing or duplicating states with its own. 

PropertyDefaults is new hard fork of [DefaultsKit](https://github.com/nmdias/DefaultsKit) by [nmdias](https://github.com/nmdias) with entirely different approaches.


### Features

- [x] Swift 4 Codable Support
- [x] Compile-time UserDefaults guaranteeing. 
- [x] Key-Type-Value relationship safety, no String literal use.
- [x] Structural extension-protocol-driven, instead of an intension.
- [x] Permission control
- [ ] Automatic private scope - In File, Class or Struct, Function

### Usage

An example to define automatic UserDefaults keys with basic Codable types:
```swift
extension Defaults: PropertyDefaults {
    public var autoStringProperty: String? {
        set{ set(newValue) } get{ return get() }
    }
    public var autoDateProperty: Date? {
        set{ set(newValue) } get{ return get() }
    }
}
```

```swift
var sharedDefaults = Defaults()
sharedDefaults.autoStringProperty = "the new value will persist in shared scope"
// sharedDefaults.autoStringProperty == Defaults.shared.autoStringProperty

Defaults.shared.autoStringProperty = "another new value will persist in shared scope"
// Defaults.shared.autoStringProperty == sharedDefaults.autoStringProperty

var localDefaults = Defaults(suiteName:"local")
localDefaults.autoStringProperty = "the new value will persist in local scope"
// localDefaults.autoStringProperty != Defaults.shared.autoStringProperty
```

Directly save/load as Codable type
```swift
public struct CustomValueType: Codable{
    var key:String = "value"
    var date:Date?
    var data:Data?
}
extension Defaults: PropertyDefaults {
    // non-optional - must define the default value with the keyword 'or'
    public var autoCustomNonOptionalProperty: CustomValueType {
        set{ set(newValue) } get{ return get(or: CustomValueType()) }
    }
    // optional with/without setter default value
    public var autoCustomOptionalProperty: CustomValueType? {
        set{ set(newValue) } get{ return get() }
    }
    public var autoCustomOptionalPropertySetterDefaultValue: CustomValueType? {
        set{ set(newValue, or: CustomValueType()) } get{ return get() }
    }
}
```


Strongly guaranteeing unique key with Swift compiler.
```swift
//CodeFile1_ofLargeProject.swift
protocol MyDefaultsKeysUsingInA : PropertyDefaults{
    var noThisIsMyKeyNotYours:Int?{ get }
}
extension Defaults : MyDefaultsKeysUsingInA{
    var noThisIsMyKeyNotYours:Int?{ set{ set(newValue) } get{ return get() } }
}

//CodeFile2_ofLargeProject.swift
protocol MyDefaultsKeysUsingInB : PropertyDefaults{
    var noThisIsMyKeyNotYours:Int?{ get }
}
extension Defaults : MyDefaultsKeysUsingInB{
    var noThisIsMyKeyNotYours:Int?{ set{ set(newValue) } get{ return get() } }
}
```

```bash
❗️Swift Compiler Error
~.swift:30:9: Invalid redeclaration of 'noThisIsMyKeyNotYours'
~.swift:21:9: 'noThisIsMyKeyNotYours' previously declared here
```

With this pattern, as you know, you also can control access permission with the protocol. It means you can use 'private' or 'file-private' defaults access.

```swift
// MyFile.swift
fileprivate protocol PrivateDefaultKeysInThisSwiftFile: PropertyDefaults{
    var filePrivateValue: String? {set get}
}

extension Defaults: PrivateDefaultKeysInThisSwiftFile {
    public var filePrivateValue: String? {
        set{ set(newValue) } get{ return get() }
    }
}

// Can access - 👌
Defaults.shared.filePrivateValue
```

```swift
// MyOtherFile.swift

// Not able to access - ❌
Defaults.shared.filePrivateValue
```

And, Yes, It's a hack way to crack our design intention.  

```swift
var p1:Int{
    Defaults.shared.set(2)  
    return Defaults.shared.get(or:0)  
}
var p2: Int{
    return Defaults.shared.get(or:0)  
}

p1 // == 2
p2 // == 0
//It means that are function/property-scoped capsulated defaults values.
```

## PropertyWatchable

A protocol extension based on NSKeyValueObservation. It simply enables to let a class object become a type-safe keypath observable object. And unique observer identifier will be assigned to all observers automatically. That prevents especially duplicated callback calls and so it can let you atomically manage a bunch of key-value flows between its joined queues.

### Features

- [x] Making an observable object with only protocol use.
- [x] Swift property literal based keypath observation.
- [x] Strictful type-guaranteed callback parameter support.
- [x] Automatic unique identifier support.
- [x] File-scoped observer removing support.
- [ ] Queue-private atomic operation support.

### Usage

The simplest example to use.
```swift
class WatchableObject:NSObject, PropertyWatchable{
    @objc dynamic
    var testingProperty:String?
}

let object = WatchableObject()
object.watch(\.testingProperty) {
    object.testingProperty == "some value"
    //Do Something.
}

object.testingProperty = "some value"
```

All options and strongly typed-parameters are same with NSKeyValueObservation. 
```swift
// Default option is the default of NSKeyValueObservation (.new)
// (WatchableObject, NSKeyValueObservedChange<Value>)
object.watch(\.testingProperty, options: [.initial, .new, .old]) { (target, changes) in     
    target.testingProperty == "some value"
    //Dd Something.
}
```
```swift
let object = WatchableObject()
object.testingProperty = "initial value"
config.watch(\.testingProperty, options: [.initial]) { (o, _) in
    o.testingProperty == "initial value"
}
```

Automatic line by line identifier support.
```swift
object.watch(\.testingProperty) {
    // Listening as a unique observer 1
}

object.watch(\.testingProperty) {
    // Listening as a unique observer 2
}

object.watch(\.testingProperty, id:"myid", options:[.old]) {
    // Listening as an observer which has identifier "myid"
}

// total 3 separated each observers are listening each callbacks.
```

Remove observations with various options.

```swift
// Remove only an observer which has "myid" only
object.unwatch(\.testingProperty, forIds:["myid"])

// Remove all observers that are watching ".testingProperty"
object.unwatch(\.testingProperty)

//Automatically remove all observers in current file.
object.unwatchAllFilePrivate()

//Automatically remove entire observers in application-wide.
object.unwatchAll()
```
