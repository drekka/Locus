//
//  File.swift
//
//
//  Created by Derek Clarkson on 18/7/21.
//

import os

/// A store that can be updated, but doesn't preserve the value across app restarts.
public class TransientStore: Store {

    private let nextStore: Store
    private var transientValue: Any?

    public var value: Any {
        get {
            if let value = transientValue {
                os_log(.debug, "🧩 TransientStore: Found value in transient store")
                return value
            }
            return nextStore.value
        }
        set {
            os_log(.debug, "🧩 TransientStore: Storing transient value")
            transientValue = newValue
        }
    }

    public init(nextStore: Store) {
        self.nextStore = nextStore
    }

    public func setDefault(_ value: Any) {
        nextStore.setDefault(value)
    }
}
