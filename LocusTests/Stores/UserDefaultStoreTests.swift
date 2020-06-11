//
//  UserDefaultStoreTests.swift
//  locusTests
//
//  Created by Derek Clarkson on 28/5/20.
//  Copyright © 2020 Derek Clarkson. All rights reserved.
//

import XCTest
import Nimble
@testable import Locus

class UserDefaultStoreTests: XCTestCase {

    var store: Store<Int>!
    var parent: MockStore<Int>!

    override func setUp() {
        super.setUp()
        UserDefaults.standard.removeObject(forKey: "abc")
        parent = MockStore(key: "abc", value: 5)
        store = UserDefaultsReadonlyStore(parent: parent)
    }

    func testReadonlyGetsDefault() {
        store = UserDefaultsReadonlyStore(parent: parent)
        expect(self.store.value) == 5
    }
    
    func testReadonlyGetsUserDefault() {
        store = UserDefaultsReadonlyStore(parent: parent)
        UserDefaults.standard.set(10, forKey: "abc")
        expect(self.store.value) == 10
    }

    func testReadonlyIgnoresWrongTypeUserDefault() {
        store = UserDefaultsReadonlyStore(parent: parent)
        UserDefaults.standard.set("def", forKey: "abc")
        expect(_ = self.store.value as Int).to(throwAssertion())
    }

    func testWritableStoresValueInUserDefaults() {
        store = UserDefaultsWritableStore(parent: parent)
        store.store(newValue: 10)
        expect(UserDefaults.standard.integer(forKey: "abc")) == 10
        expect(self.parent.value) == 5
    }

    func testReset() {
        store = UserDefaultsReadonlyStore(parent: parent)
        UserDefaults.standard.set(10, forKey: "abc")
        store.reset()
        expect(self.store.value) == 5
    }

}
