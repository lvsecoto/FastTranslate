//
//  TkCaculateUtilsTest.swift
//  SpikeMacosTests
//
//  Created by 袁俊耀 on 2019/2/17.
//  Copyright © 2019 袁俊耀. All rights reserved.
//

import XCTest
@testable import FastTranslate

class TkCaculateUtilsTest: XCTestCase {

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testHexCharAsNumber() {
        XCTAssertEqual(hexCharAsNumber("3"), 3);
        XCTAssertEqual(hexCharAsNumber("a"), 10);
    }
    
    func testNormalizeHash() {
        XCTAssertEqual(normalizeHash(8134240), 134240);
    }
    
    func testTransformQuery() {
        XCTAssertEqual(transformQuery("123ABCabc我"), [49, 50, 51, 65, 66, 67, 97, 98, 99, 230, 136, 145]);
    }

    func testShiftLeftOrRightThenSumOrXor() {
        XCTAssertEqual(shiftLeftOrRightThenSumOrXor(["+-a", "^+9"], 12), 12308);
    }

    func testCalcHash() {
        XCTAssertEqual(calcHash("hola", "409837.2120040981"), "70528.480109");
    }

}
