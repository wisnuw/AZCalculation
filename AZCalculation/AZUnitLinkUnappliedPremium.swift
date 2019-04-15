//
//  AZUnitLinkUnappliedPremium.swift
//  AZCalculation
//
//  Created by Karthikaideepan on 08/05/18.
//  Copyright © 2018 allianz. All rights reserved.
//

import Foundation

/// Unapplied Premium Calculator
class AZUnitLinkUnappliedPremium: NSObject {
  
  var upModels = [AZUPModel]()
  var formulaList = AZFormulaList()
  
  
  /// Calculate unapplied premium by given input
  ///
  /// - Parameters:
  ///   - type: type of calculation event type
  ///   - input: Plan JSON contain Product,Rider and Person Information
  ///   - action: Calculation action
  /// - Returns: unapplied premium based on input
  func calculate(_ type:AZCalculationEventType, input:[String:Any], action:AZCalculationAction) -> NSDecimalNumber{
    var data = input
    if action == .product {
      var allRider:NSDecimalNumber! = NSDecimalNumber.init(value: 0)
      var cor1stYear:NSDecimalNumber! = NSDecimalNumber.init(value: 0)
      let appliedPremiumFormula = formulaList.formulas.first { (formula) -> Bool in
        return formula.name == "productApplaidPremium"
      }
      let medAssistanceApplaidPremium = formulaList.formulas.first { (formula) -> Bool in
        return formula.name == "medAssistanceApplaidPremium"
      }
      for model in upModels{
        if model.name != "product"
        {
          if var rider = input[model.name] as? [String:Any]{
            model.calculate(rider, action: action, code: model.name)
            rider["year1"] = model.year1
            rider["year2"] = model.year2
            cor1stYear = cor1stYear + model.year1
            if model.name == "medAssistance"{
              allRider = medAssistanceApplaidPremium!.excute(rider).value + allRider
            }else{
              allRider = appliedPremiumFormula!.excute(rider).value + allRider
            }
          }
        }else{
          model.calculate(input, action: action, code: model.name)
          data["year1"] = model.year1
          data["year2"] = model.year2
          data["coi"] = appliedPremiumFormula!.excute(data).value
        }
      }
      data["cor1stYear"] = cor1stYear
      data["allRider"] = allRider
      data = formulaList.excuteFormulaBySequence(data)
    }
    return data["unappliedPremium"] as! NSDecimalNumber
  }
}
