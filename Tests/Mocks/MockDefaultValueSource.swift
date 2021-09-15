//
//  File.swift
//  File
//
//  Created by Derek Clarkson on 15/9/21.
//

@testable import Locus

enum MockDefaultValueSourceError: Error {
    case anError
}

class MockDefaultValueSource: DefaultValueSource {

    private let newDefaults: [(String, Any)]
    private let error: Error?

    init(defaults: [(String, Any)] = [], error: Error? = nil) {
        newDefaults = defaults
        self.error = error
        super.init()
    }

    override func readDefaults(_ defaults: Defaultable) {
        newDefaults.forEach {
            defaults.setDefault($0.1, forKey: $0.0)
        }

        if let error = error {
            defaults.fail(withError: error)
            return
        }

        defaults.complete()
    }
}
