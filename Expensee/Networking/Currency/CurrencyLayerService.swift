//
//  CurrencyLayerService.swift
//  Expensee
//
//  Created by Jun Meng on 3/5/20.
//  Copyright © 2020 Jun Meng. All rights reserved.
//

import Foundation

enum Currency: String {
    case nzd = "NZD"
    case usd = "USD"
}

protocol CurrencyLayerServiceProtocol {

    static func historyUSDQuotes(date: Date) -> Future<Double>
}

final class CurrencyLayerService: CurrencyLayerServiceProtocol {

    static private func parametrizeDate(_ date: Date) -> String {
        let queryDateFormatter: DateFormatter = {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "YYYY-MM-dd"
            return dateFormatter
        }()
        return queryDateFormatter.string(from: date)
    }

    static func historyUSDQuotes(date: Date) -> Future<Double> {
        let future = Future<Double>()

        let request = historyUSDQuoteRequest {
            ("date", parametrizeDate(date))
            ("access_key", "1e41bb64ceb47346e6f138aaf6b11dd9")
            ("format", "1")
        }

        Rest.load(request: request, expectedResultType: CurrencyConvertResponse.self) { (result) in
            print(result)
            switch result {
            case .failure(let error): future.reject(with: error)
            case .success(let response):
                future.resolve(with: response.quotes.usdnzd)
            }
        }

        return future
    }
}
