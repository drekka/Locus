//
//  File.swift
//
//
//  Created by Derek Clarkson on 18/7/21.
//
import os
import UIKit

/// Protocol duplicating `UserDefaults` functions so mocks can be injected during testing.
public protocol Defaults: AnyObject {
    func register(defaults: [String: Any])
    func removeObject(forKey: String)
    func value(forKey: String) -> Any?
    func set(_ newValue: Any?, forKey: String)
}

extension UserDefaults: Defaults {}

/// Wraps the system user defaults.
public class UserDefaultsStore: Store, ValueCastable {

    private var parent: Store
    private let defaults: Defaults

    public required init(parent: Store, defaults: Defaults = UserDefaults.standard) {
        self.parent = parent
        self.defaults = defaults
    }

    public func register(configuration: SettingConfiguration) {
        parent.register(configuration: configuration)
    }

    public func configuration(forKey key: String) -> SettingConfiguration {
        parent.configuration(forKey: key)
    }

    public func setDefault<T>(_ value: T, forKey key: String) {
        if parent.configuration(forKey: key).scope == .userDefaults {
            os_log(.debug, "🧩 UserDefaultsStore: Registering default value for \(key) in user defaults")
            defaults.register(defaults: [key: value])
        } else {
            parent.setDefault(value, forKey: key)
        }
    }

    public func remove(key: String) {
        if parent.configuration(forKey: key).scope == .userDefaults {
            os_log(.debug, "🧩 UserDefaultsStore: removing value for key \(key)")
            defaults.removeObject(forKey: key)
        } else {
            parent.remove(key: key)
        }
    }

    public subscript<T>(key: String) -> T {
        get {
            guard parent.configuration(forKey: key).scope == .userDefaults,
                  let value = defaults.value(forKey: key) else {
                return parent[key]
            }

            os_log(.debug, "🧩 UserDefaultsStore: Found value in user defaults")
            return cast(value, forKey: key)
        }
        set {
            if parent.configuration(forKey: key).scope == .userDefaults {
                os_log(.debug, "🧩 UserDefaultsStore: Storing value for \(key) in user defaults")
                defaults.set(newValue, forKey: key)
            } else {
                parent[key] = newValue
            }
        }
    }
}
