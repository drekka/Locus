//
//  UserDefaultsStoreFacrtory.swift
//  Locus
//
//  Created by Derek Clarkson on 6/6/20.
//  Copyright © 2020 Derek Clarkson. All rights reserved.
//

/**
Creates stores for values that can read and write to the app's user defaults.
*/
public struct UserDefaultsStoreFactory: StoreFactory {

    public init() {}

    public func createStoreForSetting<V>(withKey key: String, scope: Scope, parent: Store<V>) -> Store<V> {
        if scope == .writable {
            return UserDefaultsWritableStore(parent: parent)
        }
        if scope == .readonly {
            return UserDefaultsReadonlyStore(parent: parent)
        }
        return parent
    }
}
