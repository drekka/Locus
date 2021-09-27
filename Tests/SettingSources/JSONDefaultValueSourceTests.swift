//
//  File.swift
//  File
//
//  Created by Derek Clarkson on 13/9/21.
//

@testable import Locus
import Nimble
import XCTest

class JSONDefaultValueSourceTests: XCTestCase {

    func testCallsMapper() async throws {

        let newDefaults = try await runTest(jsonFile: "Settings")

        expect(newDefaults.count) == 2
        expect(newDefaults["jsonUrl"] as? String) == "http://abc.com"
        expect(newDefaults["jsonNumber"] as? Int) == 10
    }

    func testFailsWithInvalidJSON() async throws {
        do {
            _ = try await runTest(jsonFile: "Invalid")
        }
        catch {
            expect(error.localizedDescription) == "The data couldn’t be read because it isn’t in the correct format."
        }
    }

    // MRK: - Internal

    private func runTest(jsonFile: String) async throws -> [String: Any] {

        let url = Bundle.testBundle.url(forResource: jsonFile, withExtension: "json")!
        let valueSource = JSONDefaultValueSource(url: url) { json in
            var results: [String: Any] = [:]
            if let data = json as? [String: Any] {
                if let jsonUrl = data["jsonUrl"] as? String {
                    results["jsonUrl"] = jsonUrl
                }
                if let jsonNumber = data["jsonNumber"] as? Int {
                    results["jsonNumber"] = jsonNumber
                }
            }
            return results
        }
        return try await valueSource.readDefaults()
    }
}
