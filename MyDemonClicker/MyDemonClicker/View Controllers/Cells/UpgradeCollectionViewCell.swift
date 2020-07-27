//
//  UpgradeCollectionViewCell.swift
//  MyDemonClicker
//
//  Created by Kaz Born on 12/03/20.
//  Copyright © 2020 Kaz Born. All rights reserved.
//

import UIKit
import FirebaseAnalytics

class UpgradeCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var backgroundImageView: UIImageView!
    @IBOutlet weak var realContentView: UIView!
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var levelLabel: UILabel!
    @IBOutlet weak var currentIncomeRateLabel: UILabel!
    
    @IBOutlet weak var costLabel: UILabel!
    
    @IBOutlet weak var progressBar: UIView!
    @IBOutlet weak var progressBarBackground: UIView!
    @IBOutlet weak var progressBarProgress: UIView!
    @IBOutlet weak var progressBarProgressConstraint: NSLayoutConstraint!
    
    var upgrade  : Upgrade!
    var index    : Int!
    var delegate : UpgradeCollectionViewCellDelegate?
    
    @IBAction func buyUpgrade(_ sender: UIButton) {
        if delegate != nil {
            self.delegate?.hasBoughtUpgrade(self, cellTappedFor: self.index)
        }
    }
    
    override func awakeFromNib() {
        GameManager.shared.delegates.append(self)
    }
    
    func configureCell (_ index: Int) {
        self.index = index
        upgrade = GameManager.shared.upgrades[index]
        GameManager.shared.upgrades[index].delegate = self
        
        nameLabel.text = upgrade.name
        iconImageView.image = UIImage(named: upgrade.name)
        
        levelLabel.text = "lvl \(upgrade.level)"
        
        let currentCost = CoinsFormatter.shared.formatNumber(upgrade.currentCost)
        costLabel.text = "\(currentCost)"
        progressBarBackground.layer.cornerRadius = progressBarBackground.frame.height/2
        updateProgressBar()
        
        // --> Income Rate
        updateIncomeRate()
    }
    
    /*
     var text = CoinsFormatter.shared.formatNumber(GameManager.shared.upgrades[index].baseIncomeRate)
     var pos = upgradeCollectionViewCell.currentIncomeRateLabel.center
     animatedLabel(text, pos: pos)
     text = "1"
     pos = upgradeCollectionViewCell.levelLabel.center
     animatedLabel(text, pos: pos)
     */
    
    func updateIncomeRate () {
        upgrade = GameManager.shared.upgrades[index]
        let upgradeCurrentIncomeRate = upgrade.currentIncomeRate!
        var currentIR : Double = 0
        var formattedIR = ""
        if upgradeCurrentIncomeRate == 0 {
            currentIR = Double(upgrade.baseIncomeRate)
            formattedIR += "+"
        } else {
            currentIR = Double(upgradeCurrentIncomeRate)
        }
        
        if upgrade.name == "Prayer" {
            formattedIR += CoinsFormatter.shared.formatNumber(currentIR)
            let text = "\(formattedIR) /tap"
            if currentIncomeRateLabel.text != text {
                currentIncomeRateLabel.text = text
                animatedIncomeRate()
            }
        } else {
            formattedIR += CoinsFormatter.shared.formatNumber(currentIR)
            let text = "\(formattedIR) c/s"
            if currentIncomeRateLabel.text != text {
                currentIncomeRateLabel.text = text
                animatedIncomeRate()
            }
        }
    }
    
    func animatedIncomeRate () {
        let upgrade = GameManager.shared.upgrades[index]
        let coins = upgrade.baseIncomeRate * Double(upgrade.currentIncomeMultiplier)
        let text = CoinsFormatter.shared.formatNumber(coins)
        var pos = currentIncomeRateLabel.center
        pos.y -= 10
        pos.x -= 10
        realContentView.animatedLabel(text, pos: pos, fontSize: 15.0)
    }
    
    func updateProgressBar () {
        if upgrade.level > 0 {
            progressBar.isHidden = false
        } else {
            progressBar.isHidden = true
        }
        let progress = upgrade.getIncomeMultiplierProgress()
        self.progressBarProgressConstraint.constant = CGFloat(progress) * progressBarBackground.frame.width
        self.layoutIfNeeded()
    }
}

extension UpgradeCollectionViewCell : GameManagerDelegate {
    func hasUpdatedTotalCoins(totalCoins: Int) {
        let upgrade = GameManager.shared.upgrades[index]
        if totalCoins >= upgrade.currentCost {
            self.backgroundImageView.image = UIImage(named: "Light Cell")
        } else {
            self.backgroundImageView.image = UIImage(named: "Dark Cell")
        }
    }
    
    func hasUpdatedCPM(newCPM: Double) {
        self.updateIncomeRate()
    }
}

extension UpgradeCollectionViewCell : UpgradeDelegate {
    func hasChangedIncomeMultiplier() {
        let text = "x2!"
        let pos = progressBarBackground.center
        
        realContentView.animatedLabel(text, pos: pos, fontSize: 20.0)
    }
    
    func hasBoughtFirstLevel() {
        progressBar.isHidden = false
        Analytics.logEvent("upgrade_first_purchase", parameters: [
            "upgrade_name"  : self.upgrade.name!,
            "upgrade_index" : self.index!
        ])
    }
    
    func hasBoughtLevel() {
        self.updateProgressBar()
    }
}

protocol UpgradeCollectionViewCellDelegate {
    func hasBoughtUpgrade (_ upgradeCollectionViewCell: UpgradeCollectionViewCell, cellTappedFor index: Int)
}
