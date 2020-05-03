//
//  CurrencyConvertResponse.swift
//  Expensee
//
//  Created by Jun Meng on 3/5/20.
//  Copyright © 2020 Jun Meng. All rights reserved.
//

import Foundation
/*
 {
 "success":true,
 "terms":"https:\/\/currencylayer.com\/terms",
 "privacy":"https:\/\/currencylayer.com\/privacy",
 "historical":true,
 "date":"2020-01-02",
 "timestamp":1578009599,
 "source":"USD",
 "quotes":{
   "USDAED":3.673199,
   "USDAFN":77.199896,
   "USDALL":108.449778,
   "USDAMD":478.89766,
*/

struct CurrencyConvertResponse: Codable {
    let success: Bool
    let timestamp: TimeInterval
    let source: String
    let date: Date
    let quotes: Quote
}

struct Quote: Codable {
    let usdnzd: Double

    enum CodingKeys: String, CodingKey {
        case usdnzd = "USDNZD"
    }
}
