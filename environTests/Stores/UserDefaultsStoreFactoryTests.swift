//
//  UserDefaultsStoreFactoryTests.swift
//  EnvironTests
//
//  Created by Derek Clarkson on 7/6/20.
//  Copyright © 2020 Derek Clarkson. All rights reserved.
//

import XCTest
@testable import Environ
import Nimble

class UserDefaultsStoreFactoryTests: XCTestCase {

    let factory = UserDefaultsStoreFactory()
    let parent = MockStore<Int>(key: "abc", value: 5)

    func testCreateStoreWithReadonlyScope() {
        let store = factory.createStore(scope: .readonly, parent: parent)
        expect(store).to(beAKindOf(UserDefaultsReadonlyStore<Int>.self))
    }

    func testCreateStoreWithWritableScope() {
        let store = factory.createStore(scope: .writable, parent: parent)
        expect(store).to(beAKindOf(UserDefaultsWritableStore<Int>.self))
    }

    func testCreateStoreWithReleaseLockedScope() {
        let store = factory.createStore(scope: .releaseLocked, parent: parent)
        expect(store) === parent
    }

    func testCreateStoreWithTransientScope() {
        let store = factory.createStore(scope: .transient, parent: parent)
        expect(store) === parent
    }
}
