//
//  Created by Derek Clarkson on 1/8/21.
//

@testable import Locus
import Nimble
import XCTest

class DefaultStoreTests: XCTestCase {

    private var store: DefaultStore!

    override func setUp() {
        super.setUp()
        let intConfig = SettingConfiguration("abc", default: 5)
        store = DefaultStore()
        store.register(configuration: intConfig)
    }

    func testDuplicateRegister() {
        let stringConfig = SettingConfiguration("abc", default: "xyz")
        expect(self.store.register(configuration: stringConfig)).to(throwAssertion())
    }

    func testAccessingConfiguration() {
        expect(self.store.configuration(forKey: "abc")).toNot(throwAssertion())
    }

    func testAccessingConfiguartionForUnknownKeyFatals() {
        expect(_ = self.store.configuration(forKey: "xyz")).to(throwAssertion())
    }

    func testGettingAValue() {
        expect(self.store["abc"] as Int) == 5
    }

    func testGettingAValueForUnknownKeyFatals() {
        expect(_ = self.store["xyz"] as Int).to(throwAssertion())
    }

    func testStoringAValueFatals() {
        expect(self.store["abc"] = 1).to(throwAssertion())
    }

    func testRemovingAValueFatals() {
        expect(self.store.remove(key: "abc")).to(throwAssertion())
    }

    func testSetDefault() {
        store.setDefault(3, forKey: "abc")
        expect(self.store["abc"] as Int) == 3
    }
}
