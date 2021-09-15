//
//  Created by Derek Clarkson on 29/8/21.
//

import Combine
import UIKit

/// Conveniant wrapper around loading default values from a URL.
open class URLDefaultValueSource: DefaultValueSource {

    private var cancellableTask: Cancellable?
    
    private let url: URL
    private let headers: [String: String]?
    private let mapper: (Data, Defaultable) -> Void
        
    public init(url: URL,
                headers: [String: String]? = nil,
                mapper: @escaping (_ sourceData: Data, _ store: Defaultable) -> Void) {
        self.url = url
        self.headers = headers
        self.mapper = mapper
    }
    
    open override func readDefaults(_ defaults: Defaultable) {
        let session = URLSession(configuration: URLSessionConfiguration.ephemeral)
        var request = URLRequest(url: url)
        headers?.forEach { request.addValue($1, forHTTPHeaderField: $0) }
        self.cancellableTask = session.dataTaskPublisher(for: request).sink { _ in
            self.cancellableTask = nil
        }
        receiveValue: { data, _ in
            self.mapper(data, defaults)
        }
    }
}
