//
//  UserDefaultsStoreFacrtory.swift
//  Locus
//
//  Created by Derek Clarkson on 6/6/20.
//  Copyright © 2020 Derek Clarkson. All rights reserved.
//

public struct UserDefaultsStoreFactory: StoreFactory {

    public init() {}

    public func createStore<V>(scope: Scope, parent: Store<V>) -> Store<V> {
        if scope == .writable {
            return UserDefaultsWritableStore(parent: parent)
        }
        if scope == .readonly {
            return UserDefaultsReadonlyStore(parent: parent)
        }
        return parent
    }
}
