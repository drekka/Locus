//
//  File.swift
//  File
//
//  Created by Derek Clarkson on 15/9/21.
//

import Locus
import Nimble
import XCTest
import Combine

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
        expect(self.mockStore.configurations.count) == 1
        expect(self.mockStore.configurations["abc"]) != nil
    }

    func testGettingValue() {
        mockStore.values["abc"] = "xyz"
        expect(SettingsContainer.shared["abc"] as String) == "xyz"
    }

    func testGettingValueViaEnum() {
        mockStore.values["abc"] = "xyz"
        expect(SettingsContainer.shared[Key.abc] as String) == "xyz"
    }

    func testSettingValue() {
        SettingsContainer.shared["abc"] = "xyz"
        expect(self.mockStore.values.count) == 1
        expect(self.mockStore.values["abc"] as? String) == "xyz"
    }

    func testSettingValueViaEnum() {
        SettingsContainer.shared[Key.abc] = "xyz"
        expect(self.mockStore.values.count) == 1
        expect(self.mockStore.values["abc"] as? String) == "xyz"
    }
    
    // MARK: - Combine updates
    
    func testCombineUpdates() {


        var update: DefaultValueUpdate?
        let cancellable = SettingsContainer.shared.defaultValueUpdates
            .filter { $0.key == "abc" }
            .sink { update = $0 }
        
        let exp = expectation(description: "defaults")
        withExtendedLifetime(cancellable) {
            let valueSource = MockDefaultValueSource(name: "Source", defaults: ["abc": "xyz"])
            SettingsContainer.shared.read(sources: valueSource) { error in
                expect(error) == nil
                exp.fulfill()
            }
        }
        
        waitForExpectations(timeout: 5.0)
        
        expect(update?.key) == "abc"
        expect(update?.value as? String) == "xyz"
    }
    
    // MARK: - Default value sources

    func testReadingDefaultValueSources() {

        let exp = expectation(description: "defaults")

        let valueSource = MockDefaultValueSource(name: "Source", defaults: ["abc": "xyz"])
        var error: Error?
        SettingsContainer.shared.read(sources: valueSource) {
            error = $0
            exp.fulfill()
        }

        waitForExpectations(timeout: 5.0)

        expect(error) == nil
        expect(self.mockStore.defaults.count) == 1
        expect(self.mockStore.defaults["abc"] as? String) == "xyz"
    }

    func testReadingDefaultValueSourcesReturnsErrorOnDataSourceError() {

        let exp = expectation(description: "defaults")

        let valueSource = MockDefaultValueSource(name: "Source", error: MockDefaultValueSourceError.anError)
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
    
    func testReadingMultipleDefaultValueSources() {
        SettingsContainer.shared.register {
            transient("abc", default: 0)
        }

        var log: [(TimeInterval, String)] = []
        
        log.append((Date.now.timeIntervalSince1970, "Initing s1"))
        let source1 = MockDefaultValueSource(name: "s1", defaults: ["abc": 5])
        log.append((Date.now.timeIntervalSince1970, "Initing s2"))
        let source2 = MockDefaultValueSource(name: "s2", defaults: ["abc": 15])
        log.append((Date.now.timeIntervalSince1970, "Initing s3"))
        let source3 = MockDefaultValueSource(name: "s3", defaults: ["abc": 25])

        let exp = expectation(description: "logs")
        log.append((Date.now.timeIntervalSince1970, "Reading sources"))
        SettingsContainer.shared.read(sources: source1, source2, source3) { error in
            log.append((Date.now.timeIntervalSince1970, "Sources read"))
            exp.fulfill()
        }
        log.append((Date.now.timeIntervalSince1970, "Reading done"))

        waitForExpectations(timeout: 5.0)
        
        let mergedLog = (source1.log + log + source3.log + source2.log).sorted { $0.0 < $1.0 }.map { $0.1 }
        expect(mergedLog) == [
            "Initing s1",
            "Initing s2",
            "Initing s3",
            "Reading sources",
            "Reading done", // This appearing before the reading proves the multithreading.
            "s1 reading",
            "s1 returning values",
            "s2 reading",
            "s2 returning values",
            "s3 reading",
            "s3 returning values",
            "Sources read"
        ]
        
        
    }
}
