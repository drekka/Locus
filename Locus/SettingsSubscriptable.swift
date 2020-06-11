//
//  SettingsSubscriptable.swift
//  Locus
//
//  Created by Derek Clarkson on 9/6/20.
//  Copyright © 2020 Derek Clarkson. All rights reserved.
//

/// Enables a container to use subscripting to access setting values.
public protocol SettingsSubscriptable {

    /**
     Sets or returns the value for a setting.

     - parameter key: The key of the setting.
     - returns: The value for the setting.
     */
    subscript<T>(_ key:String) -> T { get set }

    /**
     Sets or returns the value for a setting.

     This form takes a key that conforms to the RawRepresentable protocol. Normally this would be an enum of settings keys.

     - parameter key: The key of the setting.
     - returns: The value for the setting.
     */
    subscript<K, T>(_ Key: K) -> T where K: RawRepresentable, K.RawValue == String { get set }
}
