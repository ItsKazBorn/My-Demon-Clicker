//
//  TimeBonusViewController.swift
//  MyDemonClicker
//
//  Created by Kaz Born on 24/03/20.
//  Copyright © 2020 Kaz Born. All rights reserved.
//

import UIKit
import Firebase
import GoogleMobileAds

class TimeBonusViewController: UIViewController, GADRewardedAdDelegate {
    
    var ad : GADRewardedAd!
    
    func refreshInterface () {
        //ad = GameManager.shared.createRewardedAd()
        ad = GameManager.shared.createRewardedAd(adUnitID: "ca-app-pub-7164936220100567/1699591024")
        
        Analytics.logEvent(AnalyticsEventPresentOffer, parameters: [
            "screen_name" : "x2 Coins Screen"
        ])
    }
    
    @IBAction func noAdClicked(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func showAdClicked(_ sender: UIButton) {
        // >>----> SHOW AD
        if ad.isReady {
            ad.present(fromRootViewController: self, delegate: self)
        }
        
    }
    
    func rewardedAd(_ rewardedAd: GADRewardedAd, userDidEarn reward: GADAdReward) {
        // REWARD CODE
        if CountdownTimer.shared.running {
            CountdownTimer.shared.addTime(duration: 7200)
        } else {
            CountdownTimer.shared.initCountdown(duration: 7200)
        }
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
            "screen_name" : "x2 Coins Screen"
        ])
        
        super.viewWillDisappear(animated)
    }
}
