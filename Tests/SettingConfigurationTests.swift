//
// Created by Derek Clarkson on 26/7/21.
//

import XCTest
import Locus
import Nimble

class SettingConfigurationTests: XCTestCase {
    
    func testInitializer() {
        let config = SettingConfiguration("abc", storage: .readonly, releaseLocked: false, default: 5)
        expect(config.key) == "abc"
        expect(config.storage) == .readonly
        expect(config.releaseLocked) == false
        expect(config.defaultValue as? Int) == 5
    }

    func testReadonlyAndReleaseLockedFatals() {
        expect(SettingConfiguration("abc", storage: .readonly, releaseLocked: true, default: 5)).to(throwAssertion())
    }
    
    // MARK; - Convenience functions.

    func testReadonlyConvenienceFunction() {
        let config = readonly("abc", default: 5)
        expect(config.key) == "abc"
        expect(config.storage) == .readonly
        expect(config.releaseLocked) == false
        expect(config.defaultValue as? Int) == 5
    }

    func testTransientConvenienceFunction() {
        let config = transient("abc", default: 5)
        expect(config.key) == "abc"
        expect(config.storage) == .transient
        expect(config.releaseLocked) == false
        expect(config.defaultValue as? Int) == 5
    }

    func testUserDefaultsConvenienceFunction() {
        let config = userDefault("abc", default: 5)
        expect(config.key) == "abc"
        expect(config.storage) == .userDefaults
        expect(config.releaseLocked) == false
        expect(config.defaultValue as? Int) == 5
    }

}
