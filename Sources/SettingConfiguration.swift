//
//  Created by Derek Clarkson on 26/7/21.
//

/// persistence of a setting.
///
/// By default a setting is readonly. However these values allow a setting to be updated by specifiying where the updated values can be stored.
public enum Persistence {

    // Default persistence is that settings cannot be updated.
    case none

    // Setting updates are stored in a temporary in-memory store.
    case transient

    // Setting updates are stored in user defaults.
    case userDefaults
}

/// Defines where the default value for a setting is expected to be found and therefore where updates to it are stored.
public enum Default {

    /// The default for the setting will be sourced from the registered defaults in `UserDefaults`.
    case userDefaults

    /// The default will be the hard coded value stored in setting's configuration in memory.
    case local(Any)
}

/// Creates a "read only" setting configuration.
///
/// Readonly settings cannot be updated by the app.
///
/// - parameter key: The key to register the config under.
/// - parameter default: The default value for the setting.
/// - returns: A `SettingConfiguration`.
public func readonly(_ key: String, default defaultValue: Default) -> SettingConfiguration {
    SettingConfiguration(key, default: defaultValue)
}

/// Creates a "read only" setting configuration.
///
/// Readonly settings cannot be updated by the app.
///
/// - parameter key: The key to register the config under.
/// - parameter default: The default value for the setting.
/// - returns: A `SettingConfiguration`.
public func readonly<K>(_ key: K, default defaultValue: Default) -> SettingConfiguration where K: RawRepresentable, K.RawValue == String {
    readonly(key.rawValue, default: defaultValue)
}

/// Creates a transient setting configuration.
///
/// Transient settings can be updated, but the updated values are stored in memory and not saved if the app is shutdown.
///
/// - parameter key: The key to register the config under.
/// - parameter releaseLocked: If set to true, specifies that the setting can be updated in debug builds, but not release builds.
/// - parameter default: The default value for the setting.
/// - returns: A `SettingConfiguration`.
public func transient(_ key: String, releaseLocked: Bool = false, default defaultValue: Default) -> SettingConfiguration {
    SettingConfiguration(key, persistence: .transient, releaseLocked: releaseLocked, default: defaultValue)
}

/// Creates a transient setting configuration.
///
/// Transient settings can be updated, but the updated values are stored in memory and not saved if the app is shutdown.
///
/// - parameter key: The key to register the config under.
/// - parameter releaseLocked: If set to true, specifies that the setting can be updated in debug builds, but not release builds.
/// - parameter default: The default value for the setting.
/// - returns: A `SettingConfiguration`.
public func transient<K>(_ key: K, releaseLocked: Bool = false, default defaultValue: Default) -> SettingConfiguration where K: RawRepresentable, K.RawValue == String {
    transient(key.rawValue, releaseLocked: releaseLocked, default: defaultValue)
}

/// Creates a setting which stores updates in `UserDefaults` and sources default values from the registered defaults domain.
///
/// - parameter key: The key to register the config under.
/// - parameter releaseLocked: If set to true, specifies that the setting can be updated in debug versions, but not release versions.
/// - parameter default: The default value for the setting.
/// - returns: A `SettingConfiguration`.
public func userDefault(_ key: String, releaseLocked: Bool = false) -> SettingConfiguration {
    SettingConfiguration(key, persistence: .userDefaults, releaseLocked: releaseLocked, default: .userDefaults)
}

/// Creates a setting which stores updates in `UserDefaults`.
///
/// - parameter key: The key to register the config under.
/// - parameter releaseLocked: If set to true, specifies that the setting can be updated in debug versions, but not release versions.
/// - parameter default: The default value for the setting.
/// - returns: A `SettingConfiguration`.
public func userDefault<K>(_ key: K, releaseLocked: Bool = false) -> SettingConfiguration where K: RawRepresentable, K.RawValue == String {
    userDefault(key.rawValue, releaseLocked: releaseLocked)
}

/// Defines the setup of a given setting.
public class SettingConfiguration {

    /// The unique key of a setting. No two settings can have the same key.
    public let key: String

    /// Defines where any updates to the setting will be stored.
    public let persistence: Persistence

    /// If the setting is release locked. Ie. Updatable in Debug builds, readonly in Release builds.
    public let releaseLocked: Bool

    /// The default value for the setting. This can be updated by loading a new default value from a config file or other source. If there is an updated value for the setting, it will override any default value.
    public var defaultValue: Default

    /// Convenience initialiser that accepts `RawRepresentable` as a setting keys.
    ///
    /// - parameter key: The key to register the config under.
    /// - parameter persistence: Whether the setting can be updated and where updates are stored. Readonly, transient or user defaults.
    /// - parameter default: The default value for the setting. This also defines where the default is stored for update purposes.
    /// - parameter releaseLocked: If true the setting can be updated in Debug builds but not Release builds.
    public convenience init<K>(_ key: K,
                               persistence: Persistence = .none,
                               releaseLocked: Bool = false,
                               default defaultValue: Default) where K: RawRepresentable, K.RawValue == String {
        self.init(key.rawValue, persistence: persistence, releaseLocked: releaseLocked, default: defaultValue)
    }

    /// Default initialiser.
    ///
    /// - parameter key: The key to register the config under.
    /// - parameter persistence: Whether the setting can be updated and where updates are stored. Readonly, transient or user defaults.
    /// - parameter default: The default value for the setting. This also defines where the default is stored for update purposes.
    /// - parameter releaseLocked: If true the setting can be updated in Debug builds but not Release builds.
    public init(_ key: String,
                persistence: Persistence = .none,
                releaseLocked: Bool = false,
                default defaultValue: Default) {
        self.key = key
        self.persistence = persistence
        self.releaseLocked = releaseLocked
        self.defaultValue = defaultValue

        if persistence == .none, releaseLocked {
            fatalError("💥💥💥 Cannot set release lock on a read only settings '\(key)' 💥💥💥")
        }
    }
}
