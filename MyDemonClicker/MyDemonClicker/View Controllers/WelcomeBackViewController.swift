//
//  WelcomeBackViewController.swift
//  MyDemonClicker
//
//  Created by Kaz Born on 17/03/20.
//  Copyright © 2020 Kaz Born. All rights reserved.
//

import UIKit
import Firebase
import GoogleMobileAds

class WelcomeBackViewController: UIViewController, GADRewardedAdDelegate {
    
    @IBOutlet weak var awayCoinsLabel: UILabel!
    var ad : GADRewardedAd!
    
    func refreshInterface () {
        //ad = GameManager.shared.createRewardedAd()
        ad = GameManager.shared.createRewardedAd(adUnitID: "ca-app-pub-7164936220100567/3746697103")
        
        let awayCoins = Int(GameManager.shared.awayCoins.rounded(.toNearestOrAwayFromZero))
        awayCoinsLabel.text = CoinsFormatter.shared.formatNumber(awayCoins)
        
        Analytics.logEvent(AnalyticsEventPresentOffer, parameters: [
            "screen_name" : "Welcome Back Screen"
        ])
    }
    
    @IBAction func noAdClicked(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func adClicked(_ sender: UIButton) {
        // >>----> SHOW AD
        if ad.isReady {
            ad.present(fromRootViewController: self, delegate: self)
        }
    }
    
    func rewardedAd(_ rewardedAd: GADRewardedAd, userDidEarn reward: GADAdReward) {
        GameManager.shared.currentTotalCoins += GameManager.shared.awayCoins * 2.0
        GameManager.shared.awayCoins = 0
        GameManager.shared.welcomeBack = false
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
    
    override func viewWillDisappear(_ animated: Bool) {
        
        Analytics.logEvent("refused_ad", parameters: [
            "screen_name" : "Welcome Back Screen"
        ])
        
        GameManager.shared.currentTotalCoins += GameManager.shared.awayCoins
        GameManager.shared.welcomeBack = false
        
        super.viewWillDisappear(animated)
    }
}
