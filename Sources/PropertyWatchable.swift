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

public struct PropertyWatcherInfo{
    public static let StaticId="\(PropertyWatcherInfo.self)_static"

    var id:String
    var observer:NSKeyValueObservation
    var keyPath:AnyKeyPath
}

public protocol _PropertyWatchable:class {
    associatedtype KeyPathRoot:NSObject

    func watch<Value>(_ target:KeyPathRoot, _ keyPath:KeyPath<KeyPathRoot,Value>
            , id:String
            , options: NSKeyValueObservingOptions?
            , changeHandler: @escaping (KeyPathRoot, NSKeyValueObservedChange<Value>) -> Void) -> PropertyWatcherInfo

}

public class PropertyWatcher<KeyPathRoot:NSObject>: NSObject, _PropertyWatchable {
    fileprivate lazy var _observations = [String:PropertyWatcherInfo]() // [observationId : PropertyWatcherInfo]
    fileprivate lazy var _autoObservationIdsInFile = [String:[String]]() // [file : observationId]

    @discardableResult
    public func watch<Value>(_ target: KeyPathRoot
            , _ keyPath: KeyPath<KeyPathRoot, Value>
            , id:String
            , options: NSKeyValueObservingOptions?=nil
            , changeHandler: @escaping (KeyPathRoot, NSKeyValueObservedChange<Value>) -> Void) -> PropertyWatcherInfo {

        if let existedInfo = _observations[id]{
            existedInfo.observer.invalidate()
            _observations.removeValue(forKey: id)
        }

        var observer:NSKeyValueObservation

        if let _options = options{
            observer = target.observe(keyPath, options:_options, changeHandler: changeHandler)
        }else{
            observer = target.observe(keyPath, changeHandler: changeHandler)
        }
        let info = PropertyWatcherInfo(id:id, observer: observer, keyPath: keyPath)
        self._observations[id] = info

        return info
    }

    fileprivate func appendAutoIdentifier(file:String, function:String, line:Int, id:String?=nil) -> String{
        if _autoObservationIdsInFile[file] == nil{
            _autoObservationIdsInFile[file] = [String]()
        }
        let autoObservationId = autoIdentifier(file:file,function:function,line:line, id:id)
        _autoObservationIdsInFile[file]?.append(autoObservationId)
        return autoObservationId
    }

    fileprivate func autoIdentifier(file:String, function:String, line:Int, id:String?=nil) -> String{
        let className = URL(string: file)?.deletingPathExtension().lastPathComponent ?? String(describing: type(of:self))
        return "\(id ?? "")\(className)_\(function)_\(String(line))"
    }
}

public protocol PropertyWatchable where Self:NSObject {
    associatedtype _Observee:NSObject
    var watcher: PropertyWatcher<_Observee> {get}
}

private struct PropertyWatchableAssociatedKeys {
    static var watcher:Int?
}

extension PropertyWatchable where _Observee == Self{
    public var watcher: PropertyWatcher<_Observee> {
        var _watcher = objc_getAssociatedObject(self, &PropertyWatchableAssociatedKeys.watcher)
        if _watcher == nil {
            _watcher = PropertyWatcher<_Observee>()
            objc_setAssociatedObject(self, &PropertyWatchableAssociatedKeys.watcher, _watcher, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
        return _watcher as! PropertyWatcher<_Observee>
    }

    @discardableResult
    public func watch<Value>(_ keyPath:KeyPath<_Observee,Value>
            , _file:String=#file
            , _function:String=#function
            , _line:Int=#line
            , id:String?=nil
            , options: NSKeyValueObservingOptions?=nil
            , changeHandler: @escaping (_Observee, NSKeyValueObservedChange<Value>) -> Void
            ) -> PropertyWatcherInfo{

        let _id = id ?? self.watcher.appendAutoIdentifier(file: _file, function: _function, line: _line, id:id)
        return self.watcher.watch(self, keyPath, id:_id, options:options, changeHandler: changeHandler)
    }

    @discardableResult
    public func watch<Value>(_ keyPath:KeyPath<_Observee,Value>
            , _file:String=#file
            , _function:String=#function
            , _line:Int=#line
            , id:String?=nil
            , options: NSKeyValueObservingOptions?=nil
            , changeHandler: @escaping () -> Void) -> PropertyWatcherInfo{

        let _id = id ?? self.watcher.appendAutoIdentifier(file: _file, function: _function, line: _line, id:id)
        return self.watcher.watch(self, keyPath, id:_id, options:options, changeHandler: { _, _ in changeHandler() })
    }

    public func watching<Value>(by keyPath:KeyPath<_Observee,Value>, id:String?=nil) -> [PropertyWatcherInfo]{
        return self.watcher._observations.compactMap { e -> PropertyWatcherInfo? in
            return (id == nil ? true : id==e.key) && keyPath == e.value.keyPath ? e.value : nil
        }
    }

    @discardableResult
    public func unwatchAllFilePrivate<Value>(_file:String=#file, _ keyPath:KeyPath<_Observee,Value>?=nil) -> Bool{
        guard let idsInFile = watcher._autoObservationIdsInFile[_file] else {
            return false
        }

        let ids = keyPath==nil ? idsInFile : idsInFile.filter { id in watcher._observations[id]?.keyPath == keyPath }
        assert(ids.count>0,"Already unwatched In Current File.\(String(describing: keyPath))")

        if self.unwatch(forIds: ids).count > 0{
            let indexesOfIds = ids.compactMap({ id -> Int? in idsInFile.index(of: id) })
            for index in indexesOfIds {
                watcher._autoObservationIdsInFile[_file]?.remove(at: index)
            }
            if indexesOfIds.count>0 {
                return true
            }
        }
        assert(false, "unwatch for ids \(ids) was failed." )
        return false
    }

    @discardableResult
    public func unwatch<Value>(_ keyPath:KeyPath<_Observee,Value>, forIds:[String]?=nil) -> [String:Bool]{
        var ids = self.watching(by:keyPath).map { e -> String in e.id }

        if let forIds = forIds{
            ids = Array(Set(ids).intersection(Set(forIds)))
        }

        let unwatched = self.unwatch(forIds: ids)
        assert(forIds == nil || Set(watcher._observations.compactMap({ key, value -> String? in key })).intersection(Set(forIds!)).count==0, "\(String(describing: forIds)) is still remaning.")
        return unwatched
    }

    @discardableResult
    public func unwatch(forIds:[String]) -> [String:Bool]{
        var success = [String:Bool]()
        for id in forIds {
            success[id] = self.watcher._observations[id] != nil
            self.watcher._observations[id]?.observer.invalidate()
            self.watcher._observations.removeValue(forKey: id)
        }
        return success
    }

    public func unwatchAll() {
        for item in self.watcher._observations{
            item.value.observer.invalidate()
        }
        self.watcher._observations.removeAll()
    }
}
