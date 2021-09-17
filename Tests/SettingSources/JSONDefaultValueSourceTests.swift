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

class JSONDefaultValueSourceTests: XCTestCase {

    func testCallsMapper() {

        runTest(jsonFile: "Settings") { json, container in
            if let data = json as? [String: Any] {
                if let jsonUrl = data["jsonUrl"] as? String {
                    container.setDefault(jsonUrl, forKey: "jsonUrl")
                }
                if let jsonNumber = data["jsonNumber"] as? Int {
                    container.setDefault(jsonNumber, forKey: "jsonNumber")
                }
            }

            container.complete()
        }
        validation: { completion, updates in
            switch completion {
            case .finished:
                break // All good
            default:
                fail("Unexpected error: \(String(describing: completion))")
            }
            expect(updates[0].0) == "jsonUrl"
            expect(updates[0].1 as? String) == "http://abc.com"
            expect(updates[1].0) == "jsonNumber"
            expect(updates[1].1 as? Int) == 10
        }
    }

    func testFailsWithInvalidJSON() {

        runTest(jsonFile: "Invalid") { _, _ in }
        validation: { completion, _ in
            switch completion {
            case .failure(let error):
                expect(error.localizedDescription) == "The data couldn’t be read because it isn’t in the correct format."
            // All good
            default:
                fail("Unexpected error: \(String(describing: completion))")
            }
        }
    }

    private func runTest(jsonFile: String, mapper: @escaping (Any, Defaultable) -> Void, validation: @escaping (Subscribers.Completion<Error>?, [DefaultValueUpdate]) -> Void) {

        let url = Bundle.testBundle.url(forResource: jsonFile, withExtension: "json")!
        let exp = expectation(description: "Reading JSON")
        let valueSource = JSONDefaultValueSource(url: url) { json, container in
            mapper(json, container)
        }
        
        var completion: Subscribers.Completion<Error>?
        var updates: [DefaultValueUpdate] = []
        let passthroughSubject = PassthroughSubject<DefaultValueUpdate, Error>()
        let cancellable = passthroughSubject.sink {
            completion = $0
            exp.fulfill()
        }
        receiveValue: { updates.append($0) }

        // Run the test
        valueSource.readDefaults(Defaultable(subject: passthroughSubject))

        waitForExpectations(timeout: 5.0)

        withExtendedLifetime(cancellable) {
            validation(completion, updates)
        }
    }
}
