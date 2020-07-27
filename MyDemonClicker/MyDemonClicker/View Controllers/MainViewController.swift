//
//  MainViewController.swift
//  MyDemonClicker
//
//  Created by Kaz Born on 10/03/20.
//  Copyright © 2020 Kaz Born. All rights reserved.
//

import UIKit
import Lottie

class MainViewController: UIViewController, UIGestureRecognizerDelegate {

    @IBOutlet weak var currentCoinsLabel : UILabel!
    @IBOutlet weak var currentCPSLabel   : UILabel!
    @IBOutlet weak var coinsPerLabel     : UILabel!
    
    var currentCoins : Int! {
        didSet {
            currentCoinsLabel.text = CoinsFormatter.shared.formatNumber(currentCoins)
        }
    }
    
    var currentCPM : Double = Double(GameManager.shared.currentCPM) {
        didSet {
            currentCPSLabel.text = CoinsFormatter.shared.formatNumber(currentCPM)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // --> Save/Load game notifications
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(appMovedToBackground), name: UIApplication.willResignActiveNotification, object: nil)
        notificationCenter.addObserver(self, selector: #selector(appMovedToForeground), name: UIApplication.willEnterForegroundNotification, object: nil)
        
        // --> Animations
        animationCache.clearCache()
        
        var filepath = Bundle.main.url(forResource: "Idle", withExtension: "json")!
        let idleAnimation = Animation.filepath(filepath.path)!
        animationCache.setAnimation(idleAnimation, forKey: "Idle")
        
        filepath = Bundle.main.url(forResource: "Tap", withExtension: "json")!
        let tapAnimation  = Animation.filepath(filepath.path)!
        animationCache.setAnimation(tapAnimation , forKey: "Tap")
        
        // --> Tabs
        AdTabTimer.shared.delegate = self
        
        refreshInterface()
    }
    
    func refreshInterface () {
        GameManager.shared.delegates.append(self)
        CountdownTimer.shared.delegate = self
        let totalCoins = Int(GameManager.shared.currentTotalCoins.rounded(.down))
        hasUpdatedTotalCoins(totalCoins: totalCoins)
        hasUpdatedCPM(newCPM: GameManager.shared.currentCPM)
        
        playIdleAnimation()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        refreshInterface()
    }
    
    /// >>>-------> MUTE/UNMUTE
    @IBOutlet weak var muteImageView: UIImageView!
    
    @IBAction func muteTapped(_ sender: UIButton) {
        AudioManager.shared.muted.toggle()
        if AudioManager.shared.muted == true {
            muteImageView.image = UIImage(named: "SoundIsOff")
        } else {
            muteImageView.image = UIImage(named: "SoundIsOn")
        }
    }
    
    
    /// >>>-------> TAP
    @IBAction func click(_ sender: UIButton) {
        GameManager.shared.clicked()
        AudioManager.shared.play(soundEffect: .tap)
        playTapAnimation()
    }
    
    
    @IBAction func tapped(_ sender: UITapGestureRecognizer) {
        let coins = CoinsFormatter.shared.formatNumber(GameManager.shared.currentClickValue)
        let pos = sender.location(ofTouch: 0, in: nil)
        self.view.animatedLabel(coins, pos: pos, fontSize: 40.0)
    }
    
    
    /// >>>-------> SAVE/LOAD GAME
    override func viewDidAppear(_ animated: Bool) {
        self.appMovedToForeground()
    }
    
    @objc func appMovedToBackground() {
        GameManager.shared.saveGame()
    }
    
    @objc func appMovedToForeground() {
        GameManager.shared.loadGame()
        if GameManager.shared.awayCoins > 0 && GameManager.shared.welcomeBack {
            if let vc = self.storyboard?.instantiateViewController(identifier: "WelcomeBack") {
                vc.modalPresentationStyle = .popover
                self.present(vc, animated: true, completion: nil)
            }
        }
    }
    
    
    /// >>>-------> ANIMATIONS
    @IBOutlet weak var demonhoAnimationView: AnimationView!
    var animationCache = LRUAnimationCache()
    var imageProvider  : FilepathImageProvider!
    
    func playIdleAnimation () {
        demonhoAnimationView.animation = animationCache.animation(forKey: "Idle")
        demonhoAnimationView.loopMode = .loop
        demonhoAnimationView.play()
    }
    
    func playTapAnimation () {
        demonhoAnimationView.stop()
        demonhoAnimationView.animation = animationCache.animation(forKey: "Tap")
        demonhoAnimationView.loopMode = .playOnce
        demonhoAnimationView.play { (finished) in
            self.playIdleAnimation()
        }
    }
    
    
    /// >>>-------> VIDEO ADS
    @IBOutlet weak var timerTab       : UIView!
    @IBOutlet weak var timerView      : UIView!
    @IBOutlet weak var noTimerView    : UIView!
    @IBOutlet weak var adAvailableTab : UIView!
    @IBOutlet weak var timerLabel     : UILabel!
    
    var timer = "" {
        didSet {
            timerLabel.text = timer
        }
    }
    var runningTimer = false {
        didSet {
            if runningTimer {
                timerView.isHidden = false
                noTimerView.isHidden = true
            } else {
                timerView.isHidden = true
                noTimerView.isHidden = false
            }
        }
    }
    
    @IBOutlet weak var tabLeadingConstraint: NSLayoutConstraint!
    var videoAvailable = true {
        didSet {
            if videoAvailable {
                self.animateOpenTab()
            } else {
                self.animateCloseTab()
            }
        }
    }
    
    func animateOpenTab () {
        UIView.animate(withDuration: 0.3, animations: {
            self.tabLeadingConstraint.constant = 0
            self.view.layoutIfNeeded()
        })
    }
    
    func animateCloseTab () {
        UIView.animate(withDuration: 0.3, animations: {
            self.tabLeadingConstraint.constant = -self.adAvailableTab.frame.width - 10
            self.view.layoutIfNeeded()
        })
    }
    
    @IBAction func watchTimerAdClicked(_ sender: UIButton) {
        if let vc = self.storyboard?.instantiateViewController(identifier: "x2Bonus") {
            vc.modalPresentationStyle = .popover
            self.present(vc, animated: true, completion: nil)
        }
    }
    
    @IBAction func watchBonusAdClicked(_ sender: UIButton) {
        if let vc = self.storyboard?.instantiateViewController(identifier: "CoinsBonus") {
            vc.modalPresentationStyle = .popover
            self.present(vc, animated: true, completion: nil)
        }
    }
    
    
    /// >>>-------> BOTTOM AREA
    var bottomAreaHidden = false
    var changingTab = false
    enum tab : Int {
        case first  = 1
        case second = 2
    }
    var selectedTab : tab = .first
    
    @IBOutlet weak var topTabImageView: UIImageView!
    @IBOutlet weak var bottomTabImageView: UIImageView!
    
    @IBOutlet weak var bottomAreaBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var bottomAreaView: UIView!
    @IBOutlet weak var containerView: UIView!
    
    var containerViewDelegate : MainViewControllerDelegate!
    
    func beginChangeTab () {
        print("Begin Change Tab")
        containerViewDelegate = ContainerViewController.shared.delegate
        changingTab = true
        if !bottomAreaHidden {
            hideTabContent()
        } else {
            switchViewController()
        }
    }
    
    func switchViewController () {
        print("Switch View Controller")
        switch selectedTab {
            case .first:
                print("Changing to 2nd Tab")
                topTabImageView.image = UIImage(named: "Tab IAP")
                bottomTabImageView.image = UIImage(named: "Tab Upgrade")
                containerViewDelegate.switchTab()
                selectedTab = .second
                
            case .second:
                print("Changing to 1st Tab")
                topTabImageView.image = UIImage(named: "Tab Upgrade")
                bottomTabImageView.image = UIImage(named: "Tab IAP")
                containerViewDelegate.switchTab()
                selectedTab = .first
        }
        showTabContent()
        changingTab = false
        print("Finished Changing Tab")
    }
    
    func toggleShowHideTabContent () {
        print("Toggle show/hide Content")
        if bottomAreaHidden {
            showTabContent()
        }
        else {
            hideTabContent()
        }
    }
    
    func showTabContent() {
        print("Showing Content")
        UIView.animate(withDuration: 0.3, animations: {
            self.bottomAreaBottomConstraint.constant = 0
            self.view.layoutIfNeeded()
            self.bottomAreaHidden = false
            print("Tab Opened")
        }, completion: { _ in
            print("Tab Opened Completion")
        })
    }
    
    func hideTabContent() {
        print("Hiding Content")
        let bottomHeight = bottomAreaView.frame.height
        UIView.animate(withDuration: 0.3, animations: {
            self.bottomAreaBottomConstraint.constant = 0 - (bottomHeight - 10)
            self.view.layoutIfNeeded()
            self.bottomAreaHidden = true
            print("Tab Closed")
        }, completion: { _ in
            print("Tab Closed Completion")
            if self.changingTab {
                self.switchViewController()
            }
        })
    }
    
    @IBAction func tab1Clicked(_ sender: UIButton) {
        print("-> 1st Tab Clicked")
        if selectedTab == .first {
            print("Toggle Content 1st Tab")
            toggleShowHideTabContent()
        } else {
            print("Start Changing to 1st Tab")
            beginChangeTab()
        }
    }
    
    @IBAction func tab2Clicked(_ sender: UIButton) {
        print("-> 2nd Tab Clicked")
        if selectedTab == .second {
            print("Toggle Content 2nd Tab")
            toggleShowHideTabContent()
        } else {
            print("Start Changing to 2nd Tab")
            beginChangeTab()
        }
    }
    
    
    
}


extension MainViewController : GameManagerDelegate {
    func hasUpdatedTotalCoins(totalCoins: Int) {
        currentCoins = totalCoins
    }
    
    func hasUpdatedCPM(newCPM: Double) {
        if newCPM >= 60 {
            currentCPM = newCPM
            coinsPerLabel.text = "/sec"
        } else {
            currentCPM = newCPM * 60
            coinsPerLabel.text = "/Min"
        }
    }
}

extension MainViewController : CountdownTimerDelegate {
    func hasUpdatedRemainingTime(time: String) {
        timer = time
    }
    func hasUpdatedRunning(running: Bool) {
        runningTimer = running
    }
}

extension MainViewController : AdTabTimerDelegate {
    func openTab() {
        self.animateOpenTab()
    }
    
    func closeTab() {
        self.animateCloseTab()
    }
}

protocol MainViewControllerDelegate {
    func switchTab ()
}
