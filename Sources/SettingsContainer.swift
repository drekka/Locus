//
//  Created by Derek Clarkson on 7/7/21.
//

import Combine
import os
import UIKit

/// A change to a default value.
public typealias DefaultValueUpdate = (key: String, value: Any)

let log = Logger(subsystem: "au.com.derekclarkson.locus", category: "locus")

/// Provides the ability to register settings.
@resultBuilder
public enum SettingsBuilder {

    public static func buildBlock(_ settings: SettingConfigurationSource...) -> [SettingConfiguration] {
        settings.flatMap { $0.builtSettings }
    }

    public static func buildOptional(_ settings: [SettingConfigurationSource]?) -> [SettingConfiguration] {
        settings?.flatMap { $0.builtSettings } ?? []
    }

    public static func buildEither(first settings: [SettingConfiguration]) -> [SettingConfiguration] {
        settings.flatMap { $0.builtSettings }
    }

    public static func buildEither(second settings: [SettingConfiguration]) -> [SettingConfiguration] {
        settings.flatMap { $0.builtSettings }
    }
}

/// Singular container used to manage the settings.
///
/// All settings must be registered in this container and accessed either via it or the Setting property wrapper.
public class SettingsContainer {

    /// Publicly shared container.
    public static var shared = SettingsContainer()

    private var stores: Store
    private var registeredSettings: [String: SettingConfiguration] = [:]
    private let defaultValueUpdateSubject = PassthroughSubject<DefaultValueUpdate, Never>()

    /// Provides access to a publisher which sends updates to default values.
    public var defaultValueUpdates: AnyPublisher<DefaultValueUpdate, Never> {
        return defaultValueUpdateSubject.eraseToAnyPublisher()
    }

    // MARK: - Lifecycle

    public init(stores: Store = TransientStore(parent: UserDefaultsStore(parent: DefaultStore())),
                notificationCenter _: NotificationCenter = NotificationCenter.default) {
        self.stores = stores
    }

    /// Loads settings from a list of sources.
    ///
    /// - parameter sources: A list of sources where settings can be obtained, in the order you want them to be read.
    public func read(sources: DefaultValueSource..., completion: @escaping (Error?) -> Void) {
        read(sources: sources, completion: completion)
    }

    /// Loads settings from a list of sources.
    ///
    /// - parameter sources: A list of sources where settings can be obtained, in the order you want them to be read.
    public func read(sources: [DefaultValueSource], completion: @escaping (Error?) -> Void) {

        // Execute publishers in sequence one at a time.
        log.debug("🧩 SettingsContainer: Reading sources for default values")
        Task {
            do {
                for source in sources {
                    let preferences = try await source.readDefaults()
                    preferences.enumerated().forEach { _, preference in
                        log.debug("🧩 SettingsContainer: Stored default value: \(preference.key) -> \(String(describing: preference.value))")
                        stores.setDefault(preference.value, forKey: preference.key)
                        defaultValueUpdateSubject.send((key: preference.key, value: preference.value))
                    }
                }
                log.debug("🧩 SettingsContainer: Finished reading default values")
                completion(nil)
            } catch {
                log.debug("🧩 SettingsContainer: Finished reading default values with error \(error.localizedDescription)")
                completion(error)
            }
        }
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
    public subscript<T, K>(_ key: K) -> T where T: Any, K: RawRepresentable, K.RawValue == String {
        get { stores[key.rawValue] }
        set { stores[key.rawValue] = newValue }
    }

    /// Provides access to settings.
    ///
    /// - parameter key: The key of the setting.
    public subscript<T>(_ key: String) -> T where T: Any {
        get { stores[key] }
        set { stores[key] = newValue }
    }
}
