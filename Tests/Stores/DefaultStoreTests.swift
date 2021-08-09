////
////  File.swift
////  File
////
////  Created by Derek Clarkson on 1/8/21.
////
//
//import Locus
//import Nimble
//import XCTest
//
//class DefaultStoreTests: XCTestCase {
//
//    private var store: DefaultStore<Int>!
//
//    override func setUp() {
//        super.setUp()
//        let config = SettingConfig(withKey: "abc")
//        store = DefaultStore(config: config, defaultValue: 5)
//    }
//
//    func testGettingAValue() {
//        expect(self.store.value) == 5
//    }
//
//    func testStoringAValueFatals() {
//        expect(self.store.value = 1).to(throwAssertion())
//    }
//
//    func testSetDefault() {
//        store.setDefault(3)
//        expect(self.store.value) == 3
//    }
//}
