//
//  CoinsFormatter.swift
//  MyDemonClicker
//
//  Created by Kaz Born on 11/03/20.
//  Copyright © 2020 Kaz Born. All rights reserved.
//

import Foundation

class CoinsFormatter {
    static var shared = CoinsFormatter()
    
    var formatter = NumberFormatter()
    
    let units = ["", "k", "m", "b", "t"]
    let letters = ["a", "b", "c", "d", "e", "f", "g", "h", "i", "j", "k", "l", "m", "n", "o", "p", "q", "r", "s", "t", "u", "v", "w", "x", "y", "z"]
    
    init () {
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 2
        formatter.minimumIntegerDigits = 1
        formatter.roundingMode = .down
    }
    
    init (numberStyle: NumberFormatter.Style) {
        if numberStyle == .decimal {
            formatter.numberStyle = .decimal
            formatter.maximumFractionDigits = 2
            formatter.minimumIntegerDigits = 1
            formatter.roundingMode = .down
            
        } else if numberStyle == .scientific {
            formatter.numberStyle = .scientific
            formatter.exponentSymbol = "e"
            formatter.maximumFractionDigits = 2
            formatter.minimumIntegerDigits = 1
            formatter.roundingMode = .down
        }
    }
    
    func formatNumber(_ number: Int) -> String {
        var out = ""
        
        let numberD = Double(number)
        
        
        let n = Int(log1000(value: numberD))
        let m = numberD / pow(1000.0, Double(n))
        
        var unit = ""
        
        if n < units.count {
            unit = units[n]
        } else {
            let unitInt = n - units.count
            let secondUnit = unitInt % 26
            let firstUnit = unitInt / 26
            unit = letters[firstUnit] + letters[secondUnit]
        }
        
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 2
        formatter.minimumIntegerDigits = 1
        formatter.roundingMode = .down
        
        out += formatter.string(from: NSNumber(floatLiteral: m))!
        out += unit
        
        return out
    }
    
    func formatNumber(_ number: Double) -> String {
        var out = ""
        
        let n = Int(log1000(value: number))
        let m = number / pow(1000.0, Double(n))
        
        var unit = ""
        
        if n < units.count {
            unit = units[n]
        } else {
            let unitInt = n - units.count
            let secondUnit = unitInt % 26
            let firstUnit = unitInt / 26
            unit = letters[firstUnit] + letters[secondUnit]
        }
        
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 2
        formatter.minimumIntegerDigits = 1
        formatter.roundingMode = .down
        
        out += formatter.string(from: NSNumber(floatLiteral: m))!
        out += unit
        
        return out
    }
    
    func log1000(value: Double) -> Double {
        if value == 0 {
            return 0
        }
        return log10(value) / log10(1000.0)
    }
}
