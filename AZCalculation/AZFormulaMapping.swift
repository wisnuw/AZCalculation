//
//  AZFormulaMapping.swift
//  AZCalculation
//
//  Created by Karthikaideepan on 08/05/18.
//  Copyright © 2018 allianz. All rights reserved.
//

import Foundation
import SwiftyJSON

class AZFormulaMapping: NSObject {

  
  /// load json form file path
  ///
  /// - parameter filePath: file path of json file
  ///
  /// - returns: JSON Object
  private func loadJson(filePath:String) -> JSON? {
    
    var path = Bundle.main.path(forResource: filePath, ofType: "json");
    if path == nil{
      let bundle = Bundle(for: type(of: self))
      //let bundle = Bundle(for: self.classForCoder)
      path = bundle.path(forResource: filePath, ofType: "json")!
    }
    let fileURL = URL(fileURLWithPath: path!)
    var content:JSON? = nil;
    do {
      let rawContent = try Data(contentsOf:fileURL)
      let rawString = String.init(data: rawContent, encoding: String.Encoding.utf8)
      content = JSON.init(parseJSON: rawString!)
    }
    catch let error as NSError {
      print(error.localizedDescription)
    }
    return content;
  }
  
  
  /// Create Unapplied premium formula from given path
  ///
  /// - Parameter fileName: un applied premium json file name
  /// - Returns: Unapplied premium model
  func loadUnappliedPremium(_ fileName:String) -> AZUnitLinkUnappliedPremium {
    
    let unappliedPremium = AZUnitLinkUnappliedPremium()
    if let content = loadJson(filePath: fileName){
     
      let formulaListJSON = content["formulaList"].arrayValue
      unappliedPremium.formulaList.formulas = createFormulaList(formulaListJSON)
      unappliedPremium.formulaList.squence = content["formulaSquence"].arrayObject as! [String]
      
       /*var upModelList = [AZUPModel]()
      let productJSON = content["product"]
      let productCalculation = createFormulaList([productJSON]).first!
      let upModel = AZUPModel()
      upModel.formulaList.append(productCalculation)
      upModelList.append(upModel)*/
      let riderListJSON = content["coiCorGroup"].arrayValue
      unappliedPremium.upModels = createFormulaListGroup(riderListJSON)

    }
    return unappliedPremium
    
  }
  
  
  func loadIllustrationTable(_ fileName:String) -> AZIllustrationCalculation{
    
    let calculation = AZIllustrationCalculation()
    if let content = loadJson(filePath: fileName){
      
      let formulaListJSON = content["formulaList"].arrayValue
      let formulaList = createFormulaList(formulaListJSON)
      calculation.formulaList.formulas = formulaList
      calculation.formulaList.squence = content["formulaSquence"].arrayObject as! [String]
      
      let tableFormulaListJSON = content["tableFormula"].arrayValue
      var tableFormulaList = createFormulaList(tableFormulaListJSON)
      
      let tableGroupListJSON = content["tableFormulaGroup"].arrayValue
      tableFormulaList.append(contentsOf: createFormulaGroup(tableGroupListJSON))
      
      var illustrationModelList = [AZIllustrationTableModel] ()
      for supportFormula in tableFormulaList{
        let illustrationModel = AZIllustrationTableModel()
        illustrationModel.formula = supportFormula
        illustrationModel.name = supportFormula.name
        illustrationModelList.append(illustrationModel)
      }
      calculation.tableModels = illustrationModelList
      let preFormulaListJSON = content["preFormulaList"].arrayValue
      let preFormulaList = createFormulaList(preFormulaListJSON)
      calculation.preConditionFormulaList = preFormulaList
      
      if let initalValues = content["initalValues"].dictionaryObject{
        calculation.initalValues = initalValues
      }
      
      
    }
     return calculation
  }
  ///  Create Formula list from array of formula JSON information
  ///
  /// - Parameter data: array of formula information
  /// - Returns: formula list
  func createFormulaList(_ data:[JSON]) -> [AZFormula] {
    var list = [AZFormula]()
    data.forEach { json in
      let formula = createformula(json)
      list.append(formula)
    }
    return list
  }
  
  private func createformula(_ data:JSON) -> AZFormula{
    let f = AZFormula()
    f.formula = data["formula"].stringValue
    f.name = data["name"].stringValue
    if let requiredInput = data["requiredInput"].arrayObject{
      f.requiredInput = requiredInput as? [String]
    }
    if let roundDecimal =  data["roundDecimal"].bool{
      f.roundDecimal = roundDecimal
    }
    if let roundUp =  data["roundUp"].bool{
      f.roundUp = roundUp
    }
    if let subFormulaData = data["subFormula"].array {
      let subFormula = createFormulaList(subFormulaData)
      f.subFormulas = subFormula
    }
    return f
  }
  
  func createFormulaGroup(_ data:[JSON])->[AZFormula]{
    var formulas = [AZFormula]()
    data.forEach { json in
      let names =  json["names"].arrayObject as! [String]
      for name in names {
        let formula = AZFormula()
        formula.name = name
        formula.formula = json["formula"].stringValue
        if let requiredInput = json["requiredInput"].arrayObject{
          formula.requiredInput = requiredInput as? [String]
        }
        if let roundDecimal =  json["roundDecimal"].bool{
          formula.roundDecimal = roundDecimal
        }
        if let roundUp =  json["roundUp"].bool{
          formula.roundUp = roundUp
        }
        if let subFormulaData = json["subFormula"].array {
          let subFormula = createFormulaList(subFormulaData)
          formula.subFormulas = subFormula
        }
        formulas.append(formula)
      }
    }
    return formulas
  }
  func createFormulaListGroup(_ data:[JSON])->[AZUPModel]{
    var modelList = [AZUPModel]()
    data.forEach { json in
      let names =  json["names"].arrayObject as! [String]
      for name in names {
        let model = AZUPModel()
        model.name = name
        let formulaList = json["formulaList"].arrayValue
        
        for formulaJSON in formulaList {
          let formula = AZFormula()
          formula.name = name
          formula.formula = formulaJSON["formula"].stringValue
          if let requiredInput = formulaJSON["requiredInput"].arrayObject{
            formula.requiredInput = requiredInput as? [String]
          }
          if let roundDecimal =  formulaJSON["roundDecimal"].bool{
            formula.roundDecimal = roundDecimal
          }
          if let roundUp =  formulaJSON["roundUp"].bool{
            formula.roundUp = roundUp
          }
          if let subFormulaData = formulaJSON["subFormula"].array {
            let subFormula = createFormulaList(subFormulaData)
            formula.subFormulas = subFormula
          }
          model.formulaList.append(formula)
        }
        modelList.append(model)
      }
    }
    return modelList
  }
}
