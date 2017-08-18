//
//  TimeFormatType.swift
//  ARX Template
//
//  Created by Daniel Ho on 8/16/17.
//  Copyright © 2017 Daniel Ho. All rights reserved.
//

import Foundation

enum TimeFormatType {
    case feed
    
    func timeString(_ secondsAgoFromNow: Int) -> String {
        var diffUnit = ""
        var diffTime = secondsAgoFromNow
        if (diffTime < TimeUnit.minutes.seconds()) {
            return lessThanMinuteAgo()
        } else if (diffTime < TimeUnit.hours.seconds()) {
            diffTime = diffTime / TimeUnit.minutes.seconds();
            diffUnit = TimeUnit.minutes.string(diffTime, shouldAbbreviate: shouldAbbreviateUnit())
        } else if (diffTime < TimeUnit.days.seconds()) {
            diffTime = diffTime / TimeUnit.hours.seconds();
            diffUnit = TimeUnit.hours.string(diffTime, shouldAbbreviate: shouldAbbreviateUnit())
        } else if (diffTime < TimeUnit.months.seconds()) {
            diffTime = diffTime / TimeUnit.days.seconds();
            diffUnit = TimeUnit.days.string(diffTime, shouldAbbreviate: shouldAbbreviateUnit())
        } else if (diffTime < TimeUnit.years.seconds()) {
            diffTime = diffTime / TimeUnit.months.seconds();
            diffUnit = TimeUnit.months.string(diffTime, shouldAbbreviate: shouldAbbreviateUnit())
        } else {
            diffTime = diffTime / TimeUnit.years.seconds();
            diffUnit = TimeUnit.years.string(diffTime, shouldAbbreviate: shouldAbbreviateUnit())
        }
        return formattedTimeAgo(diffTime, diffUnit: diffUnit)
    }
    
    internal func shouldAbbreviateUnit() -> Bool {
        return false
    }
    
    internal func formattedTimeAgo(_ diffTime: Int, diffUnit: String) -> String {
        switch self {
        case .feed:
//            if let localizedTimeAgo = localizedAgoString(diffTime: diffTime, timeUnit: diffUnit) {
//                return String(format: localizedTimeAgo, diffTime).uppercased()
//            }
            return String(format: NSLocalizedString("%d %@ ago", comment: "Time Unit ago, ex) 3 hours ago. Spanish should be: hace %d %@"), diffTime, diffUnit)
        }
        
    }
    
    internal func localizedAgoString(diffTime: Int, timeUnit: String) -> String? {
        if timeUnit == NSLocalizedString("minute", comment: "") {
            return NSLocalizedString("%dm", comment: "Append to X minute ago")
        } else if timeUnit == NSLocalizedString("minutes", comment: "") {
            return NSLocalizedString("%dm", comment: "Append to X minutes ago")
        } else if timeUnit == NSLocalizedString("hour", comment: "") {
            return NSLocalizedString("%dh", comment: "Append to X hour ago")
        } else if timeUnit == NSLocalizedString("hours", comment: "") {
            return NSLocalizedString("%dh", comment: "Append to X hours ago")
        } else if timeUnit == NSLocalizedString("day", comment: "") {
            return NSLocalizedString("%dd", comment: "Append to X day ago")
        } else if timeUnit == NSLocalizedString("days", comment: "") {
            return NSLocalizedString("%dd", comment: "Append to X days ago")
        } else if timeUnit == NSLocalizedString("month", comment: "") {
            return NSLocalizedString("%dmo", comment: "Append to X month ago")
        } else if timeUnit == NSLocalizedString("months", comment: "") {
            return NSLocalizedString("%dmo", comment: "Append to X months ago")
        } else if timeUnit == NSLocalizedString("year", comment: "") {
            return NSLocalizedString("%dy", comment: "Append to X year ago")
        } else if timeUnit == NSLocalizedString("years", comment: "") {
            return NSLocalizedString("%dy", comment: "Append to X years ago")
        }
        return nil
    }
    
    internal func localizedStartedAgoString(diffTime: Int, timeUnit: String) -> String? {
        if timeUnit == NSLocalizedString("minute", comment: "") {
            return NSLocalizedString("%d minute", comment: "Append to X minute ago")
        } else if timeUnit == NSLocalizedString("minutes", comment: "") {
            return NSLocalizedString("%d minutes", comment: "Append to X minutes ago")
        } else if timeUnit == NSLocalizedString("hour", comment: "") {
            return NSLocalizedString("%d hour", comment: "Append to X hour ago")
        } else if timeUnit == NSLocalizedString("hours", comment: "") {
            return NSLocalizedString("%d hourss", comment: "Append to X hours ago")
        } else if timeUnit == NSLocalizedString("day", comment: "") {
            return NSLocalizedString("%d day ago", comment: "Append to X day ago")
        } else if timeUnit == NSLocalizedString("days", comment: "") {
            return NSLocalizedString("%d days", comment: "Append to X days ago")
        } else if timeUnit == NSLocalizedString("month", comment: "") {
            return NSLocalizedString("%d month", comment: "Append to X month ago")
        } else if timeUnit == NSLocalizedString("months", comment: "") {
            return NSLocalizedString("%d months", comment: "Append to X months ago")
        } else if timeUnit == NSLocalizedString("year", comment: "") {
            return NSLocalizedString("%d year", comment: "Append to X year ago")
        } else if timeUnit == NSLocalizedString("years", comment: "") {
            return NSLocalizedString("%d years", comment: "Append to X years ago")
        }
        return nil
    }
    
    internal func lessThanMinuteAgo() -> String {
        switch self {
        case .feed:
            return NSLocalizedString("Less than 1 minute ago", comment: "Less than 1 minute ago").uppercased()
        }
    }
}

enum TimeUnit {
    case Seconds, minutes, hours, days, months, years
    
    func string(_ count: Int, shouldAbbreviate: Bool = false) -> String {
        let isPlural = count != 1
        var unit: String = ""
        switch self {
        case .Seconds:
            if (shouldAbbreviate) {
                unit = NSLocalizedString("S", comment: "Abbreviated second unit")
            } else {
                unit = isPlural ? NSLocalizedString("seconds", comment: "Second unit")
                    : NSLocalizedString("second", comment: "Second unit")
            }
        case .minutes:
            if (shouldAbbreviate) {
                unit = NSLocalizedString("M", comment: "Abbreviated minute unit")
            } else {
                unit = isPlural ? NSLocalizedString("minutes", comment: "Minute unit")
                    : NSLocalizedString("minute", comment: "Minute unit")
            }
        case .hours:
            if (shouldAbbreviate) {
                unit = NSLocalizedString("H", comment: "Abbreviated hour unit")
            } else {
                unit = isPlural ? NSLocalizedString("hours", comment: "Hour unit")
                    : NSLocalizedString("hour", comment: "Hour unit")
            }
        case .days:
            if (shouldAbbreviate) {
                unit = NSLocalizedString("D", comment: "Abbreviated day unit")
            } else {
                unit = isPlural ? NSLocalizedString("days", comment: "Day unit")
                    : NSLocalizedString("day", comment: "Day unit")
            }
        case .months:
            if (shouldAbbreviate) {
                unit = NSLocalizedString("MO", comment: "Abbreviated month unit")
            } else {
                unit = isPlural ? NSLocalizedString("months", comment: "Month unit")
                    : NSLocalizedString("month", comment: "Month unit")
            }
        case .years:
            if (shouldAbbreviate) {
                unit = NSLocalizedString("Y", comment: "Abbreviated year unit")
            } else {
                unit = isPlural ? NSLocalizedString("years", comment: "Year unit")
                    : NSLocalizedString("year", comment: "Year unit")
            }
        }
        return unit
    }
    
    func seconds() -> Int {
        var seconds: Int = 0
        switch self {
        case .Seconds:
            seconds = 0
        case .minutes:
            seconds = 60
        case .hours:
            seconds = 60 * 60
        case .days:
            seconds = 60 * 60 * 24
        case .months:
            seconds = 60 * 60 * 24 * 30
        case .years:
            seconds = 60 * 60 * 24 * 365
        }
        return seconds
    }
}
