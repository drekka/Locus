//
//  File.swift
//  File
//
//  Created by Derek Clarkson on 11/9/21.
//

import Combine
@testable import Locus
import XCTest
import Nimble

enum TestError: Error {
    case anError
}

class DefaultableTests: XCTestCase {

    private var currentValueSubject: CurrentValueSubject<DefaultValueUpdate, Error>!
    private var passthroughSubject: PassthroughSubject<DefaultValueUpdate, Error>!

    private var currentValueDefaultable: Defaultable!
    private var passthroughDefaultable: Defaultable!

    override func setUp() {
        super.setUp()
        currentValueSubject = CurrentValueSubject<DefaultValueUpdate, Error>(("abc", 1))
        currentValueDefaultable = Defaultable(subject: currentValueSubject)
        passthroughSubject = PassthroughSubject<DefaultValueUpdate, Error>()
        passthroughDefaultable = Defaultable(subject: passthroughSubject)
    }

    func testCurrentSetDefault() {
        runTest(subject: currentValueSubject) {
            currentValueDefaultable.setDefault(2, forKey: "def")
            currentValueDefaultable.complete()
        }
        assertResults: { value, completion in
            switch completion {
            case .some(.finished): break // All good
            default: XCTFail("Unexpected \(String(describing: completion))")
            }
            expect(value?.0) == "def"
            expect(value?.1 as? Int) == 2
        }
    }

    func testCurrentFails() {
        runTest(subject: currentValueSubject) {
            currentValueDefaultable.fail(withError: TestError.anError)
        }
        assertResults: { value, completion in
            switch completion {
            case .some(.failure(let error)):
                XCTAssertEqual(TestError.anError, error as? TestError)
            default: XCTFail("Unexpected \(String(describing: completion))")
            }
            XCTAssertEqual("abc", value?.0)
            XCTAssertEqual(1, value?.1 as? Int)
        }
    }

    func testPassthroughSetDefault() {
        runTest(subject: passthroughSubject) {
            passthroughDefaultable.setDefault(2, forKey: "def")
            passthroughDefaultable.complete()
        }
        assertResults: { value, completion in
            switch completion {
            case .some(.finished): break // All good
            default: XCTFail("Unexpected \(String(describing: completion))")
            }
            XCTAssertEqual("def", value?.0)
            XCTAssertEqual(2, value?.1 as? Int)
        }
    }

    func testPassthroughFails() {
        runTest(subject: passthroughSubject) {
            passthroughDefaultable.fail(withError: TestError.anError)
        }
        assertResults: { value, completion in
            switch completion {
            case .some(.failure(let error)):
                XCTAssertEqual(TestError.anError, error as? TestError)
            default: XCTFail("Unexpected \(String(describing: completion))")
            }
            XCTAssertNil(value)
        }
    }

    private func runTest<S>(subject: S,
                            test: () -> Void,
                            assertResults: (DefaultValueUpdate?, Subscribers.Completion<Error>?) -> Void) where S: Subject, S.Output == DefaultValueUpdate, S.Failure == Error {
        let exp = expectation(description: "subject")

        var value: DefaultValueUpdate?
        var completion: Subscribers.Completion<Error>?
        let cancellable = subject.sink {
            completion = $0
            exp.fulfill()
        }
        receiveValue: { value = $0 }

        test()

        waitForExpectations(timeout: 5.0)

        withExtendedLifetime(cancellable) {
            assertResults(value, completion)
        }
    }
}
