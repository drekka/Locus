//
//  Created by Derek Clarkson on 9/8/21.
//

import Combine

/// Defines a key/value tuple representing a new value for a setting published by sources.
public typealias DefaultValueChange = (String, Any)

/// A Source of default values for settings.
public protocol DefaultValueSource {
    
    /// The publsiher used by Locus as a source of default values.
    ///
    /// Sources shuld make use of this publisher to update the registered settings.
    var defaultValues: AnyPublisher<DefaultValueChange, Error> { get }
    
    /// Called by Locus to tell the source to read it's data and send the results via the publisher.
    func read()
}

open class BaseDefaultValueSource: DefaultValueSource {
    
    let defaultValuePublisher = PassthroughSubject<DefaultValueChange, Error>()
    public var defaultValues: AnyPublisher<DefaultValueChange, Error> { defaultValuePublisher.eraseToAnyPublisher() }

    open func read() {
        fatalError("💥💥💥 read() must be overrriden 💥💥💥")
    }
}
