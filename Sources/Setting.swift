//
//  Created by Derek Clarkson on 7/8/21.
//

import os

/// A property wrapper to connect a property with the setting that provides it's value.
@propertyWrapper
public class Setting<T> {

    public var wrappedValue: T {
        get { container()[key] }
        set { container()[key] = newValue }
    }

    private let container: () -> SettingsContainer
    private let key: String

    public init(wrappedValue _: T, _: String, container _: @escaping () -> SettingsContainer = { SettingsContainer.shared }) {
        fatalError("🧩 Setting: Default values cannot be set using the property wrapper. Defaults should be set during registration or loaded from a default value source.")
    }

    public init(_ key: String, container: @escaping () -> SettingsContainer = { SettingsContainer.shared }) {
        self.key = key
        self.container = container
    }
}
