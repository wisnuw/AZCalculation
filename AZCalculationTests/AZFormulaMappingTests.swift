//
//  AZFormulaMappingTests.swift
//  AZCalculationTests
//
//  Created by Karthikaideepan on 17/05/18.
//  Copyright © 2018 allianz. All rights reserved.
//

import XCTest
@testable import AZCalculation

class AZFormulaMappingTests: XCTestCase {
    
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
  func testFormulaJson(){
    let formulaMapper = AZFormulaMapping()
    let up = formulaMapper.loadUnappliedPremium("unappliedpremium")
  
    if up.upModels.count > 0 {
      
    }
  }
  
  func testDynamicPositionFormul()  {
    
    let formulaMapper = AZFormulaMapping()
    let calculation = formulaMapper.loadIllustrationTable("illustrationCalculation")
    
    let addbRider = calculation.tableModels.filter { (model) -> Bool in
      model.name == "addb"
    }
    if addbRider.count > 0 {
      let rider = ["year":0, "firstYear":1, "table":1, "loadingMile":0,"loadingPercentage":0,"sumAssured":8000000,"age":5,"selectedAdditionalValue":"1","maxTerm":65,"investmentAllocation":1 ] as [String : Any]
      let tableModel = addbRider.first!
      let result = tableModel.formula.excute(rider)
      
      XCTAssertTrue(result.value == 0)
    }
    
    
  }
  
  func testSubformulaJSON()  {
    let formulaMapper = AZFormulaMapping()
    let calculation = formulaMapper.loadIllustrationTable("illustrationCalculation")
    
    let models = calculation.tableModels
    
    let subFormulaModels = models.filter { (model) -> Bool in
      model.name == "product"
    }
    let coiTable = subFormulaModels.first!
    XCTAssert((coiTable.formula.subFormulas?.count)! > 0 )
  }
}
