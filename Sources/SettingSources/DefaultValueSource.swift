//
//  Created by Derek Clarkson on 9/8/21.
//

public protocol DefaultValueSource {
    func readDefaults() async throws -> [String: Any]
}
