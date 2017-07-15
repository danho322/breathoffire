//
//  TechniqueSearchable.swift
//  ARX Template
//
//  Created by Daniel Ho on 7/10/17.
//  Copyright © 2017 Daniel Ho. All rights reserved.
//

import Foundation

protocol SearchableData {
    func searchableString() -> String
    func sortPriority() -> Int
}

protocol TechniqueSearchable {
    var searchableArray: [SearchableData] { get set }
    var filteredSearchableArray: [SearchableData] { get set }
    
    func handleSearchText(searchText: String, filteredSearchableArray: @escaping ([SearchableData]) -> ())
    func filterSearchableArray(searchableArray: [SearchableData], searchText: String) -> [SearchableData]
    
    func sortArray(searchableArray: [SearchableData]) -> [SearchableData]
}

extension TechniqueSearchable {
    func handleSearchText(searchText: String, filteredSearchableArray: @escaping ([SearchableData]) -> ()) {
        if (searchableArray.count == 0) {
            filteredSearchableArray([])
            return
        }
        if (searchText == "") {
            DispatchQueue.global(qos: DispatchQoS.QoSClass.userInitiated).async {
                let sortedArray = self.sortArray(searchableArray: self.searchableArray)
                DispatchQueue.main.async {
                    filteredSearchableArray(sortedArray)
                }
            }
        } else {
            DispatchQueue.global(qos: DispatchQoS.QoSClass.userInitiated).async {
                let filteredArray = self.filterSearchableArray(searchableArray: self.searchableArray, searchText: searchText)
                let sortedArray = self.sortArray(searchableArray: filteredArray)
                DispatchQueue.main.async {
                    filteredSearchableArray(sortedArray)
                }
            }
        }
    }
    
    func filterSearchableArray(searchableArray: [SearchableData], searchText: String) -> [SearchableData] {
        let components = searchText
            .trimmingCharacters(in: NSCharacterSet.whitespaces).lowercased()
            .components(separatedBy: " ")
        var regexString = ""
        let performRegex = components.count > 1
        if (performRegex) {
            regexString = "^\(components.joined(separator: ".*[ ]"))"
        }
        return searchableArray.filter({ data in
            if (performRegex) {
                return data.searchableString().lowercased().range(of: regexString, options: NSString.CompareOptions.regularExpression) != nil
            } else {
                let stringMatch = data.searchableString().range(of: searchText, options: NSString.CompareOptions.caseInsensitive) != nil
                return stringMatch
            }
        })
    }
    
    func sortArray(searchableArray: [SearchableData]) -> [SearchableData] {
        return searchableArray.sorted(by: { data1, data2 in
            let sort1 = data1.sortPriority()
            let sort2 = data2.sortPriority()
            if (sort1 != sort2) {
                return sort1 < sort2
            } else {
                return data1.searchableString() < data2.searchableString()
            }
        })
    }
    
//    func contactObjectAlphaSort(_ co1: CharacterAnimationData, co2: CharacterAnimationData) -> Bool {
//        let string1 = co1.fullName().lowercased()
//        let string2 = co2.fullName().lowercased()
//        if let isAlpha1 = string1.characters.first?.isAlpha(),
//            let isAlpha2 = string2.characters.first?.isAlpha() {
//            if (!isAlpha1 && isAlpha2) {
//                return false
//            } else if (isAlpha1 && !isAlpha2) {
//                return true
//            }
//        }
//        if (string1 != string2) {
//            return string1 < string2
//        } else {
//            return co1.contactString < co2.contactString
//        }
//    }
}
