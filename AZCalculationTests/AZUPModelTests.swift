//
//  AZUPModelTests.swift
//  AZCalculationTests
//
//  Created by Karthikaideepan on 16/05/18.
//  Copyright © 2018 allianz. All rights reserved.
//

import XCTest
@testable import AZCalculation
class AZUPModelTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
  
  func testCOIvalue()  {
    let model = AZUPModel()
    model.name = "product"
    var input:[String:Any] = [String:Any]()
    input["age"] = 10
    input["gender"] = "F"
    input["currency"] = "IDR"
    input["smoking"] = false
    input["selectedAdditionalValue"] = ""
    //model.calculate(input, action: AZCalculationAction.product, code: "product")
    
    let value:Double = 1000000000.0/78.0 - 860355.222421378 - 5182075.93286622 + 2650200
    debugPrint(value)
    
    
  }
    
}
