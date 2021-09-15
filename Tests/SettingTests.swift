//
//  File.swift
//  File
//
//  Created by Derek Clarkson on 15/9/21.
//

import Locus
import Nimble
import XCTest

class SettingTests: XCTestCase {

    private var mockStore: MockStore!

    @Setting("abc")
    private var intValue: Int

    override func setUp() {
        super.setUp()
        mockStore = MockStore()
        SettingsContainer.shared = SettingsContainer(stores: mockStore)
        SettingsContainer.shared.register {
            transient("abc", default: 5)
        }
    }

    func testWrappedInitializerFatals() {
        expect(Setting(wrappedValue: 5, "abc")).to(throwAssertion())
    }

    func testGetsWrappedValueFromContainer() {
        expect(self.mockStore.registerConfiguration?.defaultValue as? Int) == 5
        mockStore.subscriptResult = 5
        expect(self.intValue) == 5
    }

    func testSetsValueInContainer() {
        intValue = 10
        expect(self.mockStore.subscriptKey) == "abc"
        expect(self.mockStore.subscriptValue as? Int) == 10
    }
}
