//
//  File.swift
//  File
//
//  Created by Derek Clarkson on 26/7/21.
//

/// Scope of a setting.
///
/// By default a setting is readonly. However these values allow a setting to be updated by specifiying where the updated values can be stored.
public enum Scope {

    // Default scope is that settings cannot be updated.
    case readonly

    // Setting updates are stored in a temporary in-memory store.
    case transient

    // Setting updates are stored in user defaults.
    case userDefaults
}
