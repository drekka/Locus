//
//  File.swift
//  File
//
//  Created by Derek Clarkson on 13/9/21.
//

import Combine
@testable import Locus
import Nimble
import XCTest

class SettingsBundleDefaultValueSourceTests: XCTestCase {

    func testReadingSettings() {
        runTest { completion, updates in
            switch completion {
            case .finished:
                break // Good
            default:
                fail("Unexpected result: \(String(describing: completion))")
            }
            expect(updates.count) == 6
            expect(updates[0].0) == "DebugName"
            expect(updates[0].1 as? String) == "Derek"
            expect(updates[1].0) == "DebugEnabled"
            expect(updates[1].1 as? Bool) == false
            expect(updates[2].0) == "DebugSlider"
            expect(updates[2].1 as? Double) == 0.8
            expect(updates[3].0) == "name"
            expect(updates[3].1 as? String) == "Fred"
            expect(updates[4].0) == "enabled"
            expect(updates[4].1 as? Bool) == true
            expect(updates[5].0) == "slider"
            expect(updates[5].1 as? Double) == 0.5
        }
    }

    func testBundleNotFound() {
        runTest(settingsBundleName: "not-exists") { completion, updates in
            switch completion {
            case .finished:
                break // Good
            default:
                fail("Unexpected result: \(String(describing: completion))")
            }
            expect(updates.isEmpty) == true
        }
    }

    func testMissingPlist() {
        runTest(settingsBundleName: "Missing child pane") { completion, updates in
            switch completion {
            case .failure(let error):
                expect(error.localizedDescription) == "Plist not found Debug.plist"
            default:
                fail("Unexpected result: \(String(describing: completion))")
            }
            expect(updates.isEmpty) == true
        }
    }

    func testInvalidPlist() {
        runTest(settingsBundleName: "Bad plist") { completion, updates in
            switch completion {
            case .failure(let error):
                expect(error.localizedDescription) == "The data couldn’t be read because it isn’t in the correct format."
            default:
                fail("Unexpected result: \(String(describing: completion))")
            }
            expect(updates.isEmpty) == true
        }
    }

    func testInvalidPlistContent() {
        runTest(settingsBundleName: "Bad plist content") { completion, updates in
            switch completion {
            case .failure(let error):
                expect(error.localizedDescription) == "The content of Root.plist isn't a valid plist definition."
            default:
                fail("Unexpected result: \(String(describing: completion))")
            }
            expect(updates.isEmpty) == true
        }
    }

    func testIncorrectSettingType() {
        runTest(settingsBundleName: "Incorrect setting type") { completion, updates in
            switch completion {
            case .failure(let error):
                expect(error.localizedDescription) == "Cast failure Cannot cast value for Settings preference 'enabled' in Root.plist to a Bool"
            default:
                fail("Unexpected result: \(String(describing: completion))")
            }
            expect(updates.isEmpty) == true
        }
    }

    // MARK: - Internal

    private func runTest(settingsBundleName: String = "Settings",
                         rootPlistFileName: String = "Root",
                         validation: @escaping (Subscribers.Completion<Error>?, [DefaultValueUpdate]) -> Void) {

        let exp = expectation(description: "Reading settings bundle")

        let valueSource = SettingsBundleDefaultValueSource(parentBundle: Bundle.testBundle,
                                                           settingsBundleName: settingsBundleName,
                                                           rootPlistFileName: rootPlistFileName)

        var completion: Subscribers.Completion<Error>?
        var updates: [DefaultValueUpdate] = []
        let passthroughSubject = PassthroughSubject<DefaultValueUpdate, Error>()
        let cancellable = passthroughSubject.sink {
            completion = $0
            exp.fulfill()
        }
        receiveValue: {
            updates.append($0)
        }

        // Run the test
        valueSource.readDefaults(Defaultable(subject: passthroughSubject))

        waitForExpectations(timeout: 5.0)

        withExtendedLifetime(cancellable) {
            validation(completion, updates)
        }
    }
}
