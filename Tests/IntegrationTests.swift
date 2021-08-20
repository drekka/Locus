//
//  File.swift
//  File
//
//  Created by Derek Clarkson on 4/8/21.
//

import Locus
import XCTest
import Nimble

class IntegrationTests: XCTestCase {

    @Setting(key: "setting.int")
    var mySettingInt: Int

    @Setting(key: "setting.string")
    var mySettingString: String

    @Setting(key: "setting.unknown")
    var myUnknownSetting: Int

    @Setting(key: "setting.incorrect.type")
    var myIncorrectTypeSetting: Date

    override func setUp() {
        super.setUp()
        SettingsContainer.shared = SettingsContainer()
        SettingsContainer.shared.register {
            setting(withKey: "setting.int", default: 5)
            setting(withKey: "setting.string", default: "abc")
            setting(withKey: "setting.incorrect.type", default: 8)
        }
    }
    
    func testBaseAccessToSettings() {
        expect(self.mySettingInt) == 5
        expect(self.mySettingString) == "abc"
    }
    
    func testUnknownSettingFatals() {
        expect(self.myUnknownSetting).to(throwAssertion())
    }

    func testIncorrectTypeFatals() {
        expect(self.myIncorrectTypeSetting).to(throwAssertion())
    }

    func testSettingAReadonlyFatals() {
        expect(self.mySettingInt = 5).to(throwAssertion())
    }
}
