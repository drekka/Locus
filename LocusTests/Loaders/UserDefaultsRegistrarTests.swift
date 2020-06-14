//
//  UserDefaultsRegistrarTests.swift
//  LocusTests
//
//  Created by Derek Clarkson on 14/6/20.
//  Copyright © 2020 Derek Clarkson. All rights reserved.
//

import XCTest
@testable import Locus
import Nimble

class UserDefaultsRegistrarTests: XCTestCase {

    private var registrar: UserDefaultsRegistrar!

    override func setUp() {
        super.setUp()
        if let appDomain = Bundle.main.bundleIdentifier {
            UserDefaults.standard.removePersistentDomain(forName: appDomain)
        }
        registrar = UserDefaultsRegistrar()
    }

    func testDoesNothingIfNothingFoundInBundle() {
        registrar.register()
        expect(UserDefaults.standard.object(forKey: "slider_preference")).to(beNil())
    }

    func testRegistering() {
        registrar.register(bundle: Bundle(for: UserDefaultsRegistrarTests.self))
        let defaults = UserDefaults.standard
        expect(defaults.float(forKey: "slider_preference")) == 0.5
        expect(defaults.string(forKey: "name_preference")) == "Hello"
        expect(defaults.bool(forKey: "enabled_preference")).to(beTrue())
        expect(defaults.float(forKey: "child.slider_preference")) == 123.456
        expect(defaults.string(forKey: "child.name_preference")) == "Hello from child"
        expect(defaults.bool(forKey: "child.enabled_preference")).to(beFalse())
    }

    func testDuplicateKeyFatals() {
        expect(self.registrar.register(bundle: Bundle(for: UserDefaultsRegistrarTests.self), rootPlistName: "DuplicateKey")).to(throwAssertion())
    }

}
