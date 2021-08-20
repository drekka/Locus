//
//  File.swift
//  File
//
//  Created by Derek Clarkson on 7/8/21.
//

/// A property wrapper to connect a property with the setting that provides it's value.
@propertyWrapper
public class Setting<T> {

    public var wrappedValue: T {
        get { container()[key] }
        set { container()[key] = newValue }
    }

    private let container: () -> SettingsContainer
    private let key: String

    public init(wrappedValue _: T, key: String, container: @escaping () -> SettingsContainer = { SettingsContainer.shared }) {
        self.key = key
        self.container = container
    }

    public init(key: String, container: @escaping () -> SettingsContainer = { SettingsContainer.shared }) {
        self.key = key
        self.container = container
    }
}
