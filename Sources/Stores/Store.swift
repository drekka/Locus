//
//  File.swift
//
//
//  Created by Derek Clarkson on 18/7/21.
//

/// Defines the features of every type of store used to source and save a setting's value.
public protocol Store: AnyObject {

    /// The value for the setting.
    var value: Any { get set }

    /// Stores a new default value.
    func setDefault(_ value: Any)
}
