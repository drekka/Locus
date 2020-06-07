//
//  MockStoreFactory.swift
//  EnvironTests
//
//  Created by Derek Clarkson on 7/6/20.
//  Copyright © 2020 Derek Clarkson. All rights reserved.
//

import Environ

struct MockStoreFactory: StoreFactory {

    init() {}

    func createStore<V>(scope: Scope, parent: Store<V>) -> Store<V> {
        return ChainedStore(parent: parent)
    }
}
