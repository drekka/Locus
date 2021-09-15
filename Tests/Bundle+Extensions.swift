//
//  File.swift
//  File
//
//  Created by Derek Clarkson on 13/9/21.
//

import UIKit

extension Bundle {
    
    static var testBundle: Bundle = {
        let testBundlePath = Bundle(for: IntegrationTests.self).resourcePath
        return Bundle(path: testBundlePath! + "/Locus_LocusTests.bundle")!
    }()
}
