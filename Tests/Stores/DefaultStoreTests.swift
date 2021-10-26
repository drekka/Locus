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
        let intConfig = SettingConfiguration("abc", default: .static(5))
        let userDefaultsConfig = SettingConfiguration("userDefault", default: .userDefaults)
        store = DefaultStore()
        store.register(configuration: intConfig)
        store.register(configuration: userDefaultsConfig)
    }

    func testDuplicateRegister() {
        let stringConfig = SettingConfiguration("abc", default: .static("xyz"))
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

    func testGettingAValueForUserDefaultsFatals() {
        expect(_ = self.store["userDefault"] as Int).to(throwAssertion())
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

    func testSetDefaultFailsWhenSettingIsStoredInUserDefaults() {
        expect(self.store.setDefault(3, forKey: "userDefault")).to(throwAssertion())
    }
}
