//
//  Created by Derek Clarkson on 16/8/21.
//

import UIKit
import UsefulThings

/// Support protocol for casting to a result type.
protocol ValueCastable {

    /// Casts a value.
    ///
    /// This will trigger a `fatalError(...)` if the value is not castable.
    ///
    /// - parameter value: The value to be cast.
    /// - parameter key: The key of the value being cast.
    /// - returns: The value cast to the correct type.
    func cast<T>(_ value: Any, forKey key: String) -> T
}

extension ValueCastable {

    func cast<T>(_ value: Any, forKey key: String) -> T {
        if let value = UsefulThings.cast(value) as T? {
            return value
        }
        fatalError("💥💥💥 Value for key \(key) cannot be cast to a \(T.self) 💥💥💥")
    }
}
