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
        get {
            let value = store.value
            guard let value = value as? T else {
                fatalError("💥💥💥 Expecting a \(T.self) but got a \(type(of: value)) from the settings container 💥💥💥")
            }
            return value
        }
        set { store.value = newValue }
    }

    private var storeSource: (() -> Store)!
    private lazy var store: Store = {
        defer {
            storeSource = nil
        }
        return storeSource()
    }()

    public init(wrappedValue _: T, key: String, container: SettingsContainer = .shared) {
        storeSource = { container.store(forKey: key) }
    }

    public init(key: String, container: SettingsContainer = .shared) {
        storeSource = { container.store(forKey: key) }
    }
}
