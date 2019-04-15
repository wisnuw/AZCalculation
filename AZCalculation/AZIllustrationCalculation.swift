//
//  AZIllustrationCalculation.swift
//  AZCalculation
//
//  Created by Karthikaideepan on 30/05/18.
//  Copyright © 2018 allianz. All rights reserved.
//

import Foundation

/// Illustration Table
class AZIllustrationCalculation:NSObject{
  
  var formulaList:AZFormulaList = AZFormulaList()
  
  var tableModels = [AZIllustrationTableModel]()
  
  var preConditionFormulaList = [AZFormula]()

  var initalValues = [String:Any]()
  
  
  /// Generte illustraion table low, medium, high
  ///
  /// - Parameter input:
  func generateTable(_ input:[String:Any]) -> [String:Array<Any>]{
    var data = input
    var illustraionTable = [String:Array<Any>]()

    data.merge(initalValues) { (key, value) -> Any in
      return value
    }
    let types = ["low","mediam","high"]
    for type in types {
      
      var tableData = Array<Any>()
      
      let age = data["age"] as! Int
      let calculationYear = 99 - age
      let allTableValues:[String:[NSNumber]] = calculateTableFormula(data,illustrationYear:calculationYear)
      for year in 0...calculationYear {
        data["year"] = year
        allTableValues.forEach { (name:String, values:[NSNumber]) in
          data[name] = values[year]
        }
        for formula in preConditionFormulaList {
          let result = formula.excute(data)
          data[result.name] = result.value
        }
        /*if year == 1 {
          debugPrint("Something wrong")
        }*/
        for i in 0...11 {
          data = formulaList.excuteFormulaBySequence(data)
          if i == 0 {
            for formula in preConditionFormulaList {
              data[formula.name] = 0
            }
          }
        }
        if let unitValueEOM = data["unitValueEOM"] as? NSNumber{
          tableData.append(round(unitValueEOM.doubleValue))
        }
      }
      illustraionTable[type] = tableData
    }
    
    return illustraionTable
  }
  
  
  private func calculateTableFormula(_ input:[String:Any], illustrationYear:Int) -> [String:[NSNumber]]{
    var allTableValues = [String:[NSNumber]]()
    
    for model in tableModels {
      var formulaData = input[model.name] as? [String:Any]
      var tableValues:[NSNumber]!
      if formulaData != nil {
        let additional = sperateRequiredInput(FromInput: input, forFormula: model.formula)
        formulaData!.merge(additional) { (key, value) -> Any in
          return value
        }
        if model.name == "allocation"{
          tableValues = model.productAllocationTableValues(formulaData!)
          allTableValues["\(model.name)_value"] = tableValues
        }else{
          tableValues = model.generateTableValues(formulaData!,requiredYear: illustrationYear)
          allTableValues["\(model.name)_value".replacingOccurrences(of: " ", with: "")] = tableValues
        }
      }
    }
    return allTableValues
  }
  
  /// create new input by required input from formula
  ///
  /// - Parameters:
  ///   - input: <#input description#>
  ///   - formula: <#formula description#>
  /// - Returns: <#return value description#>
  private func sperateRequiredInput(FromInput input:[String:Any],forFormula formula:AZFormula) -> [String:Any]
  {
    var data = [String:Any]()
    if let requiredInput = formula.requiredInput{
      for required in requiredInput{
        if let value = input[required] {
          data[required] = value
        }
      }
    }
    return data
  }
}
