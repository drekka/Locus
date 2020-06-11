//
//  TransientStoreTests.swift
//  LocusTests
//
//  Created by Derek Clarkson on 6/6/20.
//  Copyright © 2020 Derek Clarkson. All rights reserved.
//

import XCTest
@testable import Locus
import Nimble

class TransientStoreTests: XCTestCase {

    var store: Store<Int>!
    var parent: MockStore<Int>!

    override func setUp() {
        super.setUp()
        parent = MockStore(key: "abc", value: 5)
        store = TransientStore(parent: parent)
    }

    func testValue() {
        expect(self.store.value) == 5
    }

    func testStore() {
        store.store(newValue: 10)
        expect(self.parent.value) == 5
        expect(self.store.value) == 10
    }

    func testReset() {
        store.store(newValue: 10)
        store.reset()
        expect(self.parent.value) == 5
        expect(self.store.value) == 5
    }
}
