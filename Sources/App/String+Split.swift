//
//  String+Stplit.swift
//  fapl-server
//
//  Created by Roudique on 12/2/16.
//
//

import Foundation

extension String {
    
    func split(delimiter: CharacterSet, needEmpty: Bool = true) -> Array<String> {
        var array = [String]()
        var currentIndex = 0
        
        for i in 0..<self.unicodeScalars.count {
            let c = self.unicodeScalars.array[i]
            
            if delimiter.contains(c) {
                array.append(substring(from: currentIndex, to: i))
                
                currentIndex = i+1
            }
        }
        
        if currentIndex != self.unicodeScalars.count {
            array.append(substring(from: currentIndex, to: self.unicodeScalars.count))
        }
        
        return array.filter({ string in
            !string.isEmpty || needEmpty
        })
    }
    
    fileprivate func substring(from: Int, to: Int) -> String {
        guard from <= to else {
            return ""
        }
        
        var chars = [Character]()
        
        for index in from..<to {
            chars.append(Character.init(self.unicodeScalars.array[index]))
        }
        
        return String.init(String.CharacterView(chars))
    }
    
}
