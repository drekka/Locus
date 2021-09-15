//
//  File.swift
//  File
//
//  Created by Derek Clarkson on 15/9/21.
//

@testable import Locus
import Nimble
import XCTest

class ValueCastableTests: XCTestCase, ValueCastable {

    func testCasting() {
        let value: Any = "123"
        expect(self.cast(value, forKey: "abc") as String) == "123"
    }

    func testCastingStringToURL() {
        let value: Any = "http://abc.com"
        expect((self.cast(value, forKey: "abc") as URL).absoluteString) == "http://abc.com"
    }

    func testCastingFailure() {
        let value: Any = 123
        expect(self.cast(value, forKey: "abc") as String).to(throwAssertion())
    }
}
