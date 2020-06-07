//
//  Store.swift
//  environ
//
//  Created by Derek Clarkson on 19/5/20.
//  Copyright © 2020 Derek Clarkson. All rights reserved.
//



public protocol Castable {
    func cast<T>(_ value: Any, forKey key: String) -> T
}

public extension Castable {

    func cast<T>(_ value: Any, forKey key: String) -> T {
        if let castValue = value as? T {
            environLog("Resolving %@ -> %@", key, String(describing: value))
            return castValue
        }
        fatalError("Unable to cast value for '" + key + "'")
    }
}
