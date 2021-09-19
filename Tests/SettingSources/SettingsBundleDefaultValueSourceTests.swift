//
//  File.swift
//  File
//
//  Created by Derek Clarkson on 13/9/21.
//

@testable import Locus
import Nimble
import XCTest

class SettingsBundleDefaultValueSourceTests: XCTestCase {

    func testReadingSettings() async throws {

        let updates = try await SettingsBundleDefaultValueSource(parentBundle: Bundle.testBundle).readDefaults()

        expect(updates.count) == 6
        expect(updates["DebugName"] as? String) == "Derek"
        expect(updates["DebugEnabled"] as? Bool) == false
        expect(updates["DebugSlider"] as? Double) == 0.8
        expect(updates["name"] as? String) == "Fred"
        expect(updates["enabled"] as? Bool) == true
        expect(updates["slider"] as? Double) == 0.5
    }

    func testBundleNotFound() async throws {
        let updates = try await SettingsBundleDefaultValueSource(parentBundle: Bundle.testBundle, settingsBundleName: "not-exists").readDefaults()
        expect(updates.isEmpty) == true
    }

    func testMissingPlist() async {
        do {
            _ = try await SettingsBundleDefaultValueSource(parentBundle: Bundle.testBundle, settingsBundleName: "Missing child pane").readDefaults()
            fail("Error not thrown")
        } catch {
            expect(error.localizedDescription) == "Plist not found Debug.plist"
        }
    }

    func testInvalidPlist() async {
        do {
            _ = try await SettingsBundleDefaultValueSource(parentBundle: Bundle.testBundle, settingsBundleName: "Bad plist").readDefaults()
            fail("Error not thrown")
        } catch {
            expect(error.localizedDescription) == "The data couldn’t be read because it isn’t in the correct format."
        }
    }

    func testDuplicateKeysFound() async {
        print("hello")
        do {
            _ = try await SettingsBundleDefaultValueSource(parentBundle: Bundle.testBundle, settingsBundleName: "Duplicate keys").readDefaults()
            fail("Error not thrown")
        } catch {
            expect(error.localizedDescription) == "Key 'enabled' exists in more than one set of preferences."
        }
    }

    func testInvalidPlistContent() async {
        do {
            _ = try await SettingsBundleDefaultValueSource(parentBundle: Bundle.testBundle, settingsBundleName: "Bad plist content").readDefaults()
            fail("Error not thrown")
        } catch {
            expect(error.localizedDescription) == "The content of Root.plist isn't a valid plist definition."
        }
    }

    func testIncorrectSettingType() async {
        do {
            _ = try await SettingsBundleDefaultValueSource(parentBundle: Bundle.testBundle, settingsBundleName: "Incorrect setting type").readDefaults()
            fail("Error not thrown")
        } catch {
            expect(error.localizedDescription) == "Cast failure Cannot cast value for Settings preference 'enabled' in Root.plist to a Bool"
        }
    }
}
