//
//  AZFormula.swift
//  AZCalculation
//
//  Created by Karthikaideepan on 08/05/18.
//  Copyright © 2018 allianz. All rights reserved.
//

import Foundation

struct AZFormulaList {
  
  var formulas = [AZFormula]()
  var squence = [String]()
  
  func excuteFormulaBySequence(_ input:[String:Any]) -> [String:Any] {
    var data = input
    for formulaName in squence{
      let formula = formulas.first { (f) -> Bool in
        f.name == formulaName
      }
      let result = formula!.excute(data)
      //debugPrint("\(result.name) : \(result.value)")
      data[result.name] = result.value
    }
    return data
  }
}
class AZFormula: NSObject {
  
  var formula:String!
  var name:String = "name"
  var roundDecimal:Bool = false
  var roundUp:Bool = false
  var requiredInput:[String]?
  var subFormulas:[AZFormula]?
  
  /// Excute the formula by json
  ///
  /// - Parameter values: formula input
  /// - Returns: formula result
  @discardableResult
  func excute(_ values:[String:Any]) -> (name:String,value:NSDecimalNumber) {
    //debugPrint("Formula Name: \(name)")
    var data = values
    if let formulaArray = subFormulas {
      for subFormula in formulaArray {
        let result = subFormula.excute(data)
        data[result.name] = result.value
      }
    }
    if let value = formula.expression.expressionValue(with: data, context: nil) as? Double{
      var decimalValue = AZCalculator.calculator.formatNumber(value)
      if roundDecimal == true {
        decimalValue = decimalValue.rounding(isDoubleMode: true,fraction:-2)
      }else if roundUp == true {
        decimalValue = decimalValue.roundUp(toPlaces: 3)
      }
      return (name,decimalValue)
    }
    return (name,0)
  }
  
  
  /// Excute the formula by model
  ///
  /// - Parameter model: formula input model
  /// - Returns: formula result
  @discardableResult
  func excute(_ model:AZBaseModel) -> (name:String,value:NSDecimalNumber) {
    if let value = formula.expression.expressionValue(with: model, context: nil) as? NSDecimalNumber{
      return (name,value)
    }
    return (name,0)
  }
  
}
extension String {
  var expression: NSExpression {
    let exp = NSExpression(format: self)
    return exp
  }
}
