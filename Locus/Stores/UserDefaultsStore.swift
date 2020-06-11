//
//  UserDefaultsStore.swift
//  locus
//
//  Created by Derek Clarkson on 19/5/20.
//  Copyright © 2020 Derek Clarkson. All rights reserved.
//

/**
 Reads from the app's user defaults.
 */
class UserDefaultsReadonlyStore<V>: ChainedStore<V>, Castable {

    override var value: V {
        if let value = UserDefaults.standard.value(forKey: key) {
            return cast(value, forKey: key)
        }
        return parent.value
    }

    override func reset() {
        UserDefaults.standard.removeObject(forKey: key)
    }
}

/**
Reads and writes from the app's user defaults.
*/
class UserDefaultsWritableStore<V>: UserDefaultsReadonlyStore<V> {

    override func store(newValue value: V) {
        UserDefaults.standard.set(value, forKey: key)
    }
}

