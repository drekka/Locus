//
//  Created by Derek Clarkson on 29/8/21.
//

import UIKit

/// Conveniant wrapper around loading default values from a URL.
open class URLDefaultValueSource: DefaultValueSource {

    private let url: URL
    private let headers: [String: String]?
    private let mapper: (Data) throws -> [String: Any]
        
    public init(url: URL,
                headers: [String: String]? = nil,
                mapper: @escaping (_ sourceData: Data) throws -> [String: Any]) {
        self.url = url
        self.headers = headers
        self.mapper = mapper
    }
    
    open func readDefaults() async throws -> [String: Any] {
        let session = URLSession(configuration: URLSessionConfiguration.ephemeral)
        var request = URLRequest(url: url)
        headers?.forEach { request.addValue($1, forHTTPHeaderField: $0) }
        let data = try await session.data(for: request).0
        return try mapper(data)
    }
}
