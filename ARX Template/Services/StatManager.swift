//
//  StatManager.swift
//  ARX Template
//
//  Created by Daniel Ho on 7/4/17.
//  Copyright © 2017 Daniel Ho. All rights reserved.
//

import Foundation

// Used for persistence
struct StatManager {
    static let sharedIntance = StatManager()
    
    func playCount() -> Int {
        return UserDefaults.standard.integer(for: .playCount)
    }
    
    func playCountToday() -> Int {
        return UserDefaults.standard.integer(for: .playCountToday)
    }
    
    func onPlay() {
        if let lastPlayed = UserDefaults.standard.date(for: .lastPlay) {
            if !Calendar.current.isDateInToday(lastPlayed) {
                UserDefaults.standard.set(0, for: .playCountToday)
            }
        }
        UserDefaults.standard.set(Date(), for: .lastPlay)
        UserDefaults.standard.set(playCountToday() + 1, for: .playCountToday)
        UserDefaults.standard.set(playCount() + 1, for: .playCount)
    }
    
    func lastIntention() -> String? {
        return UserDefaults.standard.string(for: .intention)
    }
    
    func onIntentionPlay(_ intention: String, durationSliderValue: Float, arMode: Bool) {
        UserDefaults.standard.set(intention, for: .intention)
        UserDefaults.standard.set(durationSliderValue, for: .durationSliderValue)
        UserDefaults.standard.set(arMode, for: .arMode)
    }
    
    func lastDurationSliderValue() -> Float {
        return Float(UserDefaults.standard.double(for: .durationSliderValue))
    }
    
    func lastArMode() -> Bool {
        return UserDefaults.standard.bool(for: .arMode)
    }
}
