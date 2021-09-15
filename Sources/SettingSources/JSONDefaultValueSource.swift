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
                mapper: @escaping (_ json: Any, _ store: Defaultable) -> Void) {
        super.init(url: url,
                   headers: headers) { data, defaults in
            do {
                let json = try JSONSerialization.jsonObject(with: data)
                mapper(json, defaults)
            } catch {
                defaults.fail(withError: error)
            }
        }
    }
}
