//
//  SettingsSubscriptable.swift
//  Locus
//
//  Created by Derek Clarkson on 9/6/20.
//  Copyright © 2020 Derek Clarkson. All rights reserved.
//

public protocol SettingsSubscriptable {
    subscript<T>(_ key:String) -> T { get set }
    subscript<K, T>(_ Key: K) -> T where K: SettingsKey { get set }
}

public extension SettingsSubscriptable where Self: SettingsContainer {

    subscript<T>(key: String) -> T {
        get { return resolve(key) }
        set { store(key: key, value: newValue) }
    }

    subscript<K, T>(key: K) -> T where K: SettingsKey {
        get { return resolve(key.rawValue) }
        set { store(key: key.rawValue, value: newValue) }
    }
}
