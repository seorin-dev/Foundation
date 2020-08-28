//
//  FoundationProjTests.swift
//  FoundationProjTests
//
//  Created by baedy on 2020/05/07.
//  Copyright © 2020 baedy. All rights reserved.
//

import XCTest
import Foundation
@testable import FoundationProj

class FoundationProjTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testExample() throws {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

    func testTime() {
        XCTAssertEqual(10.timeString, "10")
        XCTAssertEqual(0.timeString, "00")
        XCTAssertEqual(6.timeString, "06")
        XCTAssertEqual((-6).timeString, "06")
        XCTAssertEqual((-15).timeString, "15")
    }
    
}
