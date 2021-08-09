//
//  File.swift
//  
//
//  Created by Derek Clarkson on 11/7/21.
//
/// Provides semantic version numbers.
public struct Version: Equatable, Comparable, Codable {
    
    let major: Int
    let minor: Int
    let patch: Int
    
    public init(_ major: Int, _ minor: Int, _ patch: Int) {
        self.major = major
        self.minor = minor
        self.patch = patch
    }
    
    public static func < (lhs: Version, rhs: Version) -> Bool {
        return lhs.major < rhs.major
        || lhs.minor < rhs.minor
        || lhs.patch < rhs.patch
    }

    public static func == (lhs: Version, rhs: Version) -> Bool {
        return lhs.major == rhs.major
        && lhs.minor == rhs.minor
        && lhs.patch == rhs.patch
    }
}
