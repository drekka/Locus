//
//  Resolvable.swift
//  environ
//
//  Created by Derek Clarkson on 19/5/20.
//  Copyright © 2020 Derek Clarkson. All rights reserved.
//

public protocol SettingsContainer {
    func register<T>(key: String, scope: Scope, defaultValue: T)
    func resolve<T>(_ key: String) -> T
    func update<T>(key: String, value: T)
}

extension SettingsContainer {
    func register<T>(key: String, defaultValue: T) {
        register(key: key, scope: .readonly, defaultValue: defaultValue)
    }
}

