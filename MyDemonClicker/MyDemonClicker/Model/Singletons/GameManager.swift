//
//  GameManager.swift
//  MyDemonClicker
//
//  Created by Kaz Born on 06/03/20.
//  Copyright © 2020 Kaz Born. All rights reserved.
//

import Foundation
import GoogleMobileAds

class GameManager {
    static let shared = GameManager()
    
    /// >>> Serious Stuff
    let defaults = UserDefaults.standard
    let encoder  = JSONEncoder()
    let decoder  = JSONDecoder()

    var delegates = [GameManagerDelegate?]()
    
    var welcomeBack = false
    
    
    /// >>> Game Variables
    var currentTotalCoins : Double = 0 {
        didSet {
            if !delegates.isEmpty {
                let int = Int(currentTotalCoins.rounded(.down))
                for delegate in delegates {
                    delegate?.hasUpdatedTotalCoins(totalCoins: int)
                }
            }
            self.updateHiddenUpgrades()
        }
    }
    var currentClickValue : Int = 1
    var baseCPM           : Double = 0
    var currentCPM        : Double = 0 {
        didSet {
            if !delegates.isEmpty {
                for delegate in delegates {
                    delegate?.hasUpdatedCPM(newCPM: currentCPM)
                }
            }
        }
    }
    
    var timerMultiplier : Int = 1 {
        didSet {
            self.updateCPM()
        }
    }
    
    var upgrades  : [Upgrade] = []
    var awayTime  : TimeInterval = 14400.0
    var awayCoins : Double = 0.0
    
    
    /// >>> Timers
    var cpsTimer : Timer? {
        didSet {
            oldValue?.invalidate()
        }
    }
    var coinsThisSecTimer : Timer!
    var previouscoins : Double!
    
    
    /// >>----> Initializer
    init () {
        initTimerCoinsThisSecond()
        
        upgrades = makeGameUpgrades()
        
        updateValues()
    }
    
    func initTimerCoinsThisSecond () {
        coinsThisSecTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true, block: { _ in
            if self.previouscoins == nil { self.previouscoins = self.currentTotalCoins }
            else {
                self.currentTotalCoins = self.currentTotalCoins.rounded(.toNearestOrAwayFromZero)
                //self.printCoins()
            }
        })
        RunLoop.main.add(coinsThisSecTimer, forMode: RunLoop.Mode.common)
    }
    
    func makeGameUpgrades () -> [Upgrade] {
        var out : [Upgrade] = []
        
        let names = ["Prayer", "Follower", "Altar", "Preacher", "Temple", "Propaganda", "Monument", "Religious War", "Theocracy", "Portal"]
        let baseCosts = [6, 66, 333, 999, 3_999, 19_666, 99_666, 399_666, 2_666_999, 16_666_666]
        let baseIncomes = [1.0, 0.1, 0.66, 1.66, 6.66, 66.0, 99.0, 666.0, 6_666, 666_666]
        
        out.append(Upgrade(name: names[0], baseCost: baseCosts[0], baseIncomeRate: baseIncomes[0], level: 1, multiplier: 1.15, isHidden: false))
        
        for i in 1 ..< names.count {
            out.append(Upgrade(name: names[i], baseCost: baseCosts[i], baseIncomeRate: baseIncomes[i], isHidden: true))
        }
        
        return out
    }
    
    /// >>----> Game Actions
    /// --> Click/Tap screen
    func clicked () {
        currentTotalCoins += Double(currentClickValue * timerMultiplier)
    }
    
    /// --> Upgraded something
    func updateValues () {
        updateClickValue()
        updateCPM()
    }
    
    func updateCPM () {
        baseCPM = 0
        if upgrades.count > 1 {
            for i in 1 ..< upgrades.count {
                baseCPM += upgrades[i].currentIncomeRate * 60.0
            }
        }
        currentCPM = baseCPM * Double(timerMultiplier)
        coinsPerMinute()
    }
    
    func updateClickValue () {
        if upgrades.count > 0 {
            self.currentClickValue = Int(upgrades[0].currentIncomeRate)
        } else {
            self.currentClickValue = 1
        }
    }
    
    func updateHiddenUpgrades () {
        for upgrade in upgrades {
            if upgrade.isHidden {
                if currentTotalCoins >= Double(upgrade.baseCost) {
                    upgrade.isHidden = false
                }
            }
        }
    }
    
    /// >>----> Timers
    let updatesPerSecond = 20
    
    func coinsPerMinute () {
        switch currentCPM {
            case 1.0 ... 60.0*Double(updatesPerSecond):
                let time = 60.0/Double(currentCPM)
                cpsTimer = Timer.scheduledTimer(withTimeInterval: time, repeats: true, block: { _ in
                    self.currentTotalCoins += Double(1)
                })
                RunLoop.main.add(cpsTimer!, forMode: RunLoop.Mode.common)
            case _ where currentCPM > 60.0*Double(updatesPerSecond):
                let coins = Double(currentCPM)/Double(60*updatesPerSecond)
                cpsTimer = Timer.scheduledTimer(withTimeInterval: 1.0/Double(updatesPerSecond), repeats: true, block: { _ in
                    self.currentTotalCoins += coins
                })
                RunLoop.main.add(cpsTimer!, forMode: RunLoop.Mode.common)
            case 0:
                fallthrough
            default:
                break
        }
    }
    
    func printCoins () {
        let coins = currentTotalCoins - previouscoins
        previouscoins = currentTotalCoins
        print("Coins/Second: \(coins)")
        print("Multiplier: \(timerMultiplier)")
        print("Timer: \(CountdownTimer.shared.strTime)")
    }
    
    
    /// >>>---------> GAME SAVE
    func saveGame () {
        defaults.set(currentTotalCoins, forKey: "totalCoins")
        defaults.set(Date(), forKey: "savedDate")
        defaults.set(awayTime, forKey: "awayTimeInterval")
        defaults.set(CountdownTimer.shared.remaining, forKey: "remainingDoubleTime")
        self.saveUpgrades()
        welcomeBack = true
        print("Game Saved")
    }
    
    private func saveUpgrades () {
        for i in 0 ..< upgrades.count {
            let dict = upgrades[i].saveUpgrade()
            
            defaults.set(dict, forKey: "\(i)")
            
        }
    }
    
    /// >>>---------> GAME LOAD
    func loadGame () {
        let oldTotalCoins = defaults.double(forKey: "totalCoins")
        let savedDate = defaults.object(forKey: "savedDate") as? Date ?? Date()
        let awayTimeInterval = defaults.double(forKey: "awayTimeInterval") as TimeInterval
        let remainingDoubleTime = defaults.double(forKey: "remainingDoubleTime") as TimeInterval
        let savedUpgrades = loadUpgrades()
        
        upgrades = savedUpgrades
        updateValues()
        currentTotalCoins = oldTotalCoins
        
        awayCoins = calculateAwayCoins(savedDate: savedDate, awayTime: awayTimeInterval, remainingDoubleTime: remainingDoubleTime)
        
        if !welcomeBack {
            self.currentTotalCoins += awayCoins
        }
        
        print("Game Loaded")
    }
    
    private func loadUpgrades () -> [Upgrade] {
        let initialUpgrades = self.makeGameUpgrades()
        var out = [Upgrade]()
        for i in 0 ..< initialUpgrades.count {
            if let saved = defaults.dictionary(forKey: "\(i)") {
                out.append(initialUpgrades[i])
                out[i].loadUpgrade(encoded: saved)
            }
        }
        if out.count == 0 {
            return initialUpgrades
        }
        
        return out
    }
    
    func calculateAwayCoins (savedDate: Date, awayTime: TimeInterval, remainingDoubleTime: TimeInterval) -> Double {
        var out : Double = 0.0
        
        let now = Date()
        let awayMaxDate = Date(timeInterval: awayTime, since: savedDate)

        if now >= awayMaxDate {
            // Use awayTime
            out = calculateDoubleAwayCoins(remainingDoubleTime: remainingDoubleTime, awayTime: awayTime)
        } else {
            // Use timePassed
            let timePassed = DateInterval(start: savedDate, end: now).duration as Double
            out = calculateDoubleAwayCoins(remainingDoubleTime: remainingDoubleTime, awayTime: timePassed)
        }
        
        if awayTime >= 120 {
            welcomeBack = true
        } else {
            welcomeBack = false
        }
        
        if out >= 1 {
            return out
        } else {
            welcomeBack = false
            return 0
        }
    }
    
    func calculateDoubleAwayCoins (remainingDoubleTime: TimeInterval, awayTime: TimeInterval) -> Double {
        var out : Double = 0.0
        if remainingDoubleTime <= awayTime {
            out += Double(self.currentCPM) * 2.0 * remainingDoubleTime/60
            let leftoverTime = awayTime - remainingDoubleTime
            out += Double(self.currentCPM) * Double(leftoverTime)/60
        } else {
            out += Double(self.currentCPM) * 2.0 * awayTime
            let leftoverTime = remainingDoubleTime - awayTime
            CountdownTimer.shared.remaining = leftoverTime
        }
        return out
    }
    
    /// >>>---------> ADS
    func createRewardedAd (adUnitID: String = "ca-app-pub-3940256099942544/1712485313") -> GADRewardedAd {
        let rewardedAd = GADRewardedAd(adUnitID: adUnitID)
        rewardedAd.load(GADRequest()) { error in
            if let error = error {
                print("Loading Failed: \(error)")
            } else {
                print("Loading Succeeded!")
            }
        }
        return rewardedAd
    }
}

protocol GameManagerDelegate {
    func hasUpdatedTotalCoins (totalCoins: Int)
    func hasUpdatedCPM (newCPM: Double)
}
