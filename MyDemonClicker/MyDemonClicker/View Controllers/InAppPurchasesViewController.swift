//
//  InAppPurchasesViewController.swift
//  MyDemonClicker
//
//  Created by Kaz Born on 12/03/20.
//  Copyright © 2020 Kaz Born. All rights reserved.
//

import UIKit

class InAppPurchasesViewController: UIViewController {

    func refreshInterface () {
        
        ContainerViewController.shared.delegate = self
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        refreshInterface()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        refreshInterface()
    }
}

extension InAppPurchasesViewController : MainViewControllerDelegate {
    func switchTab() {
        if let upgradesVC = self.storyboard?.instantiateViewController(withIdentifier: "IAPTab") {
            self.show(upgradesVC, sender: self)
        }
    }
}
