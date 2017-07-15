//
//  StatManager.swift
//  ARX Template
//
//  Created by Daniel Ho on 7/4/17.
//  Copyright © 2017 Daniel Ho. All rights reserved.
//

import Foundation

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
}
