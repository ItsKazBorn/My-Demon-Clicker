//
//  AdTabTimer.swift
//  MyDemonClicker
//
//  Created by Kaz Born on 25/06/20.
//  Copyright © 2020 Kaz Born. All rights reserved.
//

import Foundation

class AdTabTimer {
    static let shared = AdTabTimer()
    
    public var videoAvailable = true {
        didSet {
            if videoAvailable {
                if delegate != nil {
                    delegate?.openTab()
                    self.initTimer(duration: 120)
                }
            } else {
                if delegate != nil {
                    delegate?.closeTab()
                    self.initTimer(duration: 300)
                }
            }
        }
    }
    
    var delegate : AdTabTimerDelegate? {
        didSet {
            self.initTimer(duration: 60)
        }
    }
    
    private var timer : Timer! {
        didSet {
            oldValue?.invalidate()
        }
    }
    
    public func initTimer (duration: TimeInterval) {
        timer = Timer.scheduledTimer(withTimeInterval: duration, repeats: true, block: { _ in
            self.videoAvailable.toggle()
        })
        RunLoop.main.add(timer, forMode: RunLoop.Mode.common)
    }
    
}

protocol AdTabTimerDelegate {
    func openTab ()
    func closeTab ()
}
