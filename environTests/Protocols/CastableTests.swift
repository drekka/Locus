//
//  CastableTests.swift
//  EnvironTests
//
//  Created by Derek Clarkson on 3/6/20.
//  Copyright © 2020 Derek Clarkson. All rights reserved.
//

import XCTest
@testable import Environ
import Nimble

class CastableTests: XCTestCase, Castable {

    func testCast() {
        expect(self.cast("def", forKey: "key") as String) == "def"
        expect(self.cast(5, forKey: "key") as Int) == 5
    }

    func testCastFailure() {
        expect { _ = self.cast("def", forKey: "key") as Int }.to(throwAssertion())
    }
}
