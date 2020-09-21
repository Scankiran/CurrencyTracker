//
//  DataModel.swift
//  CurrencyTracker
//
//  Created by Said Çankıran on 18.09.2020.
//  Copyright © 2020 Said Çankıran. All rights reserved.
//

import Foundation


class SummaryDataType:Codable {
    private enum CodingKeys:String,CodingKey {
        case name = "name"
        case value = "value"
        case type = "type"
        
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.name = try container.decode(String.self, forKey: .name)
        self.value = try container.decode(String.self, forKey: .value)
        self.type = try container.decode(String.self, forKey: .type)
        
    }
    
    var name:String
    var value:String
    var type:String
    
}


class DetailDataType: Codable {
    private enum CodingKeys:String,CodingKey {
        case name = "name"
        case buy = "buy"
        case sell = "sell"
        case min = "min"
        case max = "max"
        case type = "type"
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.name = try container.decode(String.self, forKey: .name)
        self.buy = try container.decode(String.self, forKey: .buy)
        self.sell = try container.decode(String.self, forKey: .sell)
        self.min = try container.decode(String.self, forKey: .min)
        self.max = try container.decode(String.self, forKey: .max)
        self.type = try container.decode(String.self, forKey: .type)
    }
    
    var name:String
    var buy:String
    var sell:String
    var min:String
    var max:String
    var type:String
}

class BankDataType: Codable {
    private enum CodingKeys:String,CodingKey {
        case name = "bankName"
        case buy = "buy"
        case sell = "sell"
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.name = try container.decode(String.self, forKey: .name)
        self.buy = try container.decode(String.self, forKey: .buy)
        self.sell = try container.decode(String.self, forKey: .sell)
    }
    
    var name:String
    var buy:String
    var sell:String
    
}
