//
//  Created by Derek Clarkson on 11/7/21.
//

import XCTest
import Nimble
import Locus

class VersionTests: XCTestCase {
    
    func testEquality() {
        expect(Version(0,0,0) == Version(0,0,0)) == true
        expect(Version(1,0,0) == Version(0,0,0)) == false
        expect(Version(0,1,0) == Version(0,0,0)) == false
        expect(Version(0,0,1) == Version(0,0,0)) == false
        expect(Version(1,0,0) != Version(0,0,0)) == true
        expect(Version(0,1,0) != Version(0,0,0)) == true
        expect(Version(0,0,1) != Version(0,0,0)) == true
    }
    
    func testLT() {
        expect(Version(0,0,0) < Version(0,0,1)) == true
        expect(Version(0,0,0) < Version(0,1,0)) == true
        expect(Version(0,0,0) < Version(1,0,0)) == true
        expect(Version(0,0,1) < Version(0,1,0)) == true
        expect(Version(0,1,0) < Version(1,0,0)) == true
        expect(Version(1,0,0) < Version(1,0,0)) == false
        expect(Version(0,0,12) < Version(0,1,0)) == true
        expect(Version(0,2,12) < Version(1,0,0)) == true
    }
}
