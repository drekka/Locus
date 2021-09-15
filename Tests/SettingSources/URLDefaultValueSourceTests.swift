//
//  File.swift
//  File
//
//  Created by Derek Clarkson on 14/9/21.
//

import Combine
@testable import Locus
import Nimble
import XCTest

class URLDefaultValueSourceTests: XCTestCase {

    func testReadDefaults() {

        let url = Bundle.testBundle.url(forResource: "Settings", withExtension: "json")!
        let exp = expectation(description: "Reading config")

        let valueSource = URLDefaultValueSource(url: url,
                                                headers: ["abc": "def"]) { data, defaultable in
            let json = try! JSONSerialization.jsonObject(with: data) as! [String: Any]
            defaultable.setDefault(json["jsonNumber"], forKey: "jsonNumber")
            defaultable.complete()
        }

        var completion: Subscribers.Completion<Error>?
        var updates: [DefaultValueUpdate] = []
        let passthroughSubject = PassthroughSubject<DefaultValueUpdate, Error>()
        let cancellable = passthroughSubject.sink {
            completion = $0
            exp.fulfill()
        }
        receiveValue: { updates.append($0) }

        valueSource.readDefaults(Defaultable(subject: passthroughSubject))

        waitForExpectations(timeout: 5.0)

        withExtendedLifetime(cancellable) {
            switch completion {
            case .finished:
                break // All good
            default:
                fail("Unexpected error: \(String(describing: completion))")
            }
            expect(updates.count) == 1
            expect(updates[0].0) == "jsonNumber"
            expect(updates[0].1 as? Int) == 10
        }
    }
}
