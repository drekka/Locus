////
////  File.swift
////
////
////  Created by Derek Clarkson on 18/7/21.
////
//
//import Locus
//import Nimble
//import XCTest
//
//class TransientStoreTests: XCTestCase {
//
//    private var nextStore: DefaultStore<Int>!
//    private var transientStore: TransientStore<Int>!
//
//    override func setUp() {
//        super.setUp()
//        let config = SettingConfig(withKey: "abc")
//        nextStore = DefaultStore(config: config, defaultValue: 5)
//        transientStore = TransientStore(nextStore: nextStore)
//    }
//
//    func testInitialSetup() {
//        expect(self.transientStore.value) == 5
//    }
//
//    func testSettingAndRetrieving() {
//        transientStore.value = 3
//        expect(self.transientStore.value) == 3
//    }
//
//    func testSetDefaultPassesThrough() {
//        transientStore.value = 3
//        transientStore.setDefault(7)
//        expect(self.transientStore.value) == 3
//        expect(self.nextStore.value) == 7
//    }
//}
