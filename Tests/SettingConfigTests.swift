////
////  File.swift
////  File
////
////  Created by Derek Clarkson on 26/7/21.
////
//
//import XCTest
//import Locus
//import Nimble
//
//class SettingConfigTests: XCTestCase {
//    
//    let truthTable: [(SettingAttributes, SettingAttributes, Bool)] = [
//        (.writable, .debug, true),
//        (.writable, .transient, true),
//        (.writable, .releaseLocked, true),
//        (.debug, .transient, true),
//        (.debug, .releaseLocked, false),
//        (.transient, .releaseLocked, true),
//    ]
//
//    func testCombinations() {
//        truthTable.forEach { combination in
//            if combination.2 {
//                expect(SettingConfig(withKey: "Abc", attributes:[combination.0, combination.1])).toNot(throwAssertion())
//            } else {
//                expect(SettingConfig(withKey: "Abc", attributes:[combination.0, combination.1])).to(throwAssertion())
//            }
//        }
//    }
//    
//    func testSubset() {
//        expect(SettingConfig(withKey: "Abc", attributes:[.writable, .debug, .transient])).toNot(throwAssertion())
//        expect(SettingConfig(withKey: "Abc", attributes:[.writable, .debug, .transient, .releaseLocked])).to(throwAssertion())
//    }
//
//}
