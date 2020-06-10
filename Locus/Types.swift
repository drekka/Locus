//
//  Types.swift
//  locus
//
//  Created by Derek Clarkson on 29/5/20.
//  Copyright © 2020 Derek Clarkson. All rights reserved.
//

/// Defines an enum that is used to provide the keus for settings.
//public typealias SettingsKey = String

public protocol SettingsKey: RawRepresentable where RawValue == String {}

