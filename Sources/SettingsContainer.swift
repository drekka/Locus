//
//  File.swift
//
//
//  Created by Derek Clarkson on 7/7/21.
//

// public enum SettingsError: Error {
//    case lintIssue(Error)
// }

@resultBuilder
public enum SettingsBuilder {
    public static func buildBlock(_ settings: SettingConfiguration...) -> [SettingConfiguration] {
        return settings
    }
}

/// Singular container used to manage the settings.
public class SettingsContainer {

    /// Publically shared container.
    public static var shared = SettingsContainer()

    private var stores: Store
    private var registeredSettings: [String: SettingConfiguration] = [:]

    // MARK: - Lifecycle

    public init() {
        stores = TransientStore(parent: UserDefaultsStore(parent: DefaultStore()))
    }

    /// Loads settings from a list of sources.
    ///
    /// Given that sources may be asynchonrous.
    public func load(sources _: SettingsSource...) {}

    /// Entry point for registering settups with the container.
    ///
    /// - parameter settings: A `@resultBuilder` argument of setting configurations to be registered in the container.
    public func register(@SettingsBuilder settings: () -> [SettingConfiguration]) {
        settings().forEach { configuration in
            stores.register(configuration: configuration)
        }
    }

    // MARK: - Accessing values

    public subscript<T>(_ key: String) -> T {
        get { stores[key] }
        set { stores[key] = newValue }
    }
}
