//
//  File.swift
//
//
//  Created by Derek Clarkson on 18/7/21.
//
import os

public class DefaultStore: Store {

    private var _value: Any

    public var value: Any {
        get { _value }
        set { fatalError("💥💥💥 Cannot write values to a DefaultStore 💥💥💥") }
    }

    public init(config: SettingConfig) {
        _value = config.defaultValue
    }

    public func setDefault(_ value: Any) {
        _value = value
    }
}
