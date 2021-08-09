//
//  File.swift
//
//
//  Created by Derek Clarkson on 18/7/21.
//
import os
import UIKit

/// Wraps the system user defaults.
public class UserDefaultsStore: Store {
    
    private let key: String

    public var value: Any {
        get {
            guard let value = UserDefaults.standard.value(forKey: key) else {
                fatalError("💥💥💥 No value or registered value for user defaults key \(key) 💥💥💥")
            }

            os_log(.debug, "🧩 UserDefaultsStore: Found value in user defaults")
            return value
        }
        set {
            os_log(.debug, "🧩 UserDefaultsStore: Storing value for \(self.key) in user defaults")
            UserDefaults.standard.set(newValue, forKey: key)
        }
    }

    public init(config: SettingConfig) {
        self.key = config.key
        UserDefaults.standard.register(defaults: [key: config.defaultValue])
    }

    public func setDefault(_ value: Any) {
        UserDefaults.standard.register(defaults: [key: value])
    }
}
