//
//  AZFormulaTests.swift
//  AZCalculationTests
//
//  Created by Karthikaideepan on 08/05/18.
//  Copyright © 2018 allianz. All rights reserved.
//

import XCTest
@testable import AZCalculation
class AZFormulaTests: XCTestCase {
    
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
  
  func testRoundUp()  {
    let decimalValue = NSDecimalNumber.init(value: 15001)
    XCTAssertTrue(decimalValue.roundUp(toPlaces: 3) ==  16000)
    
  }

  
  func testFormula(){
    
    var addition = AZFormula()
    addition.formula = "((1.0 + interest)**(1.0/12.0) - 1.0)"
    addition.name = "addition"
    
    let result = addition.excute(["interest":0.08,"b":10])
    debugPrint("\(result.value)")
    //XCTAssert(result.value == 0.1666666666666667)
    
    addition = AZFormula()
    addition.formula = "0 + 1"
    addition.name = "addition"
    
    let cla = addition.excute(["a":0.08,"b":10])
    debugPrint("\(cla.value)")
    
  }
  
  func testFunctionFormula()  {
    let functionFormula  = AZFormula()
    functionFormula.formula = "14 * FUNCTION( data * year , 'isNotAvailableForFirstYear:', year)"
    let input = ["data":21,"year":1]
    
    let result = functionFormula.excute(input)
    debugPrint("\(result.value)")
  }
  
  func testRoundingIssue()  {
    let rider = ["loadingMile":0.0,"loadingPercentage":0.0,"gender":"M","sumAssured":1000000000.0,"age":40,"table":0.77] as [String : Any]
    let formula = AZFormula()
    formula.formula = "(loadingMile + (1 + loadingPercentage) * table) / 1000 * sumAssured"
    formula.excute(rider)
    
  }
}
