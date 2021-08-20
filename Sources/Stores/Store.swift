//
//  File.swift
//
//
//  Created by Derek Clarkson on 18/7/21.
//

/// Defines the features of every type of store used to source and save a setting's value.
public protocol Store {
    
    /// Registers a key, it's attributes and default value.
    ///
    /// - parameter configuration: The configuration of the new setting.
    func register(configuration: SettingConfiguration)

    /// Returns the configuration of a setting.
    ///
    /// - parameter key: The key of the setting.
    /// - returns: The setting's configuration.
    func configuration(forKey key: String) -> SettingConfiguration

    /// Sets the default value for a key.
    ///
    /// - parameter key: The key of the setting.
    /// - parameter value: The new value.
    func setDefault<T>(_ value: T, forKey key: String)
    
    /// Removes the current value of a key.
    ///
    /// - parameter key: The key of the setting.
    func remove(key: String)

    /// Subscript access to the value of a setting.
    subscript<T>(key: String) -> T { get set }
}
