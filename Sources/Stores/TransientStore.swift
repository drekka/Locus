//
//  Created by Derek Clarkson on 18/7/21.
//

/// A store that can be updated, but doesn't preserve the value across app restarts.
public class TransientStore: Store, ValueCastable {

    private var parent: Store
    private var transientValues: [String: Any] = [:]

    public init(parent: Store) {
        self.parent = parent
    }

    public func register(configuration: SettingConfiguration) {
        parent.register(configuration: configuration)
    }

    public func configuration(forKey key: String) -> SettingConfiguration {
        parent.configuration(forKey: key)
    }

    public func setDefault<T>(_ value: T, forKey key: String) {
        parent.setDefault(value, forKey: key)
    }

    public func remove(key: String) {
        if parent.configuration(forKey: key).persistence == .transient {
            log.debug("🧩 TransientStore: Removing value for '\(key)'")
            transientValues.removeValue(forKey: key)
        } else {
            log.debug("🧩 TransientStore: Passing to parent")
            parent.remove(key: key)
        }
    }

    public subscript<T>(key: String) -> T {
        get {
            if let value = transientValues[key] {
                log.debug("🧩 TransientStore: Found value for '\(key)'")
                return cast(value, forKey: key)
            }
            return parent[key]
        }
        set {
            if parent.configuration(forKey: key).persistence == .transient {
                log.debug("🧩 TransientStore: Storing value for key '\(key)'")
                transientValues[key] = newValue
            } else {
                parent[key] = newValue
            }
        }
    }
}
