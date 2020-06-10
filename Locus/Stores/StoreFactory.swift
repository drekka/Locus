//
//  StoreFactory.swift
//  Locus
//
//  Created by Derek Clarkson on 30/5/20.
//  Copyright © 2020 Derek Clarkson. All rights reserved.
//

public protocol StoreFactory {
    func createStore<V>(scope: Scope, parent: Store<V>) -> Store<V>
}
