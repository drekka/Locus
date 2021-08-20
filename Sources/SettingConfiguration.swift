//
//  File.swift
//  File
//
//  Created by Derek Clarkson on 26/7/21.
//

/// Creates a `SettingConfig`.
///
/// - parameter key: The key to register the config under.
/// - parameter scope: Specific features of the setting.
/// - parameter releaseLocked: If set to true, specifies that the setting can be updated in debug versions, but not release versions.
/// - parameter default: The default value for the setting.
/// - returns: A `SettingConfiguration`.
public func setting(withKey key: String,
                    scope: Scope = .readonly,
                    releaseLocked: Bool = false,
                    default: Any) -> SettingConfiguration {
    SettingConfiguration(withKey: key, scope: scope, releaseLocked: releaseLocked, default: `default`)
}

/// Defines the setup of a given setting.
public class SettingConfiguration {

    public let key: String
    public let scope: Scope
    public let releaseLocked: Bool

    /// The setting's default value.
    ///
    /// Loading a new value will change this.
    public var defaultValue: Any!

    /// Default initializer.
    ///
    /// - parameter key: The key to register the config under.
    /// - parameter scope: The scope of whether the setting can be updated.
    /// - parameter releaseLocked: If true, the setting cannot be updated in release builds.
    /// - parameter default: The default value for the setting.
    public init(withKey key: String,
                scope: Scope = .readonly,
                releaseLocked: Bool = false,
                default defaultValue: Any? = nil) {
        self.key = key
        self.scope = scope
        self.releaseLocked = releaseLocked
        self.defaultValue = defaultValue
        
        if scope == .readonly, releaseLocked {
            fatalError("💥💥💥 Release locked is not needed for read only settings 💥💥💥")
        }
    }
}
