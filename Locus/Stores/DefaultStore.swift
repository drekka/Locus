//
//  DefaultStore.swift
//  Locus
//
//  Created by Derek Clarkson on 6/6/20.
//  Copyright © 2020 Derek Clarkson. All rights reserved.
//

class DefaultStore<V>: Store<V> {

    private var settingKey: String
    override var key: String {
        settingKey
    }

    private var defaultValue: V
    override var value: V {
        return defaultValue
    }

    init(key: String, defaultValue: V) {
        self.settingKey = key
        self.defaultValue = defaultValue
    }

    override func update(withDefaultValue value: V) {
        defaultValue = value
    }
}

