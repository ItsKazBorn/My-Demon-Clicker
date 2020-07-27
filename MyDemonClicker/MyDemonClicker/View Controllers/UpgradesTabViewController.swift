//
//  UpgradesTabViewController.swift
//  MyDemonClicker
//
//  Created by Kaz Born on 12/03/20.
//  Copyright © 2020 Kaz Born. All rights reserved.
//

import UIKit

class UpgradesTabViewController: UIViewController, UICollectionViewDataSource {
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    var upgrades  : [Upgrade]!
    var container : MainViewController?
    
    func refreshInterface () {
        upgrades = getVisibleUpgrades()
        collectionView.reloadData()
        ContainerViewController.shared.delegate = self
    }
    
    func getVisibleUpgrades () -> [Upgrade] {
        var out = [Upgrade]()
        for i in 0 ..< GameManager.shared.upgrades.count {
            if GameManager.shared.upgrades[i].isHidden == false {
                out.append(GameManager.shared.upgrades[i])
            }
        }
        return out
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return upgrades.count + 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if indexPath.row == upgrades.count {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "HiddenCell", for: indexPath)
            return cell
        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "UpgradeCell", for: indexPath) as! UpgradeCollectionViewCell
        
            cell.delegate = self
            cell.configureCell(indexPath.row)
        
            return cell
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView.dataSource = self
        GameManager.shared.delegates.append(self)
        
        refreshInterface()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        refreshInterface()
    }
}

extension UpgradesTabViewController : UpgradeCollectionViewCellDelegate {
    func hasBoughtUpgrade(_ upgradeCollectionViewCell: UpgradeCollectionViewCell, cellTappedFor index: Int) {
        
        GameManager.shared.upgrades[index].upgrade()
        
        upgradeCollectionViewCell.configureCell(index)
        
        let newUpgrades = self.getVisibleUpgrades()
        if newUpgrades.last?.name != upgrades.last?.name {
            self.refreshInterface()
        }
    }
}

extension UpgradesTabViewController : GameManagerDelegate {
    func hasUpdatedTotalCoins(totalCoins: Int) {
        let newUpgrades = self.getVisibleUpgrades()
        if newUpgrades.last?.name != upgrades.last?.name {
            self.refreshInterface()
        }
    }
    
    func hasUpdatedCPM(newCPM: Double) {
        let newUpgrades = self.getVisibleUpgrades()
        if newUpgrades.last?.name != upgrades.last?.name {
            self.refreshInterface()
        }
    }
}

extension UpgradesTabViewController : MainViewControllerDelegate {
    func switchTab() {
        self.tabBarController!.selectedIndex = 1
    }
}
