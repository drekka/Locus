//
//  File.swift
//  File
//
//  Created by Derek Clarkson on 14/9/21.
//

@testable import Locus
import Nimble
import XCTest

class URLDefaultValueSourceTests: XCTestCase {

    func testReadDefaults() async throws {

        let url = Bundle.testBundle.url(forResource: "Settings", withExtension: "json")!
        let valueSource = URLDefaultValueSource(url: url,
                                                headers: ["abc": "def"]) { data in
            let json = try! JSONSerialization.jsonObject(with: data) as! [String: Any]
            return ["jsonNumber": json["jsonNumber"]!]
        }

        let defaults = try await valueSource.readDefaults()

        expect(defaults.count) == 1
        expect(defaults["jsonNumber"] as? Int) == 10
    }
}
