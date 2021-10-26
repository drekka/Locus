//
// Created by Derek Clarkson on 26/7/21.
//

import Locus
import Nimble
import XCTest

private enum Key: String {
    case abc
}

class SettingConfigurationTests: XCTestCase {

    func testInitializer() {
        let config = SettingConfiguration("abc", persistence: .none, default: .static(5), releaseLocked: false)
        validate(config, expectedPersistence: .none)
    }

    func testInitializerWithEnum() {
        let config = SettingConfiguration(Key.abc, persistence: .none, default: .static(5), releaseLocked: false)
        validate(config, expectedPersistence: .none)
    }

    func testReadonlyAndReleaseLockedFatals() {
        expect(SettingConfiguration("abc", persistence: .none, default: .static(5), releaseLocked: true)).to(throwAssertion())
    }

    // MARK; - Convenience functions.

    func testReadonlyConvenienceFunction() {
        let config = readonly("abc", default: .static(5))
        validate(config, expectedPersistence: .none)
    }

    func testReadonlyWithenumConvenienceFunction() {
        let config = readonly(Key.abc, default: .static(5))
        validate(config, expectedPersistence: .none)
    }

    func testTransientConvenienceFunction() {
        let config = transient("abc", default: .static(5))
        validate(config, expectedPersistence: .transient)
    }

    func testTransientWithEnumConvenienceFunction() {
        let config = transient(Key.abc, default: .static(5))
        validate(config, expectedPersistence: .transient)
    }

    func testUserDefaultsConvenienceFunction() {
        let config = userDefault("abc")
        validate(config, expectedPersistence: .userDefaults, expectedDefault: .userDefaults)
    }

    func testUserDefaultsWithEnumConvenienceFunction() {
        let config = userDefault(Key.abc)
        validate(config, expectedPersistence: .userDefaults, expectedDefault: .userDefaults)
    }
    
    // MARK: - Internal

    private func validate(_ configuration: SettingConfiguration, expectedPersistence: Persistence, expectedDefault: Default = .static(5)) {

        expect(configuration.key) == "abc"
        expect(configuration.persistence) == expectedPersistence
        expect(configuration.releaseLocked) == false

        switch (configuration.defaultValue, expectedDefault) {

        case (.static(let value), .static(let expected)):
            expect(value as? Int) == expected as! Int

        case (.userDefaults, .userDefaults):
            break // Good.

        default:
            fail("\(configuration.defaultValue) != \(expectedDefault)")
        }
    }
}
