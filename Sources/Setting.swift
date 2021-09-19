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

    public convenience init<K>(_ key: K, container: @autoclosure @escaping () -> SettingsContainer = SettingsContainer.shared) where K: RawRepresentable, K.RawValue == String {
        self.init(key.rawValue, container: container())
    }

    public init(_ key: String, container: @autoclosure @escaping () -> SettingsContainer = SettingsContainer.shared) {
        self.key = key
        self.container = container
    }
}
