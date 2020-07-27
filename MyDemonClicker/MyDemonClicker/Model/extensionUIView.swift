//
//  extensionUIView.swift
//  MyDemonClicker
//
//  Created by Kaz Born on 07/04/20.
//  Copyright © 2020 Kaz Born. All rights reserved.
//

import Foundation
import UIKit

extension UIView {
    /// >>>-------> ANIMATED LABEL
    func animatedLabel (_ text: String, pos: CGPoint, fontSize: CGFloat) {
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: 200, height: 100))
        let actualText = "+ \(text)"
        
        label.textAlignment = .center
        label.center = pos
        
        // Setar configs tipo fonte e cor
        let font = UIFont(name: "hundrighting", size: fontSize)!
        let insideColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
        let strokeColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        let strokeWidth = 2.0 as Float
        
        let attributes = stroke(font: font, strokeWidth: strokeWidth, insideColor: insideColor, strokeColor: strokeColor)
        
        label.attributedText = NSMutableAttributedString(string: actualText, attributes: attributes)
        
        self.addSubview(label)
        
        UIView.animate(withDuration: 0.5, animations: {
            label.center.y -= 25
            label.alpha = 0.0
            self.layoutIfNeeded()
        })
    }
    
    public func stroke(font: UIFont, strokeWidth: Float, insideColor: UIColor, strokeColor: UIColor) -> [NSAttributedString.Key: Any]{
        return [
            NSAttributedString.Key.strokeColor : strokeColor,
            NSAttributedString.Key.foregroundColor : insideColor,
            NSAttributedString.Key.strokeWidth : -strokeWidth,
            NSAttributedString.Key.font : font
        ]
    }
    
}
