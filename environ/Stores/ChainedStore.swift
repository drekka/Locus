//
//  ChainedStore.swift
//  Environ
//
//  Created by Derek Clarkson on 6/6/20.
//  Copyright © 2020 Derek Clarkson. All rights reserved.
//

open class ChainedStore<V>: Store<V> {

    let parent: Store<V>

    public override var key: String {
        return parent.key
    }

    public override var value: V {
        return parent.value
    }

    public init(parent: Store<V>) {
        self.parent = parent
    }

    public override func update(withDefaultValue value: V) {
        parent.update(withDefaultValue: value)
    }

    public override func store(newValue value: V) {
        parent.store(newValue: value)
    }
}

