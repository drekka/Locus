//
//  File.swift
//  File
//
//  Created by Derek Clarkson on 1/8/21.
//

import Locus
import XCTest
import Nimble

class UserDefaultsStoreTests: XCTestCase {

    private let key = "__testKey"
    private var store: UserDefaultsStore!

    override func setUp() {
        super.setUp()

        UserDefaults.standard.removeObject(forKey: key)
        let config = SettingConfig(withKey: key, default: 5)
        store = UserDefaultsStore(config: config)
    }
    
    override func tearDown() {
        UserDefaults.standard.removeObject(forKey: key)
        super.tearDown()
    }

    func testGetValue() {
        UserDefaults.standard.set(5, forKey: key)
        expect(self.store.value as? Int) == 5
    }

    func testSetValue() {
        store.value = 5
        expect(self.store.value as? Int) == 5
        expect(UserDefaults.standard.integer(forKey: self.key)) == 5
    }

    func testSetDefault() {
        store.setDefault(10)
        expect(self.store.value as? Int) == 10
        expect(UserDefaults.standard.integer(forKey: self.key)) == 10
    }
}
