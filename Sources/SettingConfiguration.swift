//
//  Created by Derek Clarkson on 26/7/21.
//

/// Creates a "read only" setting configuration.
///
/// Readonly settings cannot be updated by the app.
///
/// - parameter key: The key to register the config under.
/// - parameter default: The default value for the setting. If the setting matches a preference with a default value, then you don't need to specifiy it here as long as your run the `SettingBundleDefaultValueSource`.
/// - returns: A `SettingConfiguration`.
public func readonly(_ key: String, default: Any? = nil) -> SettingConfiguration {
    SettingConfiguration(key, default: `default`)
}

/// Creates a transient setting configuration.
///
/// Transient settings can be updated, but the updated values are stored in memory and not saved if the app is shutdown.
///
/// - parameter key: The key to register the config under.
/// - parameter releaseLocked: If set to true, specifies that the setting can be updated in debug builds, but not release builds.
/// - parameter default: The default value for the setting. If the setting matches a preference with a default value, then you don't need to specifiy it here as long as your run the `SettingBundleDefaultValueSource`.
/// - returns: A `SettingConfiguration`.
public func transient(_ key: String, releaseLocked: Bool = false, default: Any? = nil) -> SettingConfiguration {
    SettingConfiguration(key, storage: .transient, releaseLocked: releaseLocked, default: `default`)
}

/// Creates a setting which stores updates in `UserDefaults`.
///
/// - parameter key: The key to register the config under.
/// - parameter releaseLocked: If set to true, specifies that the setting can be updated in debug versions, but not release versions.
/// - parameter default: The default value for the setting. If the setting matches a preference with a default value, then you don't need to specifiy it here as long as your run the `SettingBundleDefaultValueSource`.
/// - returns: A `SettingConfiguration`.
public func userDefault(_ key: String, releaseLocked: Bool = false, default: Any? = nil) -> SettingConfiguration {
    SettingConfiguration(key, storage: .userDefaults, releaseLocked: releaseLocked, default: `default`)
}

/// Defines the setup of a given setting.
public class SettingConfiguration {

    public let key: String
    public let storage: Storage
    public let releaseLocked: Bool

    /// The setting's default value.
    ///
    /// Loading a new value will change this.
    public var defaultValue: Any!

    /// Default initializer.
    ///
    /// - parameter key: The key to register the config under.
    /// - parameter storage: The storage of whether the setting can be updated.
    /// - parameter releaseLocked: If true, the setting cannot be updated in release builds.
    /// - parameter default: The default value for the setting.
    public init(_ key: String,
                storage: Storage = .readonly,
                releaseLocked: Bool = false,
                default defaultValue: Any? = nil) {
        self.key = key
        self.storage = storage
        self.releaseLocked = releaseLocked
        self.defaultValue = defaultValue

        if storage == .readonly, releaseLocked {
            fatalError("💥💥💥 Release locked is not needed for read only settings 💥💥💥")
        }
    }
}
