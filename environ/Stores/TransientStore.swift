//
//  TransientStore.swift
//  Environ
//
//  Created by Derek Clarkson on 2/6/20.
//  Copyright © 2020 Derek Clarkson. All rights reserved.
//

class TransientStore<V>: ChainedStore<V> {

    private var transient: V?

    override var value: V {
        if let transient = transient {
            return transient
        }
        return parent.value
    }

    override func store(newValue value: V) {
        transient = value
    }
}
