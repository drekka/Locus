//
//  File.swift
//  File
//
//  Created by Derek Clarkson on 15/9/21.
//

import Locus
import Nimble
import XCTest

private enum Key: String {
    case abc
}

class SettingTests: XCTestCase {

    private var mockStore: MockStore!

    @Setting("abc")
    private var intValue: Int

    @Setting(Key.abc)
    private var intValueViaEnum: Int

    @Setting("abc", container: SettingsContainer.shared)
    private var intValueWithContainer: Int

    @Setting(Key.abc, container: SettingsContainer.shared)
    private var intValueViaEnumWithContainer: Int

    override func setUp() {
        super.setUp()
        mockStore = MockStore()
        SettingsContainer.shared = SettingsContainer(stores: mockStore)
        SettingsContainer.shared.register {
            transient("abc", default: .static(5))
        }
    }
    
    // MARK: - Getting and setting
    
    func testGetsWrappedValue() {
        expect(self.intValue) == 5
    }

    func testGetsWrappedValueWithContainer() {
        expect(self.intValueWithContainer) == 5
    }

    func testGetsWrappedValueViaEnum() {
        expect(self.intValueViaEnum) == 5
    }

    func testGetsWrappedValueViaEnumWithContainer() {
        expect(self.intValueViaEnumWithContainer) == 5
    }

    func testSetsValue() {
        intValue = 10
        expect(self.mockStore.values["abc"] as? Int) == 10
    }

    func testSetsValueWithContainer() {
        intValueWithContainer = 10
        expect(self.mockStore.values["abc"] as? Int) == 10
    }


    func testSetsValueViaEnum() {
        intValueViaEnum = 10
        expect(self.mockStore.values["abc"] as? Int) == 10
    }
    func testSetsValueViaEnumWithContainer() {
        intValueViaEnumWithContainer = 10
        expect(self.mockStore.values["abc"] as? Int) == 10
    }
}
