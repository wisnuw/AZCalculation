//
//  AZIllustrationTableModel.swift
//  AZCalculation
//
//  Created by Karthikaideepan on 31/05/18.
//  Copyright © 2018 allianz. All rights reserved.
//

import UIKit

class AZIllustrationTableModel: AZBaseModel {
  var formula:AZFormula!
  /// get coi, cor, allocation table values and calculate as per formula
  ///
  /// - Parameter input: table and formula information
  func generateTableValues(_ input:[String:Any], requiredYear:Int) -> [NSNumber]{
    var data = input
    var values:[NSNumber] = [NSNumber]()
    let manger = AZDBManager()
    var year = 0
    let age = input["age"] as! Int
    let maxTerm = input["maxTerm"] as! Int
    let calculationYear = maxTerm - age
    var tableValues = manger.queryCOI_CORValue(forCode: formula.name, input: input,noOfYears: calculationYear)
    if tableValues.count != calculationYear {
      let lastValue = tableValues.last!
      for _ in values.count..<calculationYear - 1{
        tableValues.append(lastValue)
      }
    }
    for value in tableValues {
      data["table"] = value
      data["firstYear"] = tableValues.first!
      data["year"] = year
      let formulaValue = formula.excute(data).value
      year = year + 1
      values.append(formulaValue)
    }
    for _ in values.count...requiredYear{
      values.append(0)
    }
    return values
  }
  
  func productAllocationTableValues(_ input:[String:Any]) -> [NSNumber] {
    var data = input
    var values:[NSNumber] = [NSNumber]()
    let manger = AZDBManager()
    let tableValues = manger.getAllocationtValues(forCode: input["allocationCode"] as! String)
    for value in tableValues {
      data["table"] = value
      values.append(formula.excute(data).value)
    }
    let lastValue = values.last!
    for _ in 15...99 {
      values.append(lastValue)
    }
    return values
  }
}
