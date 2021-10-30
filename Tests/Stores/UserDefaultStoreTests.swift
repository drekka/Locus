//
//  File.swift
//  File
//
//  Created by Derek Clarkson on 1/8/21.
//

import Locus
import Nimble
import XCTest

class UserDefaultsStoreTests: XCTestCase {

    private let key = "__testKey"

    private var userDefaultsStore: UserDefaultsStore!
    private var mockParentStore: MockStore!
    private var mockUserDefaults: MockUserDefaults!

    override func setUp() {
        super.setUp()

        mockParentStore = MockStore()
        mockUserDefaults = MockUserDefaults()
        userDefaultsStore = UserDefaultsStore(parent: mockParentStore, defaults: mockUserDefaults)
    }

    func testRegisterPassesThrough() {
        let configuration = SettingConfiguration(key, persistence: .userDefaults, default: .local(5))

        userDefaultsStore.register(configuration: configuration)

        expect(self.mockParentStore.configurations.count) == 1
        expect(self.mockParentStore.configurations[self.key]) === configuration
    }

    func testConfigurationPassesThrough() {
        let configuration = SettingConfiguration(key, persistence: .userDefaults, default: .userDefaults)
        mockParentStore.configurations[key] = configuration

        let returnedConfiguration = userDefaultsStore.configuration(forKey: key)

        expect(returnedConfiguration) === configuration
    }

    func testSetDefaultRegistersInUserDefaults() {
        mockParentStore.configurations[key] = SettingConfiguration(key, persistence: .userDefaults, default: .userDefaults)

        userDefaultsStore.setDefault(10, forKey: key)

        expect(self.mockUserDefaults.registeredDefaults[self.key] as? Int) == 10
        expect(self.mockUserDefaults.defaults.count) == 0
    }

    func testSetDefaultPassesThroughWhenNotAUserDefaultsSetting() {
        mockParentStore.configurations[key] = SettingConfiguration(key, default: .local(5))

        userDefaultsStore.setDefault(10, forKey: key)

        expect(self.mockUserDefaults.defaults.count) == 0
        expect(self.mockParentStore.defaults[self.key] as? Int) == 10
    }

    func testRemoveClearsStoredValue() {
        mockParentStore.configurations[key] = SettingConfiguration(key, persistence: .userDefaults, default: .local(5))
        mockUserDefaults.defaults[key] = 10

        userDefaultsStore.remove(key: key)

        expect(self.mockUserDefaults.defaults.count) == 0
    }

    func testRemovePassesThroughWhenNotAUserDefaultsSetting() {
        mockParentStore.configurations[key] = SettingConfiguration(key, default: .local(5))
        mockParentStore.values[key] = "xyz"

        userDefaultsStore.remove(key: key)

        expect(self.mockParentStore.values.count) == 0
    }

    func testGetReadsUserDefaults() {
        mockParentStore.configurations[key] = SettingConfiguration(key, persistence: .userDefaults, default: .local(5))
        mockUserDefaults.defaults[key] = 10

        expect(self.userDefaultsStore[self.key] as Int) == 10
    }

    func testGetPassesThroughWhenNotAUserDefaultsSetting() {
        mockParentStore.configurations[key] = SettingConfiguration(key, default: .local(5))
        mockParentStore.defaults[key] = 10

        expect(self.userDefaultsStore[self.key] as Int) == 10
    }

    func testGetPassesThroughWhenNoValueFound() {
        mockParentStore.configurations[key] = SettingConfiguration(key, persistence: .userDefaults, default: .local(5))
        mockParentStore.defaults[key] = 10

        expect(self.userDefaultsStore[self.key] as Int) == 10
    }

    func testSetStoresInUserDefaults() {
        mockParentStore.configurations[key] = SettingConfiguration(key, persistence: .userDefaults, default: .local(5))

        userDefaultsStore[key] = 10

        expect(self.mockUserDefaults.defaults[self.key] as? Int) == 10
    }

    func testSetPassesThroughWhenNotAUserDefaultSetting() {
        mockParentStore.configurations[key] = SettingConfiguration(key, default: .local(5))

        userDefaultsStore[key] = 10

        expect(self.mockUserDefaults.defaults.count) == 0
        expect(self.mockParentStore.values[self.key] as? Int) == 10
    }
}
