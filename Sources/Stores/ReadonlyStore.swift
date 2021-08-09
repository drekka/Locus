//
//  File.swift
//  File
//
//  Created by Derek Clarkson on 8/8/21.
//

import os

/// Enforces read only settings.
public class ReadonlyStore: Store {

    private let nextStore: Store

    public var value: Any {
        get { nextStore.value }
        set { os_log(.debug, "🧩 ReadonlyStore: Ignoring new value") }
    }

    public init(nextStore: Store) {
        self.nextStore = nextStore
    }

    public func setDefault(_ value: Any) {
        nextStore.setDefault(value)
    }
}
