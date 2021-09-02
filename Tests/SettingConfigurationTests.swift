//
// Created by Derek Clarkson on 26/7/21.
//

import XCTest
import Locus
import Nimble

class SettingConfigTests: XCTestCase {
    
    func testInitializer() {
        let config = SettingConfiguration("abc", storage: .readonly, releaseLocked: false, default: 5)
        expect(config.key) == "abc"
        expect(config.storage) == .readonly
        expect(config.releaseLocked) == false
        expect(config.defaultValue as? Int) == 5
    }

    func testReadonlyConvenienceFunction() {
        let config = readonly("abc", default: 5)
        expect(config.key) == "abc"
        expect(config.storage) == .readonly
        expect(config.releaseLocked) == false
        expect(config.defaultValue as? Int) == 5
    }

    func testInvalidArgumentCombination() {
        expect(SettingConfiguration("abc", storage: .readonly, releaseLocked: true, default: 5)).to(throwAssertion())
    }

}
