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
    var registerDefaults: [String: Any]?
    func register(defaults: [String: Any]) {
        registerDefaults = defaults
    }

    var removeObjectForKey: String?
    func removeObject(forKey: String) {
        removeObjectForKey = forKey
    }

    var valueForKey: String?
    var valueForKeyResult: Any?
    func value(forKey: String) -> Any? {
        valueForKey = forKey
        return valueForKeyResult
    }

    var setForKey: String?
    var setValue: Any?
    func set(_ value: Any?, forKey: String) {
        setForKey = forKey
        setValue = value
    }
}
