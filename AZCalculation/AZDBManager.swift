//
//  AZDBManager.swift
//  AZCalculation
//
//  Created by Karthikaideepan on 24/05/18.
//  Copyright © 2018 allianz. All rights reserved.
//

import Foundation

class AZDBManager: NSObject,AZSQLQuery {

  private func queryConfigFromDB(_ code:String) -> Dictionary<String,Any>
  {
    var result = Dictionary <String,Any>();
    let db = SQLiteDB.shared
    if(!db.isOpenStatus()){
      _ = db.openDB()
    }
    let query = "SELECT * FROM MR_UP_CALCULATION_CONFIG where code = '\(code)'"
    let dbRiderConfigs = db.query(sql:query)
    if let data = dbRiderConfigs.first{
      result = data
    }
    return result;
  }
  
  /// Retrieve the Configuration, configuration contains the way to retrieve r COR/COI and how to calculate the rider cost
  ///
  /// - Parameter code: required  Code
  /// - Returns: return the Dictionary containing the configuration
  func getCOI_CORConfig(forCode code: String) -> Dictionary<String,Any>{
    var dict = queryConfigFromDB(code)
    if dict.count != 0 {
      if let colParamsStr = dict["column_params"] as? String {
        let colParams: [String] = colParamsStr.components(separatedBy: ",")
        dict["column_params"] = colParams
      }
      else{
        dict["column_params"] = [String]()
      }
      
      if let whereParamsStr = dict["where_params"] as? String {
        let whereParams: [String] = whereParamsStr.components(separatedBy: ",")
        dict["where_params"] = whereParams
      }
      else{
        dict["where_params"] = [String]()
      }
      
    }
    return dict;
  }
  
  
  func getAllocationtValues(forCode code:String)->[NSDecimalNumber]{
    let db = SQLiteDB.shared
    if(!db.isOpenStatus()){
      _ = db.openDB()
    }
    let query = "SELECT allocation FROM UNITLINK_PRODUCT_ALLOCATION where productCode = '\(code)'"
    let result = getDoubleArrayFromQuery(query, withRounding: 0)
    return result
  }
  
  
  /// Retrieve COI or COR based on the provided value and the configuration
  ///
  /// - Parameters:
  ///   - forCode: code
  ///   - input: JSON
  ///   - noOfYears: require years
  /// - Returns: array of coi or cor
  func queryCOI_CORValue(forCode code: String, input:[String:Any],noOfYears:Int = 1) -> [NSDecimalNumber]
  {
    let riderDict = getCOI_CORConfig(forCode: code)
    if riderDict.count != 0{
      let whereString = getWhereClause(forCode: code, config: riderDict, age: input["age"] as! Int, noOfRows:noOfYears ,selectedAdditionalValue: input["selectedAdditionalValue"] as? String)
      let columnName = getColumnName(forCode: code, riderConfig: riderDict, input: input)
      let isRounding = riderDict["rounding_cor_is_needed"] as! Int
      let tableName = riderDict["table_name"] as! String
      
      let sqlString = "SELECT "+columnName+" FROM "+tableName+" WHERE "+whereString;
      let result = getDoubleArrayFromQuery(sqlString, withRounding: isRounding)
      return result;
    }
    var result = [NSDecimalNumber]()
    for _ in 1...noOfYears  {
      result.append(0);
    }
    return result
  }
  
  
  func getDoubleArrayFromQuery(_ query: String, withRounding isRounding:Int) -> [NSDecimalNumber] {

    let queryResult = queryBySQL(query,asArray: true)
    let resDouble = queryResult as? [Double]
    let resInt = queryResult as? [Int]
    let resString = queryResult as? [String]
    var resNumber = [NSDecimalNumber]()
    if resDouble == nil{
      if resInt != nil{
        resNumber = resInt!.map{ NSDecimalNumber(value: $0)}
      }
      else if resString != nil{
        resNumber = resString!.map{ NSDecimalNumber(string: $0)}
      }
      else{
        resNumber = [-1.0]
      }
    } else {
      resNumber = (resDouble!.map{ NSDecimalNumber(value: $0)})
    }
    
    if isRounding == 1 {
      resNumber = resNumber.map({ (value:NSDecimalNumber) -> NSDecimalNumber in
        return value.rounding(.plain, isDoubleMode: true, fraction: -2)
      })
    }
    return resNumber;
  }
  
  /// Get where clause from SQL Statement, where clause are generated based on the configuration and provided values
  ///
  /// - Parameters:
  ///   - code: the rider that are selected
  ///   - config: rider's configuration
  ///   - age: insured's age
  ///   - selectedAdditionalValue: additional value besides age
  /// - Returns: return Sqlite where clause in string
  func getWhereClause(forCode code:String, config: Dictionary<String,Any>,age: Int = 0, noOfRows:Int = 1,selectedAdditionalValue: String? = nil) -> String
  {
    let whereParams:NSArray = config["where_params"] as! NSArray
    var whereClause = "";
    var idx = 0;
    for param in whereParams{
      let paramValue = param as! String
      var argValue = ""
      if idx > 0{
        whereClause.append(" AND ")
      }
      
      switch paramValue {
      case "age":
        argValue = String(age)
        if noOfRows > 1 {
          let nextRows = String(age + noOfRows - 1)
          whereClause.append(paramValue + " BETWEEN " + "'"+argValue+"' AND '"+nextRows+"'")
        }
      default:
        if selectedAdditionalValue != nil{
          argValue = selectedAdditionalValue!
          whereClause.append(paramValue + " = "+"'"+argValue+"'")
        }
      }
      idx += 1
    }
    return whereClause;
  }
  
  /// Get POS Table Column name based on the configuration, and the provided value
  ///
  /// - Parameters:
  ///   - riderCode: rider code
  ///   - riderConfig: rider configuration in Dictionary (mandatory)
  ///   - gender: Insured's Gender, for payor rider it should take from payor and for spouse rider it should take from spouse
  ///   - currency: The currency of the product
  ///   - selectedAdditionalValue: Additional value to select the rider's column or where clause, e.g. for addb occupation class, for HnS the package selected.
  ///   - smoking: the smoking status of insured
  /// - Returns: return rider's COI value
  func getColumnName(forCode code:String, riderConfig: Dictionary<String,Any>, input:[String:Any]) -> String
  {
    let currency = input["currency"] as? String
    var smoking:Bool = false
    if let smokingValue  = input["smoking"]{
      if smokingValue is Bool{
        smoking = smokingValue as! Bool
      }else if smokingValue is NSNumber {
        smoking = (smokingValue as! NSNumber).boolValue
      }
    }
    let gender = input["gender"] as? String
    let selectedAdditionalValue  = input["selectedAdditionalValue"] as? String
    let columnParams:NSArray = riderConfig["column_params"] as! NSArray
    var columnArgs: Array<String> = Array();
    var columnName = ""
    let columnFormat = riderConfig["column_format"] as? String
    for param in columnParams{
      let paramValue = param as! String
      switch paramValue {
      case "currency":
        columnArgs.addValue(value: currency!)
      case "smoking":
        if smoking {
          columnArgs.addValue(value: "S")
        }
        else{
          columnArgs.addValue(value: "NS")
        }
      case "gender":
        if gender != nil{
          var genderStr = gender
          if code.lowercased() == "hsrider" || code.lowercased() == "smcr"{
            if genderStr == "F" {
              genderStr = "FEMALE"
            }
            else{
              genderStr = "MALE"
            }
            columnArgs.addValue(value: genderStr)
          }
          else{
            columnArgs.addValue(value: genderStr)
          }
        }
      default:
        if selectedAdditionalValue != nil{
          columnArgs.addValue(value: selectedAdditionalValue!)
        }
      }
    }
    columnName = columnNameFormat(format: columnFormat!, substrings: columnArgs)
    return columnName
  }
  /// Return formatted string already with all the argument without many extra unused characters
  ///
  /// - Parameters:
  ///   - format: String format containing %@
  ///   - substrings: The arguments passed to the format
  /// - Returns: Formatted string with arguments values
  private func columnNameFormat(format: String, substrings: [CVarArg]) -> String {
    return String(format: format, arguments: substrings)
  }
}

extension Array {
  mutating func addValue(value: Element?) {
    guard let newValue = value else { return }
    self.append(newValue)
  }
}
