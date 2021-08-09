//
//  File.swift
//  File
//
//  Created by Derek Clarkson on 26/7/21.
//

/// Scope of a setting.
///
/// By default a setting is readonly. However one or more of these flags may be set to change that behaviour.
public struct SettingAttributes: OptionSet {

    // Setting can be modified.
    public static let readonly = SettingAttributes(rawValue: 1 << 0)

    // Setting can be updated but any changes won't be remembered when app is shutdown.
    public static let transient = SettingAttributes(rawValue: 1 << 1)

    // Setting is stored in user defaults.
    public static let userDefaults = SettingAttributes(rawValue: 1 << 2)

    public let rawValue: Int

    public init(rawValue: Int) {
        self.rawValue = rawValue
    }
}
