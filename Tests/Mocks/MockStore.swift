//
//  File.swift
//  File
//
//  Created by Derek Clarkson on 18/8/21.
//

import Locus
import UsefulThings

class MockStore: Store {

    var configurations: [String: SettingConfiguration] = [:]
    var defaults: [String: Any] = [:]
    var values: [String: Any] = [:]

    func register(configuration: SettingConfiguration) {
        configurations[configuration.key] = configuration
    }

    func configuration(forKey key: String) -> SettingConfiguration {
        configurations[key]!
    }

    func setDefault<T>(_ value: T, forKey key: String) {
        defaults[key] = value
    }

    func remove(key: String) {
        values.removeValue(forKey: key)
    }

    subscript<T>(key: String) -> T {
        get {
            if let value: T = cast(values[key]) { return value }
            if let registeredDefaultValue: T = cast(defaults[key]) { return registeredDefaultValue }
            if case .static(let value) = configurations[key]?.defaultValue,
               let castValue = cast(value) as T? {
                return castValue
            }
            fatalError("Arrrg!")
        }
        set(newValue) {
            values[key] = newValue
        }
    }
}
