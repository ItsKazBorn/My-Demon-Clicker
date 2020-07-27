//
//  Upgrade.swift
//  MyDemonClicker
//
//  Created by Kaz Born on 06/03/20.
//  Copyright © 2020 Kaz Born. All rights reserved.
//

import Foundation

class Upgrade {
    
    var delegate : UpgradeDelegate?
    
    let name            : String!
    let baseCost        : Int!
    let baseIncomeRate  : Double!
    let multiplier      : Double!
    
    var level : Int = 0 {
        didSet {
            updateIncomeMultiplier(level)
            if level > 0 {
                updateCurrentCost(currentCost)
                updateCurrentIncomeRate(level)
            } else {
                currentCost = baseCost
                currentIncomeRate = 0
            }
        }
    }
    
    var currentCost : Int!
    var currentIncomeRate : Double!
    var currentIncomeMultiplier : Int = 1 {
        didSet {
            if delegate != nil {
                delegate?.hasChangedIncomeMultiplier()
            }
        }
    }
    var isHidden    : Bool = false
    
    init(name: String, baseCost: Int, baseIncomeRate: Double, level : Int = 0, multiplier: Double = 1.15, isHidden: Bool = false) {
        self.name = name
        self.baseCost = baseCost
        self.baseIncomeRate = baseIncomeRate
        self.multiplier = multiplier
        self.isHidden = isHidden
        self.level = level
        self.currentCost = baseCost
        updateCurrentIncomeRate(level)
    }
    
    func updateCurrentIncomeRate (_ level: Int!) {
        currentIncomeRate = baseIncomeRate * Double(level) * Double(currentIncomeMultiplier)
    }
    
    func updateCurrentCost (_ oldCost: Int) {
        let newCostD = Double(baseCost) * (pow(multiplier, Double(level)))
        var newCostI = Int(newCostD.rounded(.toNearestOrAwayFromZero))

        if newCostI == oldCost {
            newCostI += 1
        } else if newCostI < oldCost {
            newCostI = oldCost + 1
        }
        
        currentCost = newCostI
    }
    
    func updateIncomeMultiplier (_ level: Int) {
        switch level {
            case 10:
                currentIncomeMultiplier *= 2
            case 11 ... 100:
                if level % 25 == 0 {
                    currentIncomeMultiplier *= 2
                }
            case 101 ... 500:
                if level % 50 == 0 {
                    currentIncomeMultiplier *= 2
                }
            case 501 ... 1000:
                if level % 100 == 0 {
                    currentIncomeMultiplier *= 2
                }
            case _ where level > 1000:
                if level % 250 == 0 {
                    currentIncomeMultiplier *= 2
                }
            default:
                break
        }
    }
    
    func getIncomeMultiplierProgress() -> Double {
        switch level {
            case 1 ..< 10:
                return Double(level)/10
            case 10 ..< 25:
                let levels = level - 10
                return Double(levels)/(25-10)
            case 25 ..< 100:
                let levels = level % 25
                return Double(levels)/25
            case 100 ..< 500:
                let levels = level % 50
                return Double(levels)/50
            case 500 ..< 1000:
                let levels = level % 100
                return Double(levels)/100
            case _ where level > 1000:
                let levels = level % 250
                return Double(levels)/250
            default:
                return 0.0
        }
    }
    
    func upgrade () {
        if GameManager.shared.currentTotalCoins >= Double(currentCost) {
            GameManager.shared.currentTotalCoins -= Double(currentCost)
            level += 1
            GameManager.shared.updateValues()
            AudioManager.shared.play(soundEffect: .buy)
            if delegate != nil {
                delegate?.hasBoughtLevel()
                if level == 1 {
                    delegate?.hasBoughtFirstLevel()
                }
            }
        }
    }
    
    func saveUpgrade() -> [ String : Any ] {
        var out = [String: Any]()
        
        out["level"]    = self.level
        out["isHidden"] = self.isHidden
        
        return out
    }
    
    func loadUpgrade(encoded: [String : Any]) {
        self.level    = encoded["level"]    as! Int
        self.isHidden = encoded["isHidden"] as! Bool
    }
    
}

protocol UpgradeDelegate {
    func hasBoughtLevel ()
    func hasChangedIncomeMultiplier ()
    func hasBoughtFirstLevel ()
}
