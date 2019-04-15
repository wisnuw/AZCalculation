//
//  AZCalculator.swift
//  AZCalculation
//
//  Created by Karthikaideepan on 08/05/18.
//  Copyright © 2018 allianz. All rights reserved.
//

import Foundation

public enum AZCalculationEventType{
  case new
  case modified
  case added
}
public enum AZCalculationAction{
  case person
  case rider
  case product
  case none
}


/// Calculator for plan
public class AZCalculator: NSObject {

  static let calculator:AZCalculator = AZCalculator()
  private var dbName:String?
  private var productName:String?
  private var unappliedPremium:AZUnitLinkUnappliedPremium?
  private var illustrationCalculation:AZIllustrationCalculation?
  public static func setDataBaseName(_ name:String){
    calculator.dbName = name
  }
  var formatter:NumberFormatter = NumberFormatter()
  func formatNumber(_ double:Double)-> NSDecimalNumber {
    formatter.minimumFractionDigits = 0
    formatter.maximumFractionDigits = 9
    formatter.locale = Locale(identifier: "en_US_POSIX")
    let number = formatter.number(from:"\(double)")
    return NSDecimalNumber(decimal: number!.decimalValue)
  }
  /// Product change
  ///
  /// - Parameter product: new product name
  public static func changeProduct(_ product:String){
     calculator.productName = product
  }
  
  /// Calculate unapplied premium from input
  ///
  /// - Parameter input: plan json, it contain product, rider and person information
  /// - Returns: unapplied premium from input
  public static func calculateUnappliedPremium(_ input:[String:Any]) -> NSDecimalNumber?{
    
    if calculator.unappliedPremium == nil{
      calculator.unappliedPremium = AZFormulaMapping().loadUnappliedPremium("unappliedpremium")
    }
    let unappliedPremum = calculator.unappliedPremium?.calculate(AZCalculationEventType.modified, input: input, action: AZCalculationAction.product)
    return unappliedPremum
  }
  public static func setupIllustration(){
    if calculator.illustrationCalculation == nil{
      calculator.illustrationCalculation = AZFormulaMapping().loadIllustrationTable("illustrationCalculation")
    }
  }
  public static func calculateIllustrationCalculation(_ input:[String:Any])->[String:Array<Any>]{
    setupIllustration()
    return calculator.illustrationCalculation!.generateTable(input)
  }
}
