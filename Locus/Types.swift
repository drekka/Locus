//
//  Types.swift
//  locus
//
//  Created by Derek Clarkson on 29/5/20.
//  Copyright © 2020 Derek Clarkson. All rights reserved.
//

/// Defines something that can be used as a key for a setting. Normally this would be an enum.
public protocol SettingsKey: RawRepresentable where RawValue == String {}

