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

class SettingsContainerTests: XCTestCase {

    private var mockStore: MockStore!

    override func setUp() {
        super.setUp()
        mockStore = MockStore()
        SettingsContainer.shared = SettingsContainer(stores: mockStore)
    }

    func testRegistering() {
        SettingsContainer.shared.register {
            transient("abc", default: "xyz")
        }
        expect(self.mockStore.registerConfiguration?.key) == "abc"
        expect(self.mockStore.registerConfiguration?.defaultValue as? String) == "xyz"
        expect(self.mockStore.registerConfiguration?.releaseLocked) == false
        expect(self.mockStore.registerConfiguration?.storage) == .transient
    }

    func testGettingValue() {
        mockStore.subscriptResult = "xyz"
        expect(SettingsContainer.shared["abc"] as String) == "xyz"
    }

    func testGettingValueViaEnum() {
        mockStore.subscriptResult = "xyz"
        expect(SettingsContainer.shared[Key.abc] as String) == "xyz"
    }

    func testSettingValue() {
        SettingsContainer.shared["abc"] = "xyz"
        expect(self.mockStore.subscriptKey) == "abc"
        expect(self.mockStore.subscriptValue as? String) == "xyz"
    }

    func testSettingValueViaEnum() {
        SettingsContainer.shared[Key.abc] = "xyz"
        expect(self.mockStore.subscriptKey) == "abc"
        expect(self.mockStore.subscriptValue as? String) == "xyz"
    }

    func testReadingDefaultValueSources() {

        let exp = expectation(description: "defaults")

        let valueSource = MockDefaultValueSource(defaults: [
            ("abc", "xyz"),
        ])
        var error: Error?
        SettingsContainer.shared.read(sources: valueSource) {
            error = $0
            exp.fulfill()
        }

        waitForExpectations(timeout: 5.0)

        expect(error) == nil
        expect(self.mockStore.setDefaultKey) == "abc"
        expect(self.mockStore.setDefaultValue as? String) == "xyz"
    }

    func testReadingDefaultValueSourcesReturnsErrorOnDataSourceError() {

        let exp = expectation(description: "defaults")

        let valueSource = MockDefaultValueSource(error: MockDefaultValueSourceError.anError)
        var error: Error?
        SettingsContainer.shared.read(sources: valueSource) {
            error = $0
            exp.fulfill()
        }

        waitForExpectations(timeout: 5.0)
        switch error {
        case .some(MockDefaultValueSourceError.anError): break // Good
        default: fail("Error not returned")
        }
    }
}
