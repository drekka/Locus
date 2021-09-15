//
//  File.swift
//  File
//
//  Created by Derek Clarkson on 18/8/21.
//

import Locus

class MockStore: Store {

    var registerConfiguration: SettingConfiguration?
    func register(configuration: SettingConfiguration) {
        registerConfiguration = configuration
    }

    var configurationKey: String?
    var configurationResult: SettingConfiguration?
    func configuration(forKey key: String) -> SettingConfiguration {
        configurationKey = key
        return configurationResult!
    }

    var setDefaultKey: String?
    var setDefaultValue: Any?
    func setDefault<T>(_ value: T, forKey key: String) {
        setDefaultKey = key
        setDefaultValue = value
    }

    var removeKey: String?
    func remove(key: String) {
        removeKey = key
    }

    var subscriptKey: String?
    var subscriptValue: Any?
    var subscriptResult: Any?
    subscript<T>(key: String) -> T {
        get {
            subscriptKey = key
            return subscriptResult as! T
        }
        set(newValue) {
            subscriptKey = key
            subscriptValue = newValue
        }
    }
}
