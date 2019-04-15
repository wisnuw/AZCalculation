//
//  AZProductIllustrationTableTests.swift
//  AZCalculationTests
//
//  Created by Karthikaideepan on 11/06/18.
//  Copyright © 2018 allianz. All rights reserved.
//

import XCTest
@testable import AZCalculation
class AZProductIllustrationTableTests: XCTestCase {
    
    override func setUp() {
        super.setUp()

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
  func testProductAllocationCalculationWithoutRider() {
    let input = getBaseProductInfo()
    let output = AZCalculator.calculateIllustrationCalculation(input)
    
    let low = output["low"]
    
    if let year5 = low![4] as? NSNumber {
      XCTAssertTrue(year5 ==  307335887 )
    }
  }
  
  func getBaseProductInfo() -> [String:Any]{
    var input = [String:Any]()
    input["age"] = 5
    input["currency"] = "IDR"
    input["premium"] =  100000000
    input["mode"] = 1
    input["maxSumAssuredMultiplier"] = 150
    input["sumAssured"] =  3000000000
    input["maxTerm"] = 99
    let product = ["loadingMile":5,"loadingPercentage":0,"age":5,"currency":"IDR","smoking":false,"gender":"M","sumAssured":3000000000,"maxTerm":99] as [String : Any]
    input["product"] = product
    let allocation = ["allocationCode":"ALL"]
    input["allocation"] = allocation
    return input
  }
  func testIllustrationTableWithAddbRider() {
    var input = getBaseProductInfo()
    let rider = ["loadingMile":5,"loadingPercentage":0,"sumAssured":8000000,"age":5,"selectedAdditionalValue":"1","maxTerm":65] as [String : Any]
    input["addb"] = rider
    let output = AZCalculator.calculateIllustrationCalculation(input)
    
    let low = output["low"]
    if let year5 = low![4] as? NSNumber {
      XCTAssertTrue(year5 == 307032912)
    }
  }
  func testIllustrationTableWithFlexicareRider() {
    
    var input:[String:Any] = getBaseProductInfo()
    let fam1 = ["loadingPercentage":0.02,"sumAssured":10,"age":5,"currency":"IDR","maxTerm":60] as [String : Any]
    input["fam1"] = fam1
    let fam2 = ["loadingPercentage":0.05,"sumAssured":10,"age":41,"currency":"IDR","maxTerm":60] as [String : Any]
    input["fam2"] = fam2
    let fam3 = ["loadingPercentage":0.06,"sumAssured":10,"age":38,"currency":"IDR","maxTerm":60] as [String : Any]
    input["fam3"] = fam3
    let fam4 = ["loadingPercentage":0.09,"sumAssured":10,"age":22,"currency":"IDR","maxTerm":60] as [String : Any]
    input["fam4"] = fam4
    let fam5 = ["loadingPercentage":0.1,"sumAssured":10,"age":19,"currency":"IDR","maxTerm":60] as [String : Any]
    input["fam5"] = fam5
    
    let output = AZCalculator.calculateIllustrationCalculation(input)
    
    let low = output["low"]
    if let year5 = low![24] as? NSNumber {
      XCTAssertTrue(year5 ==   4797090301  )
    }
  }
  
  func testIllustrationTableWithCI100Rider() {
    
    var input:[String:Any] = getBaseProductInfo()
    let rider = ["loadingMile":0,"loadingPercentage":0,"gender":"M","sumAssured":8000000,"age":5,"smoking":false,"maxTerm":65] as [String : Any]
    input["ci 100s"] = rider
    let output = AZCalculator.calculateIllustrationCalculation(input)
    
    let low = output["low"]
    if let year5 = low![24] as? NSNumber {
      XCTAssertTrue(year5 == 5459254080 )
    }
    
  }
  func testIllustrationTableWithCIPlusRider() {
    
    var input:[String:Any] = getBaseProductInfo()
    let rider = ["loadingMile":0,"loadingPercentage":0,"gender":"M","sumAssured":8000000,"age":5,"maxTerm":65] as [String : Any]
    input["ci plus"] = rider
    let output = AZCalculator.calculateIllustrationCalculation(input)
    
    let low = output["low"]
    if let year5 = low![24] as? NSNumber {
      XCTAssertTrue(year5 ==  5459317780 )
    }
    
  }
  func testIllustrationTableWithSmartMedCancerRider() {
    
    var input:[String:Any] = getBaseProductInfo()
    let smcr = ["loadingPercentage":0,"gender":"M","selectedAdditionalValue":"2","age":5,"maxTerm":75] as [String : Any]
    input["smcr"] = smcr
    let output = AZCalculator.calculateIllustrationCalculation(input)
    
    let low = output["low"]
    if let year5 = low![24] as? NSNumber {
      XCTAssertTrue(year5 ==   5426752220)
    }
    
  }
  
  func testIllustrationTableWithHSRider() {
    
    var input:[String:Any] = getBaseProductInfo()
    
    let hs = ["loadingPercentage":0,"gender":"MALE","selectedAdditionalValue":"100","age":5, "maxTerm":80] as [String : Any]
    input["hsrider"] = hs
    
    let output = AZCalculator.calculateIllustrationCalculation(input)
    
    let low = output["low"]
    if let year5 = low![24] as? NSNumber {
      XCTAssertTrue(year5 == 5412499981 )
    }
    
  }
  
  func testIllustrationTableWithTpdAccRider() {
    
    var input:[String:Any] = getBaseProductInfo()
    input["maxSumAssuredMultiplier"] = 125
    input["age"] = 18
    var product = input["product"]  as! [String:Any]
    product["age"] = 18
    input["product"] = product
    let rider = ["loadingMile":0,"loadingPercentage":0,"gender":"M","sumAssured":21000000,"age":18,"maxTerm":65] as [String : Any]
    input["tpda"] = rider
    
    let output = AZCalculator.calculateIllustrationCalculation(input)
    
    let low = output["low"]
    if let year5 = low![24] as? NSNumber {
      XCTAssertTrue(year5 ==    5290807970 )
    }
    
  }
  func testIllustrationTableWithTpdRider() {
    
    var input:[String:Any] = getBaseProductInfo()
    input["maxSumAssuredMultiplier"] = 125
    input["age"] = 18
    var product = input["product"]  as! [String:Any]
    product["age"] = 18
    input["product"] = product
    let rider = ["loadingMile":0,"loadingPercentage":0,"gender":"M","sumAssured":21000000,"age":18,"maxTerm":60] as [String : Any]
    input["tpd"] = rider
    
    let output = AZCalculator.calculateIllustrationCalculation(input)
    
    let low = output["low"]
    if let year5 = low![24] as? NSNumber {
      XCTAssertTrue(year5 == 5290484126)
    }
    
  }
  
  func testIllustrationTableWithPayorRider(){
    var input:[String:Any] = getBaseProductInfo()
    let pbr = ["loadingPercentage":0,"loadingMile":0,"currency":"IDR","gender":"F","sumAssured": 100000000 ,"age":32,"mode":1, "maxTerm":65] as [String : Any]
    input["pbr"] = pbr
    let output = AZCalculator.calculateIllustrationCalculation(input)
    
    let low = output["low"]
    if let year5 = low![24] as? NSNumber {
      XCTAssertTrue(year5 == 5065345216 )
    }
  }

  func testIllustrationTableWithSpouseRider(){
    var input:[String:Any] = getBaseProductInfo()
    let spbr = ["loadingPercentage":0,"loadingMile":0,"currency":"IDR","gender":"M","sumAssured":100000000,"age":31,"mode":1,"maxTerm":65] as [String : Any]
    input["spbr"] = spbr
    let output = AZCalculator.calculateIllustrationCalculation(input)
    
    let low = output["low"]
    if let year5 = low![24] as? NSNumber {
      XCTAssertTrue(year5 ==  5115106591  )
    }
  }
  
  
}
