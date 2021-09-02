//
//  Created by Derek Clarkson on 29/8/21.
//

import Combine

/// Wraps a subject in a minimal protocol for sending results.
public class Sender<Output, Failure> where Failure: Error {

    private let send: (Output) -> Void
    private let sendCompletion: (Subscribers.Completion<Failure>) -> Void

    init<W>(subject: W) where W: Subject, W.Output == Output, W.Failure == Failure {
        send = subject.send
        sendCompletion = subject.send(completion:)
    }

    /// Sends a value to the wrapped subject.
    public func send(_ value: Output) {
        send(value)
    }

    /// Sends a completion to the wrapped subject.
    public func send(completion: Subscribers.Completion<Failure>) {
        sendCompletion(completion)
    }
}
