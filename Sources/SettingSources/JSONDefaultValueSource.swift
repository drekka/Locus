//
//  File.swift
//  File
//
//  Created by Derek Clarkson on 2/9/21.
//

import UIKit

public class JSONDefaultValueSource: URLDefaultValueSource {

    public init(url: URL,
                headers: [String: String]? = nil,
                mapper: @escaping (_ json: Any) throws -> [String: Any]) {
        super.init(url: url,
                   headers: headers) { data in
            let json = try JSONSerialization.jsonObject(with: data)
            return try mapper(json)
        }
    }
}
