//
//  SettingsTests.swift
//  LocusTests
//
//  Created by Derek Clarkson on 7/6/20.
//  Copyright © 2020 Derek Clarkson. All rights reserved.
//

import XCTest
@testable import Locus
import Nimble

class LocusContainerTests: XCTestCase {

    private var settings: SettingsContainer!

    override func setUp() {
        super.setUp()
        settings = LocusContainer(storeFactories: [MockStoreFactory()])
    }

    func testSingletonAccess() {
        expect(LocusContainer.shared).toNot(beNil())
        }

    func testDuplicationRegistrationThrows() {
        LocusContainer.shared.register(key: "abc", defaultValue: 5)
        expect(LocusContainer.shared.register(key: "abc", defaultValue: "def")).to(throwAssertion())
    }

    func testResolve() {
        settings.register(key: "abc", scope: .readonly, defaultValue: 5)
        let result:Int = settings.resolve("abc")
        expect(result) == 5
    }

    func testResolveCastFailure() {
        settings.register(key: "abc", scope: .readonly, defaultValue: 5)
        expect(_ = self.settings.resolve("abc") as String).to(throwAssertion())
    }

    func testResolveUnknownKeyFailure() {
        expect(_ = self.settings.resolve("abc") as String).to(throwAssertion())
    }

    func testSet() {
        settings.register(key: "abc", scope: .writable, defaultValue: 5)
        settings.store(key: "abc", value: 10)
        let result:Int = settings.resolve("abc")
        expect(result) == 10
    }
}
