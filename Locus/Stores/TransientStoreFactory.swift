//
//  TransientStoreFactory.swift
//  Locus
//
//  Created by Derek Clarkson on 6/6/20.
//  Copyright © 2020 Derek Clarkson. All rights reserved.
//

/**
 Creates stores for transient settings.
 */
public struct TransientStoreFactory: StoreFactory {

    public init() {}

    public func createStoreForSetting<V>(withKey key: String, scope: Scope, parent: Store<V>) -> Store<V> {
        return scope == .transient ? TransientStore(parent: parent) : parent
    }
}
