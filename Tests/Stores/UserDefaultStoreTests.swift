//
//  File.swift
//  File
//
//  Created by Derek Clarkson on 1/8/21.
//

import Locus
import Nimble
import XCTest

// Use this mock because sunchronisation of user defaults is unreliable.
class MockDefaults: Defaults {
    var registerDefaults: [String: Any]?
    func register(defaults: [String: Any]) {
        registerDefaults = defaults
    }

    var removeObjectForKey: String?
    func removeObject(forKey: String) {
        removeObjectForKey = forKey
    }

    var valueForKey: String?
    var valueForKeyResult: Any?
    func value(forKey: String) -> Any? {
        valueForKey = forKey
        return valueForKeyResult
    }

    var setForKey: String?
    var setValue: Any?
    func set(_ value: Any?, forKey: String) {
        setForKey = forKey
        setValue = value
    }
}

class UserDefaultsStoreTests: XCTestCase {

    private let key = "__testKey"

    private var store: UserDefaultsStore!
    private var mockStore: MockStore!
    private var mockDefaults: MockDefaults!

    override func setUp() {
        super.setUp()

        mockStore = MockStore()
        mockDefaults = MockDefaults()
        store = UserDefaultsStore(parent: mockStore, defaults: mockDefaults)
    }

    func testRegisterPassesThrough() {
        let configuration = SettingConfiguration(key, storage: .userDefaults, default: 5)
        store.register(configuration: configuration)
        expect(self.mockStore.registerConfiguration) === configuration
    }

    func testConfigurationPassesThrough() {
        let configuration = SettingConfiguration(key, storage: .userDefaults)
        mockStore.configurationResult = configuration
        let returnedConfiguration = store.configuration(forKey: key)
        expect(returnedConfiguration) === configuration
    }

    func testSetDefaultRegistersInUserDefaults() {
        mockStore.configurationResult = SettingConfiguration(key, storage: .userDefaults)

        store.setDefault(10, forKey: key)
        expect(self.mockDefaults.registerDefaults?[self.key] as? Int) == 10
        expect(self.mockStore.setDefaultKey) == nil
    }

    func testSetDefaultPassesThroughWhenNotAUserDefaultsSetting() {
        mockStore.configurationResult = SettingConfiguration(key)

        store.setDefault(10, forKey: key)
        expect(self.mockDefaults.registerDefaults) == nil
        expect(self.mockStore.setDefaultKey) == key
        expect(self.mockStore.setDefaultValue as? Int) == 10
    }

    func testRemoveClearsStoredValue() {
        mockStore.configurationResult = SettingConfiguration(key, storage: .userDefaults)

        store.remove(key: key)
        expect(self.mockDefaults.removeObjectForKey) == key
    }

    func testRemovePassesThroughWhenNotAUserDefaultsSetting() {
        mockStore.configurationResult = SettingConfiguration(key)

        store.remove(key: key)
        expect(self.mockDefaults.removeObjectForKey) == nil
        expect(self.mockStore.removeKey) == key
    }

    func testGetReadsUserDefaults() {
        mockStore.configurationResult = SettingConfiguration(key, storage: .userDefaults)
        mockDefaults.valueForKeyResult = 10

        let value: Int = store[key]

        expect(self.mockDefaults.valueForKey) == key
        expect(value) == 10
    }

    func testGetPassesThroughWhenNotAUserDefaultsSetting() {
        mockStore.configurationResult = SettingConfiguration(key)
        mockStore.subscriptResult = 10

        let value: Int = store[key]

        expect(self.mockDefaults.valueForKey) == nil
        expect(value) == 10
    }

    func testGetPassesThroughWhenNoValueFound() {
        mockStore.configurationResult = SettingConfiguration(key, storage: .userDefaults)
        mockStore.subscriptResult = 10

        let value: Int = store[key]

        expect(value) == 10
        expect(self.mockStore.subscriptKey) == key
    }

    func testSetStoresInUserDefaults() {
        mockStore.configurationResult = SettingConfiguration(key, storage: .userDefaults)

        store[key] = 10
        expect(self.mockDefaults.setValue as? Int) == 10
        expect(self.mockDefaults.setForKey) == key
    }

    func testSetPassesThroughWhenNotAUserDefaultSetting() {
        mockStore.configurationResult = SettingConfiguration(key)

        store[key] = 10
        expect(self.mockDefaults.setValue) == nil
        expect(self.mockDefaults.setForKey) == nil
        expect(self.mockStore.subscriptValue as? Int) == 10
        expect(self.mockStore.subscriptKey) == key
    }
}
