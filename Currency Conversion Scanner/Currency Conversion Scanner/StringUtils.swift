//
//  StringUtils.swift
//  Currency Conversion Scanner
//
//  Created by Jimmy Low on 7/6/20.
//  Copyright © 2020 Jimmy Low. All rights reserved.
//

import Foundation

/*
 Extend Character library to add functions for the project
 */
extension Character {
    /*
     This function converts similar character to numbers. For example, s is very similar to S or 5. I is very similar to 1.
     */
    func convertSimilarCharacter(allowedChars: String) -> Character {
        let conversionTable = [
            "s": "S",
            "S": "5",
            "5": "S",
            "o": "O",
            "Q": "O",
            "O": "0",
            "0": "O",
            "l": "I",
            "I": "1",
            "1": "I",
            "B": "8",
            "8": "B"
        ]
        // allows double substitution, for example, 'o' -> 'O' -> '0'
        let maxSubstitutions = 2
        var current = String(self)
        var counter = 0
        // If the input character can be found in the conversion table, substitute
        while !allowedChars.contains(current) && counter < maxSubstitutions {
            if let altChar = conversionTable[current] {
                current = altChar
                counter += 1
            } else {
                // Cannot find, break out
                break
            }
        }
        // again, this is going through character by character, so return only the first char in the string.
        return current.first!
    }
}

extension String {
    /*
     This function checks if string matches a regex pattern, if yes, return its range and value with substituted commonly misrecognized characters. Otherwise, return nil.
    */
    
    func extractValue() -> (Range<String.Index>, String)? {
        /*
         This regex pattern is meant to match currency value ($100, 430円, for example)
         */
        let pattern = #"""
        (?x)                    # Verbose regex, allows comment
        (                       # first case, currency symbol before value
        [$¢£¥฿₨₩€₱₹円]       # Check for list of currency symbol
        [1-9]\d*                # check for a valid number
        |                       # second case, currency symbol after value
        [1-9]\d*             # check for a valid number
        [$¢£¥฿₨₩€₱₹円]          # Check for list of currency symbol
        )                       # close case
        """#
        
        /*
         (?x)                                    # Verbose regex, allows comment
         (                                       # first case, currency symbol before value
         [$¢£¥฿₨₩€₱₹円]                           # Check for list of currency symbol
         (\d{1,3}(\,\d{3})*|(\d+))               # standard currency value
         (\.\d{2})                               # check decimals (cents)
         )|(                                     # second case, currency symbol after value
         (\d{1,3}(\,\d{3})*|(\d+))                # standard currency value
         (\.\d{2})                               # check decimals (cents)
         [$¢£¥฿₨₩€₱₹円]                           # Check for list of currency symbol
         )                                       # close case
         */
        
        /*
         (?x)                    # Verbose regex, allows comment
         (                       # first case, currency symbol before value
         [$¢£¥฿₨₩€₱₹円]       # Check for list of currency symbol
         [1-9]\d*                # check for a valid number
         |                       # second case, currency symbol after value
         [1-9]\d*             # check for a valid number
         [$¢£¥฿₨₩€₱₹円]          # Check for list of currency symbol
         )                       # close case
         */
        
        // Check if string matches a pattern
        guard let range = self.range(of: pattern, options: .regularExpression, range: nil, locale: nil) else {
            // No value found.
            return nil
        }
        
        var priceValue = ""
        // convert type Range to Substring then to String
        let substring = String(self[range])
        let nsrange = NSRange(substring.startIndex..., in: substring)
        do {
            // try to match the regex expression
            let regex = try NSRegularExpression(pattern: pattern, options: [])
            if let match = regex.firstMatch(in: substring, options: [], range: nsrange) {
                // Extracting regex match
                for rangeInd in 1 ..< match.numberOfRanges {
                    let range = match.range(at: rangeInd)
                    // Note that regex might be found as substring so extract it and append to overall string
                    let matchString = (substring as NSString).substring(with: range)
                    priceValue += matchString as String
                }
            }
        } catch {
            print("Error \(error) when creating pattern")
        }
        
        var result = ""
        let allowedChars = "0123456789$¢£¥฿₨₩€₱₹円"
        // Substitute misreconigzed characters
        for var char in priceValue {
            char = char.convertSimilarCharacter(allowedChars: allowedChars)
            guard allowedChars.contains(char) else { return nil }
            result.append(char)
        }
        return (range, result)
    }
}

/*
 This class is to follow the Vision framework standard to verify and ensure the read result is correct by reading the result multiple time, as the recognition method is set to fast, there might be inaccuracy.
 */
class StringTracker {
    var frameIndex: Int = 0
    typealias StringObservation = (lastSeen: Int, count: Int)
    
    // Dictionary of seen strings. Used to get stable recognition before displaying anything.
    var seenStrings = [String: StringObservation]()
    var bestCount = 0
    var bestString = ""

    /*
     This function logs the found string into the dictionary.
     */
    func logFrame(strings: [String]) {
        for string in strings {
            // add unseen string. counts to be incremented at the bottom so start with -1.
            if seenStrings[string] == nil {
                seenStrings[string] = (lastSeen: 0, count: -1)
            }
            seenStrings[string]?.lastSeen = frameIndex
            seenStrings[string]?.count += 1
            print("Seen \(string) \(seenStrings[string]?.count ?? 0) times")  // test in console
        }
    

        for (string, observation) in seenStrings {
            // remove any string that has not been seen in 30 frames (~1s)
            if observation.lastSeen < frameIndex - 30 {
                seenStrings.removeValue(forKey: string)
            }
            
            // Find the string with the greatest count.
            let count = observation.count
            if count > bestCount {
                bestCount = count
                bestString = string
            }
        }
        
        frameIndex += 1
    }
    
    /*
     This function returns the bestString if bestCount is above a stable number (10), otherwise return nil.
     */
    func getStableString() -> String? {
        // minimum 10 confirmed result is to be considered as a stable string
        if bestCount >= 10 {
            return bestString
        } else {
            // if no stable string, return nil
            return nil
        }
    }
    
    /*
     This function resets the value of a string in the dictionary
     */
    func reset(string: String) {
        seenStrings.removeValue(forKey: string)
        bestCount = 0
        bestString = ""
    }
}
