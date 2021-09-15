//
//  File.swift
//  File
//
//  Created by Derek Clarkson on 13/9/21.
//

import XCTest
@testable import Locus
import Nimble

class DefaultValueSourceTests: XCTestCase {
    
    func testReceiveTriggersFatal() {
        let valueSource = DefaultValueSource()
        expect(_ = valueSource.sink { _ in } receiveValue: { _ in }).to(throwAssertion())
    }
}

