//
//  File.swift
//  File
//
//  Created by Derek Clarkson on 15/9/21.
//

@testable import Locus
import UIKit

enum MockDefaultValueSourceError: Error {
    case anError
}

class MockDefaultValueSource: DefaultValueSource {

    private let name: String
    private let newDefaults: [String: Any]
    private let error: Error?
    var log: [(TimeInterval, String)] = []

    init(name: String, defaults: [String: Any] = [:], error: Error? = nil) {
        self.name = name
        newDefaults = defaults
        self.error = error
    }

    func readDefaults() async throws -> [String: Any] {
        log.append((Date.now.timeIntervalSince1970, "\(name) reading"))
        return try await Task {
            if let error = error {
                log.append((Date.now.timeIntervalSince1970, "\(name) error"))
                throw error
            }

            log.append((Date.now.timeIntervalSince1970, "\(name) returning values"))
            return newDefaults
        }.value
    }
}
