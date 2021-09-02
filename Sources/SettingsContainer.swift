//
//  Created by Derek Clarkson on 7/7/21.
//

import Combine
import os

let log = Logger(subsystem: "au.com.derekclarkson.locus", category: "locus")

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
    private var readDefaultsCancellable: Cancellable?

    // MARK: - Lifecycle

    public init() {
        stores = TransientStore(parent: UserDefaultsStore(parent: DefaultStore()))
    }

    /// Loads settings from a list of sources.
    ///
    /// - parameter sources: A list of sources where settings can be obtianed, in the order you want them to be read.
    public func read(sources: DefaultValueSource...) {

        readDefaultsCancellable = sources.publisher
            .flatMap(maxPublishers: .max(1)) { $0.defaultValues }
            .sink { _ in
                self.readDefaultsCancellable = nil
            }
        receiveValue: { self.stores.setDefault($0.1, forKey: $0.0) }

        log.debug("🧩 SettingsContainer: Reading sources for default values")
        sources.forEach { $0.read() }
    }

    /// Entry point for registering settups with the container.
    ///
    /// - parameter settings: A `@resultBuilder` argument of setting configurations to be registered in the container.
    public func register(@SettingsBuilder settings: () -> [SettingConfiguration]) {
        settings().forEach { configuration in
            stores.register(configuration: configuration)
        }
    }
    
    // MARK: - Accessing values

    /// Provides access to settings.
    ///
    /// - parameter key: The key of the setting.
    public subscript<T>(_ key: String) -> T where T: Any {
        get { stores[key] }
        set { stores[key] = newValue }
    }
}
