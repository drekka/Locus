//
//  SettingsContainer.swift
//  environ
//
//  Created by Derek Clarkson on 13/5/20.
//  Copyright © 2020 Derek Clarkson. All rights reserved.
//

import Foundation

protocol SettingsInitializer {
    func initializeSettings()
}

class Settings {

    ///
    static var shared: SettingsContainer = {
        environLog("Starting singleton container...")
        return Settings()
    }()

    private let storeFactories: [StoreFactory]
    private var stores: [String: Any] = [:]

    public init(storeFactories: [StoreFactory] = [TransientStoreFactory(), UserDefaultsStoreFactory()]) {
        self.storeFactories = storeFactories.reversed()
    }
}

extension Settings: SettingsContainer {

    func register<T>(key: String, scope: Scope, defaultValue: T) {

        guard !stores.keys.contains(key) else {
            fatalError("Key " + key + " already registered")
        }

        stores[key] = storeFactories.reduce(DefaultStore(key: key, defaultValue: defaultValue)) { store, factory -> Store<T> in
            return factory.createStore(scope: scope, parent: store)
        }
    }

    func resolve<T>(_ key: String) -> T {
        return store(forKey: key).value
    }

    func update<T>(key: String, value: T) {
        store(forKey: key).update(withDefaultValue: value)
    }

    private func store<T>(forKey key: String) -> Store<T> {
        if let store = stores[key] {
            if let castStore = store as? Store<T> {
                return castStore
            }
            fatalError("Cast failure. Cannot cast a " + String(describing: type(of: store)) + " to a Store<" + String(describing: T.self) + ">.")
        }
        fatalError("Unknown key: " + key)
    }
}
