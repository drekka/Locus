//
//  UserDefaultsStore.swift
//  environ
//
//  Created by Derek Clarkson on 19/5/20.
//  Copyright © 2020 Derek Clarkson. All rights reserved.
//

class UserDefaultsReadonlyStore<V>: ChainedStore<V>, Castable {

    override var value: V {
        if let value = UserDefaults.standard.value(forKey: key) {
            return cast(value, forKey: key)
        }
        return parent.value
    }
}

class UserDefaultsWritableStore<V>: UserDefaultsReadonlyStore<V> {

    override func store(newValue value: V) {
        UserDefaults.standard.set(value, forKey: key)
    }
}

