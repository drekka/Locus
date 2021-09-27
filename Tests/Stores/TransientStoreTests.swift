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

    private var mockParentStore: MockStore!
    private var transientStore: TransientStore!
    private var transient: SettingConfiguration!
    private var nonTransient: SettingConfiguration!

    override func setUp() {
        super.setUp()
        mockParentStore = MockStore()
        transient = SettingConfiguration("transient", storage: .transient, default: 5)
        nonTransient = SettingConfiguration("non-transient", default: 10)

        transientStore = TransientStore(parent: mockParentStore)

        transientStore.register(configuration: transient)
        transientStore.register(configuration: nonTransient)
    }

    func testConfigurationPassesThrough() {
        expect(self.transientStore.configuration(forKey: "transient")) === transient
        expect(self.transientStore.configuration(forKey: "non-transient")) === nonTransient
    }

    func testSetDefault() {
        transientStore.setDefault(50, forKey: "transient")
        transientStore.setDefault(150, forKey: "non-transient")
        expect(self.mockParentStore.defaults["transient"] as? Int) == 50
        expect(self.mockParentStore.defaults["non-transient"] as? Int) == 150
        expect(self.transientStore["transient"] as Int?) == 50
        expect(self.transientStore["non-transient"] as Int?) == 150
    }

    func testRemove() {
        mockParentStore.values["non-transient"] = 200
        transientStore["transient"] = 500
        expect(self.transientStore["transient"] as Int?) == 500
        expect(self.transientStore["non-transient"] as Int?) == 200

        transientStore.remove(key: "transient")
        transientStore.remove(key: "non-transient")

        expect(self.mockParentStore.values.count) == 0
        expect(self.transientStore["transient"] as Int?) == 5
        expect(self.transientStore["non-transient"] as Int?) == 10
    }

    func testGet() {
        transientStore["transient"] = 200
        expect(self.transientStore["transient"] as Int?) == 200
        expect(self.transientStore["non-transient"] as Int?) == 10
    }

    func testSet() {
        transientStore["transient"] = 100
        transientStore["non-transient"] = 200

        expect(self.transientStore["transient"] as Int?) == 100
        expect(self.transientStore["non-transient"] as Int?) == 200
    }
}
