//
//  IntegrationTests.swift
//  LocusTests
//
//  Created by Derek Clarkson on 8/6/20.
//  Copyright © 2020 Derek Clarkson. All rights reserved.
//

import XCTest
import Locus
import Nimble

protocol TestSettings {
    var url: String { get }
    var retries: Int { get }
}

enum TestSettingsKey: String, SettingsKey {
    case url = "test.url"
    case retries = "test.retries"
}

extension LocusContainer: TestSettings {
    var url: String { return self[TestSettingsKey.url] }
    var retries: Int { return self[TestSettingsKey.retries] }
    func registerTestSettings(inContainer container: SettingsContainer) {
        container.register(key: TestSettingsKey.url, scope: .readonly, defaultValue: "http://abc.com")
        container.register(key: TestSettingsKey.retries, scope: .readonly, defaultValue: 5)
    }
}

class IntegrationTests: XCTestCase {

    private var settings: TestSettings!

    override func setUp() {
        super.setUp()
        let container = LocusContainer(storeFactories: MockStoreFactory())
        container.register(container.registerTestSettings)
        settings = container
    }

    func testReadingValues() {
        expect(self.settings.retries) == 5
        expect(self.settings.url) == "http://abc.com"
    }
}
