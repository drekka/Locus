//
//  Created by Derek Clarkson on 4/8/21.
//

import Locus
import Nimble
import XCTest

class IntegrationTests: XCTestCase {

    @Setting("name")
    var userDefaultsName: String

    @Setting("enabled")
    var userDefaultsEnabled: Bool

    @Setting("slider")
    var userDefaultsSlider: Double

    @Setting("DebugName")
    var userDefaultsDebugName: String

    @Setting("DebugEnabled")
    var userDefaultsDebugEnabled: Bool

    @Setting("DebugSlider")
    var userDefaultsDebugSlider: Double

    @Setting("jsonUrl")
    var readOnlyJsonURL: URL

    @Setting("jsonNumber")
    var readOnlyJsonNumber: Int

    @Setting("transient.date")
    var transientDate: Date

    @Setting("transient.string")
    var transientString: String

    override func setUp() {
        super.setUp()

        // Clear out preferences
        UserDefaults.standard.dictionaryRepresentation().forEach { key, _ in UserDefaults.standard.removeObject(forKey: key) }

        SettingsContainer.shared = SettingsContainer()
        SettingsContainer.shared.register {
            userDefault("name")
            userDefault("enabled")
            userDefault("slider")
            userDefault("DebugName")
            userDefault("DebugEnabled")
            userDefault("DebugSlider")
            readonly("jsonUrl", default: URL(string: "http://localhost")!)
            readonly("jsonNumber", default: 0)
            transient("transient.date", default: Date())
            transient("transient.string", default: "abc")
        }
    }

    func testReadingDefaults() {
        readDefaultValueSources(SettingsBundleDefaultValueSource(parentBundle: Bundle.testBundle))

        expect(self.userDefaultsName) == "Fred"
        expect(self.userDefaultsEnabled) == true
        expect(self.userDefaultsSlider) == 0.5
        expect(self.userDefaultsDebugName) == "Derek"
        expect(self.userDefaultsDebugEnabled) == false
        expect(self.userDefaultsDebugSlider) == 0.8
        expect(self.readOnlyJsonURL.absoluteString) == "http://localhost"
        expect(self.readOnlyJsonNumber) == 0
    }

    func testChangingValues() {
        readDefaultValueSources(SettingsBundleDefaultValueSource(parentBundle: Bundle.testBundle))

        userDefaultsName = "Derek"
        userDefaultsEnabled = false
        userDefaultsSlider = 0

        expect(self.userDefaultsName) == "Derek"
        expect(self.userDefaultsEnabled) == false
        expect(self.userDefaultsSlider) == 0

        expect(self.readOnlyJsonNumber = 10).to(throwAssertion())
    }

    func testReadingAJSONFileOfDefaults() {

        let url = Bundle.testBundle.url(forResource: "Settings", withExtension: "json")!
        let source = JSONDefaultValueSource(url: url) { json, defaultValueSender in
            (json as! [String: Any]).forEach { defaultValueSender.setDefault($0.value, forKey: $0.key) }
            defaultValueSender.complete()
        }

        readDefaultValueSources(source)

        expect(self.readOnlyJsonURL) == URL(string: "http://abc.com")!
        expect(self.readOnlyJsonNumber) == 10
    }

    private func readDefaultValueSources(_ sources: DefaultValueSource...) {
        let exp = expectation(description: "reading json")
        SettingsContainer.shared.read(sources: sources) { _ in
            exp.fulfill()
        }
        waitForExpectations(timeout: 5.0)
    }
}
