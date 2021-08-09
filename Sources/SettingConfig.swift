//
//  File.swift
//  File
//
//  Created by Derek Clarkson on 26/7/21.
//

/// Creates a `SettingConfig`.
///
/// - parameter key: The key to register the config under.
/// - parameter attributes: Specific features of the setting.
/// - parameter default: The default value for the setting.
/// - returns: A `SettingConfig`.
public func setting(withKey key: String, attributes: SettingAttributes = [], default: Any) -> SettingConfig {
    SettingConfig(withKey: key, attributes: attributes, default: `default`)
}

/// Defines the setup of a given setting.
public struct SettingConfig {

    /// The key  of the setting.
    let key: String

    /// Specific features.
    let attributes: SettingAttributes

    /// The setting's default value.
    let defaultValue: Any

    /// Default initializer.
    ///
    /// - parameter key: The key to register the config under.
    /// - parameter attributes: Specific features of the setting.
    /// - parameter default: The default value for the setting.
    public init(withKey key: String, attributes: SettingAttributes = [], default: Any) {
        self.key = key
        self.attributes = attributes
        defaultValue = `default`

        if attributes.isSuperset(of: [.transient, .readonly]) {
            fatalError("💥💥💥 Invalid attributes, a setting cannot be both transient and readonly 💥💥💥")
        }
    }
}
