//
//  Created by Derek Clarkson on 4/8/21.
//

import Locus
import Nimble
import XCTest

class IntegrationTests: XCTestCase {

    private var testResourceBundle: Bundle!

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

        let testBundlePath = Bundle(for: IntegrationTests.self).resourcePath
        testResourceBundle = Bundle(path: testBundlePath! + "/Locus_LocusTests.bundle")!
    }

    func testReadingDefaults() {
        SettingsContainer.shared.read(sources: SettingsBundleDefaultValueSource(parentBundle: testResourceBundle))
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
        SettingsContainer.shared.read(sources: SettingsBundleDefaultValueSource(parentBundle: testResourceBundle))
        userDefaultsName = "Derek"
        userDefaultsEnabled = false
        userDefaultsSlider = 0

        expect(self.userDefaultsName) == "Derek"
        expect(self.userDefaultsEnabled) == false
        expect(self.userDefaultsSlider) == 0
        
        expect(self.readOnlyJsonNumber = 10).to(throwAssertion())
    }

    func testReadingAJSONFileOfDefaults() {

        let exp = expectation(description: "reading json")

        let url = testResourceBundle.url(forResource: "Settings", withExtension: "json")!
        SettingsContainer.shared.read(sources: URLDefaultValueSource(url: url) { data, defaultValueSender in
            do {
                let json = try JSONSerialization.jsonObject(with: data) as? [String: Any]
                json?.forEach { defaultValueSender.send(($0.key, $0.value)) }
                defaultValueSender.send(completion: .finished)
            } catch {
                defaultValueSender.send(completion: .failure(error))
            }
            exp.fulfill()
        })

        waitForExpectations(timeout: 5.0)

        expect(self.readOnlyJsonURL) == URL(string: "http://abc.com")!
        expect(self.readOnlyJsonNumber) == 10
    }
}
