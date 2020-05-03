//
//  CurrencyLayerService.swift
//  Expensee
//
//  Created by Jun Meng on 3/5/20.
//  Copyright © 2020 Jun Meng. All rights reserved.
//

import Foundation

protocol CurrencyLayerServiceProtocol {

    func historyUSDQuotes(convertionRequest: CurrencyConvertionRequestDTO) -> Future<CurrencyConvertionResponseDTO>
}

final class CurrencyLayerService: CurrencyLayerServiceProtocol {

    let queryDateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "YYYY-MM-dd"
        return dateFormatter
    }()

    private func parametrizeDate(_ date: Date) -> String {
        return queryDateFormatter.string(from: date)
    }

    func historyUSDQuotes(convertionRequest: CurrencyConvertionRequestDTO) -> Future<CurrencyConvertionResponseDTO> {
        let future = Future<CurrencyConvertionResponseDTO>()

        let request = historyUSDQuoteRequest {
            ("date", parametrizeDate(convertionRequest.date))
            ("access_key", "1e41bb64ceb47346e6f138aaf6b11dd9")
            ("format", "1")
        }

        Rest.load(request: request,
                  dateDecodingStrategy: JSONDecoder.DateDecodingStrategy.formatted(queryDateFormatter),
                  expectedResultType: CurrencyConvertResponseCodable.self) { (result) in
            switch result {
            case .failure(let error):
                future.reject(with: error)
            case .success(let response):
                let result = CurrencyConvertionResponseDTO(fromCurrency: convertionRequest.fromCurrency,
                                                           toCurrency: convertionRequest.toCurrency,
                                                           date: convertionRequest.date,
                                                           fromCurrencyAmount: convertionRequest.fromCurrencyAmount,
                                                           toCurrencyAmount: response.quotes.usdnzd)
                future.resolve(with: result)
            }
        }

        return future
    }
}

struct CurrencyConvertionRequestDTO {

    let fromCurrency: String

    let toCurrency: String

    let date: Date

    let fromCurrencyAmount: Double
}

struct CurrencyConvertionResponseDTO {

    let fromCurrency: String

    let toCurrency: String

    let date: Date

    let fromCurrencyAmount: Double

    let toCurrencyAmount: Double
}
