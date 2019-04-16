//
//  AZDecimalNumber..swift
//  asntoolbox
//
//  Created by sanjay on 8/16/17.
//  Copyright © 2017 PT. Asuransi Allianz Life Indonesia. All rights reserved.
//

import Foundation


extension NSDecimalNumber: Comparable {}

public func ==(lhs: NSDecimalNumber, rhs: NSDecimalNumber) -> Bool {
  return lhs.compare(rhs) == .orderedSame
}

public func <(lhs: NSDecimalNumber, rhs: NSDecimalNumber) -> Bool {
  return lhs.compare(rhs) == .orderedAscending
}

// MARK: - Arithmetic Operators

public prefix func -(value: NSDecimalNumber) -> NSDecimalNumber {
  return value.multiplying(by: NSDecimalNumber(mantissa: 1, exponent: 0, isNegative: true))
}

public func +(lhs: NSDecimalNumber, rhs: NSDecimalNumber) -> NSDecimalNumber {
  return lhs.adding(rhs)
}

public func -(lhs: NSDecimalNumber, rhs: NSDecimalNumber) -> NSDecimalNumber {
  return lhs.subtracting(rhs)
}

public func *(lhs: NSDecimalNumber, rhs: NSDecimalNumber) -> NSDecimalNumber {
  return lhs.multiplying(by: rhs)
}

public func /(lhs: NSDecimalNumber, rhs: NSDecimalNumber) -> NSDecimalNumber {
  return lhs.dividing(by: rhs)
}

public func ^(lhs: NSDecimalNumber, rhs: Int) -> NSDecimalNumber {
  return lhs.raising(toPower: rhs)
}

public func += ( lhs: inout NSDecimalNumber, rhs: NSDecimalNumber) {
  lhs = lhs + rhs
}

public func +(lhs: Decimal, rhs: Decimal) -> Decimal{
  var first = lhs
  let second = rhs
  first += second
  return first
}

public extension NSDecimalNumber {
  
    func rounding(_ mode:NSDecimalNumber.RoundingMode = .plain, isDoubleMode:Bool = false, fraction:Int = 0) -> NSDecimalNumber {
    if isDoubleMode {
        return self.roundDouble(Double(truncating: self), fractions: fraction)
    }
    
    return self.rounding(accordingToBehavior: NSDecimalNumberHandler(roundingMode: mode, scale: 0, raiseOnExactness: false, raiseOnOverflow: false, raiseOnUnderflow: false, raiseOnDivideByZero: false))
  }
  
    func roundUp(toPlaces places: Double) -> NSDecimalNumber{
    guard places >= 0 else { return self }
    let powValue:Double = pow(10.0, places)
    let roundup  =  (self.doubleValue / powValue).rounded(.up) * powValue
    return NSDecimalNumber.init(value: roundup)
  }
    func roundDouble(_ paramDouble:Double, fractions paramInt:Int) -> NSDecimalNumber {
    var param = paramDouble
    let l1:Int64 = Int64(Darwin.pow(10.0, Double(abs(paramInt))))
    var l2:Int64 = 0
    var l3:Int64 = 0
    
    if (paramDouble > 0.0)
    {
      if (paramInt > 0)
      {
        l2 = Int64(paramDouble / Double(l1 / 10))
        l3 = Int64((paramDouble / Double(l1)) * 10)
        if (l2 - l3 >= 5) { l3 += 10 }
        param = Double(l3) * Double(l1 / 10)
      }
      else if (paramInt < 0)
      {
        l2 = Int64(paramDouble * (Double(l1) * 10.0))
        l3 = Int64(paramDouble * Double(l1)) * 10
        if (l2 - l3 >= 5) { l3 += 10}
        param = Double(l3) / Double(l1 * 10)
      }
      else
      {
        param = round(paramDouble)
      }
    }
    else if (paramDouble < 0.0)
    {
      if (paramInt > 0)
      {
        l2 = Int64(floor(paramDouble / Double(l1 / 10)))
        l3 = Int64(paramDouble / Double(l1)) * 10
        if l3 - l2 > 5 {
          l3 -= 10
        }
        param = Double(l3) * Double(l1 / 10)
      }
      else if (paramInt < 0)
      {
        l2 = Int64(floor(paramDouble * Double(l1) * 10))
        l3 = Int64(paramDouble * Double(l1)) * 10
        if l3 - l2 > 5 {
          l3 -= 10
        }
        param = Double(l3) / Double(l1 * 10)
      }
      else
      {
        param = round(paramDouble)
      }
    }
    return NSDecimalNumber(value: param)
  }
  
  
  func roundingWithScale(_ mode:NSDecimalNumber.RoundingMode = .bankers, scale:Int16) -> NSDecimalNumber {
    return self.rounding(accordingToBehavior: NSDecimalNumberHandler(roundingMode: mode, scale: scale, raiseOnExactness: false, raiseOnOverflow: false, raiseOnUnderflow: false, raiseOnDivideByZero: false))
  }
}
extension NSNumber{
  func isMaximum(_ input:NSNumber) -> NSNumber {
    if self.doubleValue < input.doubleValue{
      return input
    }
    return self
  }
  func isNotAvailableForFirstYear(_ year:NSNumber ) -> NSNumber{
    if year.doubleValue != 0 {
      return self
    }
    else{
      return 0
    }
  }
  func isAvailableForSecondAndThirdYear(_ year:NSNumber ) -> NSNumber{
    if year.doubleValue == 1 || year.doubleValue == 2 {
      return self
    }
    else{
      return 0
    }
  }
  func isAvailableUntilYear(_ year:NSNumber) -> NSNumber {
      return 0
  }
}

extension Double{
  func rounded(toPlaces places: Int) -> Double {
    guard places >= 0 else { return self }
    let divisor = Double(Int(pow(10.0, Double(places))))
    //let divisor = Self(sign: .plus, exponent: places, significand: Self(Int(pow(5, Double(places)))))
    return (self * divisor).rounded() / divisor
  }
  func removeTrailingZero() -> NSDecimalNumber {
    let tempVar = String(format: "%g", self)
    return NSDecimalNumber.init(string: tempVar)
  }
}
