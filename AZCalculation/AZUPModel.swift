//
//  AZUPModel.swift
//  AZCalculation
//
//  Created by Karthikaideepan on 08/05/18.
//  Copyright © 2018 allianz. All rights reserved.
//

import Foundation

class AZBaseModel: NSObject {
  var name:String = "product"
}
class AZUPModel:AZBaseModel{
  var year1:NSDecimalNumber = 0
  var year2:NSDecimalNumber = 0
  var formulaList = [AZFormula]()
  
  
  /// Excute the formula by given input
  ///
  /// - Parameters:
  ///   - input: input JSON
  ///   - action: calculation action
  ///   - code: product or rider code
  func calculate(_ input:[String:Any], action:AZCalculationAction,code:String){
    var data = input
    let manger = AZDBManager()
    let values = manger.queryCOI_CORValue(forCode: code, input: input,noOfYears: 2)
    data["table"] = values[0]
    year1 = formulaList[0].excute(data).value
    let position = values.count == 1 ? 0 : 1
    data["table"] = values[position]
    year2 = formulaList[1].excute(data).value
    
  }
}


