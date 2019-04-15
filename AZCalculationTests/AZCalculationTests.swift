//
//  AZCalculationTests.swift
//  AZCalculationTests
//
//  Created by Karthikaideepan on 08/05/18.
//  Copyright © 2018 allianz. All rights reserved.
//

import XCTest
@testable import AZCalculation

class AZCalculationTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
  func baseProductInfo() -> [String:Any]{
    var input:[String:Any] = [String:Any]()
    input["age"] = 40
    input["gender"] = "M"
    input["currency"] = "IDR"
    input["premium"] =  2400000
    input["mode"] = 1
    input["maxSumAssuredMultiplier"] = 78.0
    input["sumAssured"] =   24000000
    input["loadingMile"] = 0
    input["loadingPercentage"] = 0
    input["productAdminFee"] = 27500.0
    return input
  }
  
  func testMultipleRider()  {
    
    var input:[String:Any] = [String:Any]()
    input["age"] = 40
    input["gender"] = "M"
    input["currency"] = "IDR"
    input["premium"] =  6500000
    input["mode"] = 12
    input["maxSumAssuredMultiplier"] = 78.0
    input["sumAssured"] =  4000000000
    input["loadingMile"] = 0
    input["loadingPercentage"] = 0
    input["productAdminFee"] = 27500.0
    let rider = ["loadingMile":0.0,"loadingPercentage":0.0,"gender":"M","sumAssured":1000000000.0,"age":40] as [String : Any]
    input["tpd"] = rider
    
    
    let premium = AZCalculator.calculateUnappliedPremium(input)
    XCTAssertEqual(round(premium!.doubleValue),   25947949 )
    
  }
  func testUnappliedPremiumWithMile()  {
    var input:[String:Any] = [String:Any]()
    input["age"] = 40
    input["gender"] = "M"
    input["currency"] = "IDR"
    input["premium"] =  70000000
    input["mode"] = 1
    input["maxSumAssuredMultiplier"] = 78.0
    input["sumAssured"] =  1500000000
    input["loadingMile"] = 4
    input["loadingPercentage"] = 0
    input["productAdminFee"] = 27500.0
    let premium = AZCalculator.calculateUnappliedPremium(input)
    XCTAssertEqual(round(premium!.doubleValue), 48872413 )
  }
  func testUnappliedPremium()  {
    let input = baseProductInfo()
    let premium = AZCalculator.calculateUnappliedPremium(input)
    XCTAssertEqual(round(premium!.doubleValue), 1403083 )
  }
  func testUnappliedPremiumMedicalRider()  {
    var input:[String:Any] = [String:Any]()
    input["age"] = 5
    input["gender"] = "F"
    input["currency"] = "IDR"
    input["premium"] =  20000000.0
    input["mode"] = 1
    input["maxSumAssuredMultiplier"] = 150.0
    input["sumAssured"] =  2500000000
    input["loadingMile"] = 0
    input["loadingPercentage"] = 0
    input["productAdminFee"] = 27500.0
    let rider = ["age":5] as [String : Any]
    input["medAssistance"] = rider
    let premium = AZCalculator.calculateUnappliedPremium(input)
    
    XCTAssertEqual(round(premium!.doubleValue),   3261333)
  }
  
  func testUnappliedPremiumWithAddbRider() {
    
    var input:[String:Any] = [String:Any]()
    input["age"] = 5
    input["gender"] = "F"
    input["currency"] = "IDR"
    input["premium"] =  20000000.0
    input["mode"] = 1
    input["maxSumAssuredMultiplier"] = 150.0
    input["sumAssured"] =  2500000000
    input["loadingMile"] = 0
    input["loadingPercentage"] = 0
    input["productAdminFee"] = 27500.0
    let rider = ["loadingMile":0,"loadingPercentage":0,"sumAssured":8000000,"age":5,"selectedAdditionalValue":"1"] as [String : Any]
    input["addb"] = rider
    let premium = AZCalculator.calculateUnappliedPremium(input)
    
    XCTAssertEqual(round(premium!.doubleValue),     3322533  )
    
  }
  func testUnappliedPremiumWithFlexicareRider() {
    
    var input = baseProductInfo()
    input["premium"] = 24000000.0
    input["sumAssured"] =  1000000000.0
    let fam1 = ["loadingPercentage":0.0,"sumAssured":10,"age":40,"currency":"IDR"] as [String : Any]
    input["fam1"] = fam1
    let fam2 = ["loadingPercentage":0.0,"sumAssured":10,"age":28,"currency":"IDR"] as [String : Any]
    input["fam2"] = fam2
    let fam3 = ["loadingPercentage":0.0,"sumAssured":10,"age":20,"currency":"IDR"] as [String : Any]
    input["fam3"] = fam3
    let fam4 = ["loadingPercentage":0.0,"sumAssured":10,"age":38,"currency":"IDR"] as [String : Any]
    input["fam4"] = fam4
    let fam5 = ["loadingPercentage":0.0,"sumAssured":10,"age":48,"currency":"IDR"] as [String : Any]
    input["fam5"] = fam5
    let premium = AZCalculator.calculateUnappliedPremium(input)
    XCTAssert(round(premium!.doubleValue) == 1025908 )
    
  }
  func testUnappliedPremiumWithCI100Rider() {
    
    var input:[String:Any] = [String:Any]()
    input["age"] = 5
    input["gender"] = "F"
    input["currency"] = "IDR"
    input["premium"] =  20000000.0
    input["mode"] = 1
    input["maxSumAssuredMultiplier"] = 150.0
    input["sumAssured"] =  2500000000
    input["loadingMile"] = 0
    input["loadingPercentage"] = 0
    input["productAdminFee"] = 27500.0
    let rider = ["loadingMile":0,"loadingPercentage":0,"gender":"F","sumAssured":8000000,"age":5,"smoking":false] as [String : Any]
    input["ci 100s"] = rider
    let premium = AZCalculator.calculateUnappliedPremium(input)
    XCTAssertEqual(round(premium!.doubleValue),  3326933)
    
  }
  func testUnappliedPremiumWithCI100Age40Rider() {
    
    var input:[String:Any] = baseProductInfo()
    input["premium"] =  70000000.0
    input["sumAssured"] =   1500000000.0
    let rider = ["loadingMile":0,"loadingPercentage":0,"gender":"M","sumAssured": 120000000 ,"age":40,"smoking":false] as [String : Any]
    input["ci 100s"] = rider
    let premium = AZCalculator.calculateUnappliedPremium(input)
    XCTAssertEqual(round(premium!.doubleValue),50182431 )
    
  }
  
  func testUnappliedPremiumWithCIPlusRider() {
    
    var input:[String:Any] = [String:Any]()
    input["age"] = 5
    input["gender"] = "F"
    input["currency"] = "IDR"
    input["premium"] =  20000000.0
    input["mode"] = 1
    input["maxSumAssuredMultiplier"] = 150.0
    input["sumAssured"] =  2500000000
    input["loadingMile"] = 0
    input["loadingPercentage"] = 0
    input["productAdminFee"] = 27500.0
    let rider = ["loadingMile":0,"loadingPercentage":0,"gender":"F","sumAssured":8000000,"age":5] as [String : Any]
    input["ci plus"] = rider
    let premium = AZCalculator.calculateUnappliedPremium(input)
     XCTAssertEqual(round(premium!.doubleValue), 3326053)
    
  }
  func testUnappliedPremiumWithCIAccRider() {
    var input:[String:Any] = [String:Any]()
    input["age"] = 5
    input["gender"] = "F"
    input["currency"] = "IDR"
    input["premium"] =  20000000.0
    input["mode"] = 1
    input["maxSumAssuredMultiplier"] = 150.0
    input["sumAssured"] =  2500000000
    input["loadingMile"] = 0
    input["loadingPercentage"] = 0
    input["productAdminFee"] = 27500.0
    let rider = ["loadingMile":0,"loadingPercentage":0,"gender":"F","sumAssured":8000000,"age":5] as [String : Any]
    input["ci"] = rider
    let premium = AZCalculator.calculateUnappliedPremium(input)
     XCTAssertEqual(round(premium!.doubleValue), 3327493 )
    
  }
  func testUnappliedPremiumWithTpdRider() {
    
    var input:[String:Any] = [String:Any]()
    input["age"] = 18
    input["gender"] = "F"
    input["currency"] = "IDR"
    input["premium"] =  20000000.0
    input["mode"] = 1
    input["maxSumAssuredMultiplier"] = 125.0
    input["sumAssured"] =   1500000000
    input["loadingMile"] = 0
    input["loadingPercentage"] = 0
    input["productAdminFee"] = 27500.0
    let rider = ["loadingMile":0,"loadingPercentage":0,"gender":"F","sumAssured":20000000,"age":18] as [String : Any]
    input["tpd"] = rider
    let premium = AZCalculator.calculateUnappliedPremium(input)
    XCTAssertEqual(round(premium!.doubleValue), 7992400 )
    
  }
  func testUnappliedPremiumWithSmartMedCancerRider() {
    
    var input = baseProductInfo()
    input["premium"] = 24000000.0
    input["sumAssured"] =  1000000000.0
    let smcr = ["loadingPercentage":0,"gender":"M","selectedAdditionalValue":"2","age":40] as [String : Any]
    input["smcr"] = smcr
    let premium = AZCalculator.calculateUnappliedPremium(input)
    XCTAssertEqual(round(premium!.doubleValue), 8529287 )
    
  }
  func testUnappliedPremiumWithHSRider() {
    var input = baseProductInfo()
    input["premium"] = 24000000.0
    input["sumAssured"] =  1000000000.0
    let hs = ["loadingPercentage":0,"gender":"MALE","selectedAdditionalValue":"100","age":40] as [String : Any]
    input["hsrider"] = hs
    let premium = AZCalculator.calculateUnappliedPremium(input)
    XCTAssertEqual(round(premium!.doubleValue),10445087)
    
  }
  func testUnappliedPayorRider(){
    var input = baseProductInfo()
    input["premium"] = 24000000.0
    input["sumAssured"] =  1000000000.0
    let pbr = ["loadingPercentage":0,"loadingMile":0,"currency":"IDR","gender":"M","sumAssured":24000000.0,"age":40,"mode":1] as [String : Any]
    input["pbr"] = pbr
    let premium = AZCalculator.calculateUnappliedPremium(input)
    XCTAssertEqual(round(premium!.doubleValue), 10104287)
  }
  func testUnappliedPayorProtectionRider(){
    var input = baseProductInfo()
    input["premium"] = 24000000.0
    input["sumAssured"] =  1000000000.0
    let ppr = ["loadingPercentage":0,"loadingMile":0,"currency":"IDR","gender":"M","sumAssured":24000000.0,"age":40,"mode":1] as [String : Any]
    input["ppr"] = ppr
    let premium = AZCalculator.calculateUnappliedPremium(input)
    XCTAssertEqual(round(premium!.doubleValue),  10385087  )
  }
  func testUnappliedSpouseRider(){
    var input = baseProductInfo()
    input["premium"] = 24000000.0
    input["sumAssured"] =  1000000000.0
    let spbr = ["loadingPercentage":0,"loadingMile":0,"currency":"IDR","gender":"F","sumAssured":24000000.0,"age":61,"mode":1] as [String : Any]
    input["spbr"] = spbr
    let premium = AZCalculator.calculateUnappliedPremium(input)
    XCTAssertEqual(round(premium!.doubleValue),8969087)
  }
  func testUnappliedSpouseProtectionRider(){
    var input = baseProductInfo()
    input["premium"] = 24000000.0
    input["sumAssured"] =  1000000000.0
    let sppr = ["loadingPercentage":0,"loadingMile":0,"currency":"IDR","gender":"F","sumAssured":24000000.0,"age":61,"mode":1] as [String : Any]
    input["sppr"] = sppr
    let premium = AZCalculator.calculateUnappliedPremium(input)
    XCTAssertEqual(round(premium!.doubleValue), 10051487 )
  }
  func testExpressionIsMaximumFuc()
  {
    let value = ["a":320,"b":434]
    let functionExpression = NSExpression(format:"FUNCTION(a, 'isMaximum:',b)")
    let functionValue = functionExpression.expressionValue(with: value, context: nil) as! Double
    XCTAssertEqual(functionValue, 434)
  }
  
  func testUnappliedPremiumWithFlexiCIRider() {
    
    var input:[String:Any] = [String:Any]()
    input["age"] = 40
    input["gender"] = "M"
    input["currency"] = "IDR"
    input["premium"] =  70000000
    input["mode"] = 1
    input["maxSumAssuredMultiplier"] = 78.0
    input["sumAssured"] =  1500000000
    input["loadingMile"] = 0
    input["loadingPercentage"] = 0
    input["productAdminFee"] = 27500.0
    let rider = ["loadingMile":0,"loadingPercentage":0.25,"sumAssured":8000000,"age":40,"selectedAdditionalValue":"SILVER","gender":"M","smoking":false] as [String : Any]
    input["flexci"] = rider
    let premium = AZCalculator.calculateUnappliedPremium(input)
    XCTAssert(round(premium!.doubleValue) ==   50734831 )
    
  }
  func testUnappliedPremiumWithFlexiCIGenderSpecificRider() {
    
    var input:[String:Any] = [String:Any]()
    input["age"] = 40
    input["gender"] = "M"
    input["currency"] = "IDR"
    input["premium"] =  70000000
    input["mode"] = 1
    input["maxSumAssuredMultiplier"] = 78.0
    input["sumAssured"] =  1500000000
    input["loadingMile"] = 0
    input["loadingPercentage"] = 0
    input["productAdminFee"] = 27500.0
    let rider = ["loadingMile":0,"loadingPercentage":0.25,"sumAssured":8000000,"age":40,"selectedAdditionalValue":"SILVER","gender":"M","smoking":false] as [String : Any]
    input["flexci"] = rider
    let genderSpecific = ["loadingMile":0,"loadingPercentage":0.25,"sumAssured":8000000,"age":40,"gender":"M","smoking":false] as [String : Any]
    input["genderSpecific"] = genderSpecific
    let premium = AZCalculator.calculateUnappliedPremium(input)
    XCTAssert(round(premium!.doubleValue) == 50734331)
  }
  func testUnappliedPremiumWithFlexiCI_GenderSpecific_PowerResetECRider() {
    
    var input:[String:Any] = [String:Any]()
    input["age"] = 40
    input["gender"] = "M"
    input["currency"] = "IDR"
    input["premium"] =  70000000
    input["mode"] = 1
    input["maxSumAssuredMultiplier"] = 78.0
    input["sumAssured"] =  1500000000
    input["loadingMile"] = 0
    input["loadingPercentage"] = 0
    input["productAdminFee"] = 27500.0
    let rider = ["loadingMile":0,"loadingPercentage":0.25,"sumAssured":8000000,"age":40,"selectedAdditionalValue":"GOLD","gender":"M","smoking":false] as [String : Any]
    input["flexci"] = rider
    let genderSpecific = ["loadingMile":0,"loadingPercentage":0.25,"sumAssured":8000000,"age":40,"gender":"M","smoking":false] as [String : Any]
    input["genderSpecific"] = genderSpecific
    
    let powerResetEC = ["loadingMile":0,"loadingPercentage":0.25,"sumAssured":8000000,"age":40,"gender":"M","smoking":false] as [String : Any]
    input["powerResetEC"] = powerResetEC
    
    let premium = AZCalculator.calculateUnappliedPremium(input)
    XCTAssert(round(premium!.doubleValue) ==  50726731 )
  }
  func testUnappliedPremiumWithFlexiCI_GenderSpecific_PowerResetEC_ContinuousCancerRider() {
    
    var input:[String:Any] = [String:Any]()
    input["age"] = 40
    input["gender"] = "M"
    input["currency"] = "IDR"
    input["premium"] =  70000000
    input["mode"] = 1
    input["maxSumAssuredMultiplier"] = 78.0
    input["sumAssured"] =  1500000000
    input["loadingMile"] = 0
    input["loadingPercentage"] = 0
    input["productAdminFee"] = 27500.0
    let rider = ["loadingMile":0,"loadingPercentage":0.25,"sumAssured":8000000,"age":40,"selectedAdditionalValue":"GOLD","gender":"M","smoking":false] as [String : Any]
    input["flexci"] = rider
    let genderSpecific = ["loadingMile":0,"loadingPercentage":0.25,"sumAssured":8000000,"age":40,"gender":"M","smoking":false] as [String : Any]
    input["genderSpecific"] = genderSpecific
    
    let powerResetEC = ["loadingMile":0,"loadingPercentage":0.25,"sumAssured":8000000,"age":40,"gender":"M","smoking":false] as [String : Any]
    input["powerResetEC"] = powerResetEC
    
    let continuousCancer = ["loadingMile":0,"loadingPercentage":0.25,"sumAssured":8000000,"age":40,"gender":"M","smoking":false] as [String : Any]
    input["continuousCancer"] = continuousCancer
    
    let premium = AZCalculator.calculateUnappliedPremium(input)
    XCTAssert(round(premium!.doubleValue) == 50725631)
  }
  
  
  func testUnappliedPremiumPACHL_1805(){
    
    var input:[String:Any] = [String:Any]()
    input["age"] = 5
    input["gender"] = "F"
    input["currency"] = "IDR"
    input["premium"] =  20000000.0
    input["mode"] = 1
    input["maxSumAssuredMultiplier"] = 150.0
    input["sumAssured"] =  2500000000
    input["loadingMile"] = 0
    input["loadingPercentage"] = 0
    input["productAdminFee"] = 27500.0
    /*let addb = ["loadingMile":0,"loadingPercentage":0,"sumAssured":8000000,"age":5,"selectedAdditionalValue":"1"] as [String : Any]
    input["addb"] = addb
    let medAssistance = ["age":5] as [String : Any]
    input["medAssistance"] = medAssistance
    let hs = ["loadingPercentage":0,"gender":"FEMALE","selectedAdditionalValue":"100","age":5] as [String : Any]
    input["hsrider"] = hs
    
    let fam1 = ["loadingPercentage":0.0,"sumAssured":1,"age":5,"currency":"IDR"] as [String : Any]
    input["fam1"] = fam1*/
    
    let flexci = ["loadingMile":0.0,"loadingPercentage":0.0,"sumAssured":8000000,"age":5, "selectedAdditionalValue":"GOLD", "gender":"F","smoking":false] as [String : Any]
    input["flexci"] = flexci
    
    /*let genderSpecific = ["loadingMile":0,"loadingPercentage":0.25,"sumAssured":8000000,"age":5,"gender":"F","smoking":false] as [String : Any]
    input["genderSpecific"] = genderSpecific
    
    let continuousCancer = ["loadingMile":0,"loadingPercentage":0.25,"sumAssured":8000000,"age":5,"gender":"F","smoking":false] as [String : Any]
    input["continuousCancer"] = continuousCancer
    
    let pbr = ["loadingPercentage":0,"loadingMile":0,"currency":"IDR","gender":"M","sumAssured":21000000.0,"age":31,"mode":1] as [String : Any]
    
    input["pbr"] = pbr
    
    let ppr = ["loadingPercentage":0,"loadingMile":0,"currency":"IDR","gender":"M","sumAssured":21000000.0,"age":31,"mode":1] as [String : Any]
    input["ppr"] = ppr
    
    
    let spbr = ["loadingPercentage":0,"loadingMile":0,"currency":"IDR","gender":"F","sumAssured":21000000.0,"age":32,"mode":1] as [String : Any]
    input["spbr"] = spbr
    
    let sppr = ["loadingPercentage":0,"loadingMile":0,"currency":"IDR","gender":"F","sumAssured":21000000.0,"age":32,"mode":1] as [String : Any]
    input["sppr"] = sppr*/
    
    
    let premium = AZCalculator.calculateUnappliedPremium(input)
    XCTAssert(round(premium!.doubleValue) ==   3327573  )
    
  }
  
  
  func testUnappliedPremiumAllisya()  {
    var input:[String:Any] = [String:Any]()
    input["age"] = 12
    input["gender"] = "F"
    input["currency"] = "IDR"
    input["premium"] =  1700000.0
    input["mode"] = 12
    input["maxSumAssuredMultiplier"] = 147.0588235
    input["sumAssured"] =   1000000000.0
    input["loadingMile"] = 0
    input["loadingPercentage"] = 0
    input["productAdminFee"] =  35000.0
    let premium = AZCalculator.calculateUnappliedPremium(input)
    XCTAssertEqual(round(premium!.doubleValue),  13600000)
  }
  func testUnappliedPremiumPayorBenfitUATissue()  {
    var input:[String:Any] = [String:Any]()
    input["age"] = 30
    input["gender"] = "M"
    input["currency"] = "IDR"
    input["premium"] =  1000000.0
    input["mode"] = 12
    input["maxSumAssuredMultiplier"] = 110
    input["sumAssured"] =   700000000.0
    input["loadingMile"] = 0
    input["loadingPercentage"] = 0
    input["productAdminFee"] =  27500.0
    let pbr = ["loadingPercentage":0,"loadingMile":0,"currency":"IDR","gender":"M","sumAssured":1000000.0,"age":30,"mode":12] as [String : Any]
    input["pbr"] = pbr
    let premium = AZCalculator.calculateUnappliedPremium(input)
    XCTAssertEqual(round(premium!.doubleValue),    5404764 )
  }
  func testUnappliedFlexicareFamilyUATissue()  {
    var input:[String:Any] = [String:Any]()
    input["age"] = 30
    input["gender"] = "M"
    input["currency"] = "IDR"
    input["premium"] =  1000000.0
    input["mode"] = 12
    input["maxSumAssuredMultiplier"] = 110
    input["sumAssured"] =   700000000.0
    input["loadingMile"] = 0
    input["loadingPercentage"] = 0
    input["productAdminFee"] =  27500.0
    let fam1 = ["loadingPercentage":0.0,"sumAssured":10,"age":30,"currency":"IDR"] as [String : Any]
    input["fam1"] = fam1
    let premium = AZCalculator.calculateUnappliedPremium(input)
    XCTAssertEqual(round(premium!.doubleValue), 4391364)
  }
  
  func testUnappliedPremiumAllisyaMultiRiderIssue()  {
    var input:[String:Any] = [String:Any]()
    input["age"] = 5
    input["gender"] = "M"
    input["currency"] = "IDR"
    input["premium"] =  6500000.0
    input["mode"] = 1
    input["maxSumAssuredMultiplier"] = 150
    input["sumAssured"] =   400000000.0
    input["loadingMile"] = 0
    input["loadingPercentage"] = 0
    input["productAdminFee"] =  35000.0
    let ciPlus = ["loadingMile":0,"loadingPercentage":0,"gender":"M","sumAssured":8000000,"age":5] as [String : Any]
    input["ci plus"] = ciPlus
    
    
    let ci = ["loadingMile":0,"loadingPercentage":0,"gender":"M","sumAssured":8000000,"age":5] as [String : Any]
    input["ci"] = ci
    
    let addb = ["loadingMile":0,"loadingPercentage":0,"sumAssured":8000000,"age":5,"selectedAdditionalValue":"1"] as [String : Any]
    input["addb"] = addb
    
    let term70 = ["loadingMile":0,"loadingPercentage":0,"gender":"M","sumAssured":20000000,"age":5] as [String : Any]
    input["term70"] = term70
    
    let hs = ["loadingPercentage":0,"gender":"MALE","selectedAdditionalValue":"100","age":5] as [String : Any]
    input["hsrider"] = hs
    
    let ci100 = ["loadingMile":0,"loadingPercentage":0,"gender":"M","sumAssured":8000000,"age":5,"smoking":false] as [String : Any]
    input["ci 100s"] = ci100
    
    let pbr = ["loadingPercentage":0,"loadingMile":0,"currency":"IDR","gender":"M","sumAssured":(6500000.0 + 1000000),"age":31,"mode":1] as [String : Any]
    input["pbr"] = pbr
    
    let spbr = ["loadingPercentage":0,"loadingMile":0,"currency":"IDR","gender":"F","sumAssured":(6500000.0 + 1000000),"age":32,"mode":1] as [String : Any]
    input["spbr"] = spbr
    
    let sppr = ["loadingPercentage":0,"loadingMile":0,"currency":"IDR","gender":"F","sumAssured":(6500000.0 + 1000000),"age":32,"mode":1] as [String : Any]
    input["sppr"] = sppr
    
    let fam1 = ["loadingPercentage":0.0,"sumAssured":8,"age":5,"currency":"IDR"] as [String : Any]
    input["fam1"] = fam1
    
    let premium = AZCalculator.calculateUnappliedPremium(input)
    XCTAssertEqual(round(premium!.doubleValue),   120564) // 3833333, 3823413 , 3815893,  3805093 ,  3788693 ,  3169493,  3162933 , 3013683 ,  2789327,  2438830   final  120564
  }
  
  func testMytoolBox() {
  var input:[String:Any] = [String:Any]()
    input["age"] = 21;
    input["currency"] = "IDR";
    input["gender"] = "Male";
    input["loadingMile"] = 0;
    input["loadingPercentage"] = 0;
    input["maxSumAssuredMultiplier"] = 90;
    input["mode"] = 1;
    input["premium"] = 6000000;
    input["smoking"] = false
    input["sumAssured"] = 30000000;
    input["productAdminFee"] = 35000
    let addb = ["loadingMile":0,"loadingPercentage":0,"sumAssured":8000000,"age":21,"selectedAdditionalValue":"1"] as [String : Any]
    input["addb"] = addb
    let fam1 = ["loadingPercentage":0.0,"sumAssured":10,"age":21,"currency":"IDR"] as [String : Any]
    input["fam1"] = fam1
    
    let ciPlus = ["loadingMile":0,"loadingPercentage":0,"gender":"Male","sumAssured":8000000,"age":21] as [String : Any]
    input["ci plus"] = ciPlus
    
    let ci100 = ["loadingMile":0,"loadingPercentage":0,"gender":"Female","sumAssured":8000000,"age":5,"smoking":false] as [String : Any]
    input["ci 100s"] = ci100
    
    let ci = ["loadingMile":0,"loadingPercentage":0,"gender":"Female","sumAssured":8000000,"age":21] as [String : Any]
    input["ci"] = ci
    
    
    let tpd = ["loadingMile":0,"loadingPercentage":0,"gender":"Female","sumAssured":20000000,"age":18] as [String : Any]
    input["tpd"] = tpd
    
    let tpda = ["loadingMile":0,"loadingPercentage":0,"gender":"Female","sumAssured":20000000,"age":18] as [String : Any]
    input["tpda"] = tpda
    
    let medAssistance = ["age":5] as [String : Any]
    input["medAssistance"] = medAssistance
    
    let hs = ["loadingPercentage":0,"gender":"Male","selectedAdditionalValue":"100","age":40] as [String : Any]
    input["hsrider"] = hs
    
    
    let premium = AZCalculator.calculateUnappliedPremium(input)
    
    
    
    debugPrint(premium);
  }
}
