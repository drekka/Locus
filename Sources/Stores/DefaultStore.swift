//
//  Created by Derek Clarkson on 18/7/21.
//

/// A default store for in memory settings.
///
/// There should be a value for every setting in this store as it is always the last store in the chain.
public class DefaultStore: Store, ValueCastable {

    private var configurations: [String: SettingConfiguration] = [:]

    public init() {}

    public func register(configuration: SettingConfiguration) {
        if configurations.keys.contains(configuration.key) {
            fatalError("💥💥💥 Duplicate configuration for '\(configuration.key)' found 💥💥💥")
        }
        configurations[configuration.key] = configuration
    }

    public func configuration(forKey key: String) -> SettingConfiguration {
        guard let configuration = configurations[key] else {
            fatalError("💥💥💥 Key '\(key)' not registered with Locus 💥💥💥")
        }
        return configuration
    }

    public func setDefault<T>(_ value: T, forKey key: String) {
        let configuration = configuration(forKey: key)
        guard case .local = configuration.defaultValue else {
            fatalError("💥💥💥 Key '\(key)' is configured with a default value stored in user defaults. 💥💥💥")
        }
        log.debug("🧩 DefaultStore: Setting default \(key) -> \(String(describing: value))")
        configuration.defaultValue = .local(value)
    }

    public func remove(key _: String) {
        fatalError("💥💥💥 Cannot removes values from a DefaultStore 💥💥💥")
    }

    public subscript<T>(key: String) -> T {
        get {
            if case .local(let value) = configuration(forKey: key).defaultValue {
                return cast(value, forKey: key)
            }
            fatalError("💥💥💥 Key '\(key)' is configured with a default value stored in user defaults. 💥💥💥")
        }
        set {
            fatalError("💥💥💥 DefaultStore is read only. Cannot write a value for '\(key)' 💥💥💥")
        }
    }
}
