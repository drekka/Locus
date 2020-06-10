//
//  Resolvable.swift
//  locus
//
//  Created by Derek Clarkson on 19/5/20.
//  Copyright © 2020 Derek Clarkson. All rights reserved.
//

public protocol SettingsContainer {
    func register(_ registrars: (SettingsContainer) -> Void...)
    func register<T>(key: String, scope: Scope, defaultValue: T)
    func register<K, T>(key: K, scope: Scope, defaultValue: T) where K: SettingsKey
    func resolve<T>(_ key: String) -> T
    func resolve<K, T>(_ key: K) -> T where K: SettingsKey
    func store<T>(key: String, value: T)
    func store<K, T>(key: K, value: T) where K: SettingsKey
}

public extension SettingsContainer {

    func register<T>(key: String, defaultValue: T) {
        register(key: key, scope: .readonly, defaultValue: defaultValue)
    }

    func register<K, T>(key: K, defaultValue: T) where K: SettingsKey {
        register(key: key.rawValue, scope: .readonly, defaultValue: defaultValue)
    }

    func register<K, T>(key: K, scope: Scope, defaultValue: T) where K: SettingsKey {
        register(key: key.rawValue, scope: scope, defaultValue: defaultValue)
    }

    func resolve<K, T>(_ key: K) -> T where K: SettingsKey {
        resolve(key.rawValue)
    }

    func store<K, T>(key: K, value: T) where K: SettingsKey {
        store(key: key.rawValue, value: value)
    }
}
