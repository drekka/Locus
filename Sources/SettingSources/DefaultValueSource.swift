//
//  Created by Derek Clarkson on 9/8/21.
//

import Combine

/// A parent class for value sources.
open class DefaultValueSource: Publisher {

    public typealias Output = DefaultValueUpdate
    public typealias Failure = Error

    /// Override to publisher function.
    ///
    /// Do not call.
    public func receive<S>(subscriber: S) where S: Subscriber, S.Failure == Failure, S.Input == Output {
        let defaultValueSubject = PassthroughSubject<DefaultValueUpdate, Error>()
        defaultValueSubject.receive(subscriber: subscriber)
        readDefaults(Defaultable(subject: defaultValueSubject))
    }

    /// Override to read updates to default settings.
    ///
    /// - parameter container: Call the methods on this instance to update the defaults and notify the container when this class has finished reading values.
    // swiftformat:disable:next unusedArguments
    open func readDefaults(_ container: Defaultable) {
        fatalError("💥💥💥 DefaultValueSource.readDefaults(_:) not overrriden 💥💥💥")
    }
}
