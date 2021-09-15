//
//  File.swift
//  File
//
//  Created by Derek Clarkson on 3/9/21.
//

import Combine

/// Wraps a subject to expose functions that a `DefaultValueSource` will need to call.
public struct Defaultable {

    private let sendValue: (DefaultValueUpdate) -> Void
    private let sendCompletion: (Subscribers.Completion<Error>) -> Void
    private let sendFailure: (Subscribers.Completion<Error>) -> Void

    init<S>(subject: S) where S: Subject, S.Output == DefaultValueUpdate, S.Failure == Error {
        sendValue = subject.send(_:)
        sendCompletion = subject.send(completion:)
        sendFailure = subject.send(completion:)
    }

    /// Sets the default value for a key.
    ///
    /// - parameter key: The key of the setting.
    /// - parameter value: The new value.
    public func setDefault<T>(_ value: T, forKey key: String) {
        sendValue((key, value))
    }

    /// Indicates that the value source has finished reading dfault values.
    public func complete() {
        sendCompletion(.finished)
    }

    /// Indicates that the value source excountered an error.
    public func fail(withError error: Error) {
        sendCompletion(.failure(error))
    }
}
