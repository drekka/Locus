//
//  File.swift
//  
//
//  Created by Derek Clarkson on 26/10/21.
//

/// Protocol applies to sources of settings configurations.
///
/// This allows the containers result builder to handle functions that build arrays of results.
public protocol SettingConfigurationSource {
    var builtSettings: [SettingConfiguration] { get }
}

/// Applies the `SettingConfigurationSource` to array's of setting configurations.
extension Array: SettingConfigurationSource where Element == SettingConfiguration {
    public var builtSettings:[SettingConfiguration] {
        self
    }
}

/// Used by the containers result builder to assemble a list of settings.
extension SettingConfiguration: SettingConfigurationSource {
    public var builtSettings:[SettingConfiguration] {
        [ self ]
    }
}

