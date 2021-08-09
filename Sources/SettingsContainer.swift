//
//  File.swift
//
//
//  Created by Derek Clarkson on 7/7/21.
//

public enum SettingsError: Error {
    case lintIssue(Error)
}

@resultBuilder
public enum SettingsBuilder {
    public static func buildBlock(_ settings: SettingConfig...) -> [SettingConfig] {
        return settings
    }
}

/// Singular container used to manage the settings.
public class SettingsContainer {

    /// Publically shared container.
    public static var shared = SettingsContainer()

    private var stores: [String: Store] = [:]

    /// Loads settings from a list of sources.
    ///
    /// Given that sources may be asynchonrous.
    public func load(sources: SettingsSource...) {
        
    }

    /// Entry point for registering settups with the container.
    ///
    /// - parameter settings: A `@resultBuilder` argument of setting configurations to be registered in the container.
    public func register(@SettingsBuilder settings: () -> [SettingConfig]) {
        settings().forEach { settingConfig in

            var store: Store = settingConfig.attributes.contains(.userDefaults) ? UserDefaultsStore(config: settingConfig) : DefaultStore(config: settingConfig)

            if settingConfig.attributes.contains(.transient) {
                store = TransientStore(nextStore: store)
            }

            if settingConfig.attributes.contains(.readonly) {
                store = ReadonlyStore(nextStore: store)
            }

            stores[settingConfig.key] = store
        }
    }

    func store(forKey key: String) -> Store {
        guard let store = stores[key] else {
            fatalError("💥💥💥 Key \(key) has not been registered with the container 💥💥💥")
        }
        return store
    }
}
