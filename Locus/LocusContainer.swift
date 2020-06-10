//
//  LocusContainer.swift
//  Locus
//
//  Created by Derek Clarkson on 9/6/20.
//  Copyright © 2020 Derek Clarkson. All rights reserved.
//

public class LocusContainer {

    ///
    public static var shared: SettingsContainer = {
        locusLog("Starting singleton container...")
        return LocusContainer()
    }()

    private let storeFactories: [StoreFactory]
    private var stores: [String: Any] = [:]

    public init(storeFactories: [StoreFactory] = [TransientStoreFactory(), UserDefaultsStoreFactory()]) {
        self.storeFactories = storeFactories.reversed()
    }

    public convenience init(storeFactories: StoreFactory...) {
        self.init(storeFactories: storeFactories)
    }
}

extension LocusContainer: SettingsContainer, SettingsSubscriptable {

    public func register(_ registrars: (SettingsContainer) -> Void...) {
        registrars.forEach { $0(self) }
    }

    public func register<T>(key: String, scope: Scope, defaultValue: T) {

        guard !stores.keys.contains(key) else {
            fatalError("Key " + key + " already registered")
        }

        stores[key] = storeFactories.reduce(DefaultStore(key: key, defaultValue: defaultValue)) { store, factory -> Store<T> in
            return factory.createStore(scope: scope, parent: store)
        }
    }

    public func resolve<T>(_ key: String) -> T {
        return storeChain(forKey: key).value
    }

    public func store<T>(key: String, value: T) {
        storeChain(forKey: key).update(withDefaultValue: value)
    }

    private func storeChain<T>(forKey key: String) -> Store<T> {
        if let store = stores[key] {
            if let castStore = store as? Store<T> {
                return castStore
            }
            fatalError("Cast failure. Cannot cast a " + String(describing: type(of: store)) + " to a Store<" + String(describing: T.self) + ">.")
        }
        fatalError("Unknown key: " + key)
    }
}
