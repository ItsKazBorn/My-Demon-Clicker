//
//  CoinsBonusViewController.swift
//  MyDemonClicker
//
//  Created by Kaz Born on 24/03/20.
//  Copyright © 2020 Kaz Born. All rights reserved.
//

import UIKit
import Firebase
import GoogleMobileAds

class CoinsBonusViewController: UIViewController, GADRewardedAdDelegate {

    @IBOutlet weak var bonusCoinsLabel: UILabel!
    var ad : GADRewardedAd!
    var bonusCoins : Double!
    
    func refreshInterface () {
        //ad = GameManager.shared.createRewardedAd()
        ad = GameManager.shared.createRewardedAd(adUnitID: "ca-app-pub-7164936220100567/2263176731")
        
        bonusCoins = GameManager.shared.currentCPM * 60.0
        bonusCoinsLabel.text = CoinsFormatter.shared.formatNumber(bonusCoins)
        AdTabTimer.shared.videoAvailable = false
        
        Analytics.logEvent(AnalyticsEventPresentOffer, parameters: [
            "screen_name" : "Bonus Coins Screen"
        ])
    }
    
    @IBAction func noClicked(_ sender: UIButton) {
        AdTabTimer.shared.videoAvailable = false
        
        Analytics.logEvent("refused_ad", parameters: [
            "screen_name" : "Bonus Coins Screen"
        ])
        
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func showAdClicked(_ sender: UIButton) {
        // >>----> SHOW AD
        if ad.isReady {
            ad.present(fromRootViewController: self, delegate: self)
        }
    }
    
    func rewardedAd(_ rewardedAd: GADRewardedAd, userDidEarn reward: GADAdReward) {
        GameManager.shared.currentTotalCoins += GameManager.shared.currentCPM * 60.0
        GameManager.shared.currentTotalCoins += Double(bonusCoins)
        
        self.dismiss(animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        refreshInterface()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        refreshInterface()
    }
}
