//
//  CollectionViewLayout.swift
//  MyDemonClicker
//
//  Created by Kaz Born on 12/03/20.
//  Copyright © 2020 Kaz Born. All rights reserved.
//

import Foundation
import UIKit

class CollectionViewLayout: UICollectionViewFlowLayout {
    
    override func prepare() {
        super.prepare()
        
//        guard let collectionView = collectionView else { return }
        
//        let availableHeight = collectionView.bounds.inset(by: collectionView.layoutMargins).height
//        let aspectRatio = CGFloat(228 / 91)
    
//        let cellHeight = (availableHeight).rounded(.down) - 20
//        let cellWidth = cellHeight * aspectRatio
        
        self.itemSize = CGSize(width: 229, height: 92)
        
        self.scrollDirection = .horizontal
        
        self.sectionInset = UIEdgeInsets(top: 10.0, left: 10.0, bottom: 10.0, right: 10.0)
        self.sectionInsetReference = .fromSafeArea
    }
}
