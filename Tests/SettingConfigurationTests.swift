////
////  File.swift
////  File
////
////  Created by Derek Clarkson on 26/7/21.
////

import XCTest
import Locus
import Nimble

class SettingConfigTests: XCTestCase {
    
    func testInitializer() {
        let config = SettingConfiguration(withKey: "abc", scope: .readonly, releaseLocked: false, default: 5)
        expect(config.key) == "abc"
        expect(config.scope) == .readonly
        expect(config.releaseLocked) == false
        expect(config.defaultValue as? Int) == 5
    }

    func testConvenienceFunction() {
        let config = setting(withKey: "abc", scope: .readonly, releaseLocked: false, default: 5)
        expect(config.key) == "abc"
        expect(config.scope) == .readonly
        expect(config.releaseLocked) == false
        expect(config.defaultValue as? Int) == 5
    }

    func testInvalidArgumentCombination() {
        expect(SettingConfiguration(withKey: "abc", scope: .readonly, releaseLocked: true, default: 5)).to(throwAssertion())
    }

}
