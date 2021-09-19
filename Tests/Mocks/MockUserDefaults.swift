//
//  File.swift
//  File
//
//  Created by Derek Clarkson on 15/9/21.
//

import UIKit
import Locus

// Use this mock because sunchronisation of user defaults is unreliable.
class MockUserDefaults: Defaults {
    
    var defaults: [String: Any] = [:]
    var registeredDefaults: [String: Any] = [:]

    func register(defaults: [String: Any]) {
        defaults.forEach { registeredDefaults[$0] = $1 }
    }

    func removeObject(forKey key: String) {
        defaults.removeValue(forKey: key)
    }

    func value(forKey key: String) -> Any? {
        if let value = defaults[key] {
            return value
        }
        if let value = registeredDefaults[key] {
            return value
        }
        return nil
    }

    func set(_ value: Any?, forKey key: String) {
        defaults[key] = value
    }
}
