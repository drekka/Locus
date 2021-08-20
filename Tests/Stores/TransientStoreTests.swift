//
//  File.swift
//
//
//  Created by Derek Clarkson on 18/7/21.
//

import Locus
import Nimble
import XCTest

class TransientStoreTests: XCTestCase {

    private var mockParent: MockStore!
    private var transientStore: TransientStore!

    override func setUp() {
        super.setUp()
        mockParent = MockStore()
        transientStore = TransientStore(parent: mockParent)
    }

    func testRegisterPassesThrough() {
        let configuration = SettingConfiguration(withKey: "abc", default: 5)
        transientStore.register(configuration: configuration)
        expect(self.mockParent.registerConfiguration) === configuration
    }

    func testConfigurationPassesThrough() {
        mockParent.configurationResult = SettingConfiguration(withKey: "abc", default: 5)

        let configuration = transientStore.configuration(forKey: "abc")
        expect(self.mockParent.configurationKey) == "abc"
        expect(configuration.key) == "abc"
    }

    func testSetDefaultPassesThrough() {
        transientStore.setDefault(5, forKey: "abc")
        expect(self.mockParent.setDefaultKey) == "abc"
        expect(self.mockParent.setDefaultValue as? Int) == 5
    }

    func testRemovePassesThroughWhenNotTransient() {
        mockParent.configurationResult = SettingConfiguration(withKey: "abc", default: 5)
        transientStore.remove(key: "abc")
        expect(self.mockParent.removeKey) == "abc"
    }

    func testRemoveClearsTransientValue() {

        mockParent.configurationResult = SettingConfiguration(withKey: "abc", scope: .transient, default: 5)
        transientStore["abc"] = 10

        // Remove
        transientStore.remove(key: "abc")
        expect(self.mockParent.removeKey) == nil
        expect(self.mockParent.subscriptKey) == nil

        // Verify transient value is gone by accessing value from parent.
        mockParent.subscriptResult = 3
        expect(self.transientStore["abc"] as Int) == 3
        expect(self.mockParent.removeKey) == nil
        expect(self.mockParent.subscriptKey) == "abc"
    }

    func testGetReturnsParentValueWhenNotTransient() {
        mockParent.subscriptResult = 5

        expect(self.transientStore["abc"] as Int) == 5
        expect(self.mockParent.subscriptKey) == "abc"
    }

    func testGetReturnsTransientValue() {
        mockParent.configurationResult = SettingConfiguration(withKey: "abc", scope: .transient, default: 5)
        transientStore["abc"] = 10
        
        expect(self.transientStore["abc"] as Int) == 10
        expect(self.mockParent.subscriptKey) == nil
    }

    func testGetReturnsParentValue() {
        mockParent.configurationResult = SettingConfiguration(withKey: "abc", scope: .transient, default: 5)
        mockParent.subscriptResult = 5
        
        expect(self.transientStore["abc"] as Int) == 5
        expect(self.mockParent.subscriptKey) == "abc"
    }

    func testSetPasseThroughWhenNotTransient() {
        mockParent.configurationResult = SettingConfiguration(withKey: "abc", default: 5)
        
        transientStore["abc"] = 10
        expect(self.mockParent.subscriptKey) == "abc"
        expect(self.mockParent.subscriptValue as? Int) == 10
    }

    func testSetStoresValueWhenTransient() {
        mockParent.configurationResult = SettingConfiguration(withKey: "abc", scope: .transient, default: 5)
        
        transientStore["abc"] = 10
        expect(self.transientStore["abc"] as Int) == 10
        expect(self.mockParent.subscriptKey) == nil
        expect(self.mockParent.subscriptValue) == nil
    }
}
