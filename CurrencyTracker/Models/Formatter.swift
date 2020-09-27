//
//  Formatter.swift
//  CurrencyTracker
//
//  Created by Said Çankıran on 22.09.2020.
//  Copyright © 2020 Said Çankıran. All rights reserved.
//

import Foundation

class Formatter {
    static let run = Formatter()
    
    func currencyTypeFormatter(currency name:String) -> String {
        print(name.lowercased())
        switch name.lowercased() {
        case "gram altin":
            return "gold"
        case "dolar":
            return "usd"
        case "sterli̇n":
            return "gbp"
        default:
            return name.lowercased()
        }
    }
}
