//
//  Created by Derek Clarkson on 29/8/21.
//

import Combine
import UIKit

/// Conveniant wrapper around loading default values from a URL.
public class URLDefaultValueSource: BaseDefaultValueSource {

    private let mapper: (_ sourceData: Data, _ defaultValuePublisher: Sender<DefaultValueChange, Error>) -> Void
    private let url: URL
    private let headers: [String: String]?
    private var cancellableTask: Cancellable?

    public init(url: URL,
         headers: [String: String]? = nil,
         mapper: @escaping (_ sourceData: Data, _ defaultValuePublisher: Sender<DefaultValueChange, Error>) -> Void) {
        self.mapper = mapper
        self.url = url
        self.headers = headers
    }

    public override func read() {
        let session = URLSession(configuration: URLSessionConfiguration.ephemeral)
        var request = URLRequest(url: url)
        headers?.forEach { request.addValue($1, forHTTPHeaderField: $0) }
        cancellableTask = session.dataTaskPublisher(for: request).sink { _ in
            self.cancellableTask = nil
        }
        receiveValue: { data, _ in
            self.mapper(data, Sender(subject: self.defaultValuePublisher))
        }
    }
}
