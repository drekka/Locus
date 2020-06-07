//
//  Store.swift
//  Environ
//
//  Created by Derek Clarkson on 30/5/20.
//  Copyright © 2020 Derek Clarkson. All rights reserved.
//

open class Store<V> {

    open var key: String {
        fatalError("Key property must be overridden.")
    }

    open var value: V {
        fatalError("Value property for key '" + key + "' must be overridden.")
    }

    open func store(newValue value: V) {
        fatalError("Key " + key + " is not storable.")
    }

    open func update(withDefaultValue value: V) {
        fatalError("Key " + key + " is not updateable.")
    }
}
