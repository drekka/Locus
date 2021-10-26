//
//  Created by Derek Clarkson on 4/8/21.
//

import Locus
import Nimble
import XCTest

class IntegrationTests: XCTestCase {

    enum SettingKey: String {
        case name
        case enabled
        case slider
        case debugName = "DebugName"
        case debugEnabled = "DebugEnabled"
        case debugSlider = "DebugSlider"
        case jsonUrl
        case jsonNumber
        case transientDate = "transient.date"
        case transientString = "transient.string"
    }

    @Setting(SettingKey.name)
    var userDefaultsName: String

    @Setting(SettingKey.enabled)
    var userDefaultsEnabled: Bool

    @Setting(SettingKey.slider)
    var userDefaultsSlider: Double

    @Setting(SettingKey.debugName)
    var userDefaultsDebugName: String

    @Setting(SettingKey.debugEnabled)
    var userDefaultsDebugEnabled: Bool

    @Setting(SettingKey.debugSlider)
    var userDefaultsDebugSlider: Double

    @Setting(SettingKey.jsonUrl)
    var readOnlyJsonURL: URL

    @Setting(SettingKey.jsonNumber)
    var readOnlyJsonNumber: Int

    @Setting(SettingKey.transientDate)
    var transientDate: Date

    @Setting(SettingKey.transientString)
    var transientString: String

    override func setUp() {
        super.setUp()

        // Clear out preferences
        UserDefaults.standard.dictionaryRepresentation().forEach { key, _ in UserDefaults.standard.removeObject(forKey: key) }

        SettingsContainer.shared = SettingsContainer()
        SettingsContainer.shared.register {
            userDefault(SettingKey.name)
            userDefault(SettingKey.enabled)
            userDefault(SettingKey.slider)
            userDefault(SettingKey.debugName)
            userDefault(SettingKey.debugEnabled)
            userDefault(SettingKey.debugSlider)
            readonly(SettingKey.jsonUrl, default: .static(URL(string: "http://localhost")!))
            readonly(SettingKey.jsonNumber, default: .static(0))
            transient(SettingKey.transientDate, default: .static(Date()))
            transient(SettingKey.transientString, default: .static("abc"))
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
        let source = JSONDefaultValueSource(url: url) { $0 as! [String: Any] }

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
