//
//  CountdownTimer.swift
//  MyDemonClicker
//
//  Created by Kaz Born on 27/03/20.
//  Copyright © 2020 Kaz Born. All rights reserved.
//

import Foundation

class CountdownTimer {
    static let shared = CountdownTimer()
    
    public var running = false {
        didSet {
            if delegate != nil {
                delegate?.hasUpdatedRunning(running: running)
            }
            if running {
                GameManager.shared.timerMultiplier = 2
            } else {
                GameManager.shared.timerMultiplier = 1
            }
        }
    }
    public var strTime = "" {
        didSet {
            if delegate != nil {
                delegate?.hasUpdatedRemainingTime(time: strTime)
            }
        }
    }
    
    var delegate : CountdownTimerDelegate?
    
    var remaining : TimeInterval! {
        didSet {
            if remaining <= 0 {
                stopTimer()
            }
        }
    }
    
    private var timer : Timer! {
        didSet {
            oldValue?.invalidate()
        }
    }
    
    private var end : Date!
    
    public func initCountdown (duration: TimeInterval) {
        let start = Date()
        end = start.addingTimeInterval(duration)
        
        remaining = duration
        
        initTimer()
    }
    
    public func addTime (duration: TimeInterval) {
        var toAdd = duration
        if remaining + duration > 28800 {
            toAdd = 28800 - remaining
        }
        end = end.addingTimeInterval(toAdd)
    }
    
    public func formatTime () -> String {
        let hours = Int(Double(remaining / 3600).rounded(.down))
        var left = remaining - Double(hours * 3600)
        let minutes = Int(Double(left / 60).rounded(.down))
        left -= Double(minutes * 60)
        let seconds = Int(left.rounded(.down))
        
        let strH = String(format: "%01d", hours)
        let strM = String(format: "%02d", minutes)
        let strS = String(format: "%02d", seconds)
        
        return "\(strH):\(strM):\(strS)"
    }
    
    private func initTimer () {
        running = true
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true, block: { _ in
            self.updateRemaining()
        })
        RunLoop.main.add(timer, forMode: RunLoop.Mode.common)
    }
    
    private func updateRemaining () {
        let now = Date()
        let dateInterval = DateInterval(start: now, end: end)
        remaining = dateInterval.duration
        strTime = formatTime()
    }
    
    private func stopTimer () {
        timer.invalidate()
        timer = nil
        running = false
        strTime = ""
    }
    
}

protocol CountdownTimerDelegate {
    func hasUpdatedRemainingTime (time: String)
    func hasUpdatedRunning (running: Bool)
}
