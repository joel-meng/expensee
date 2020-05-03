//
//  CurrencyConvertingUseCase.swift
//  Expensee
//
//  Created by Jun Meng on 3/5/20.
//  Copyright © 2020 Jun Meng. All rights reserved.
//

import Foundation

protocol CurrencyConvertingUseCaseProtocol {

    func convertCurrency(with request: ConvertCurrencyUseCaseRequest) -> Future<ConvertCurrencyUseCaseResponse>
}

final class CurrencyConvertingUseCase: CurrencyConvertingUseCaseProtocol {

    private let currencyConvertingService: CurrencyLayerServiceProtocol

    init(currencyService: CurrencyLayerServiceProtocol) {
        self.currencyConvertingService = currencyService
    }

    func convertCurrency(with request: ConvertCurrencyUseCaseRequest) -> Future<ConvertCurrencyUseCaseResponse> {
        let future = Future<ConvertCurrencyUseCaseResponse>()

        guard request.convertion.fromCurrency == "USD" && request.convertion.toCurrency == "NZD" else {
            future.reject(with: NSError())
            return future
        }

        return currencyConvertingService.historyUSDQuotes(convertionRequest:
            CurrencyConvertionRequestDTO(fromCurrency: request.convertion.fromCurrency,
                                          toCurrency: request.convertion.toCurrency,
                                          date: request.convertion.date,
                                          fromCurrencyAmount: request.convertion.fromCurrencyAmount)).map {
            ConvertCurrencyUseCaseResponse(convertionResult:
                ConvertCurrencyUseCaseResponse
                    .CurrencyConvertionDTO(fromCurrency: $0.fromCurrency,
                                           toCurrency: $0.toCurrency,
                                           date: $0.date,
                                           fromCurrencyAmount: $0.fromCurrencyAmount,
                                           toCurrencyAmount: $0.toCurrencyAmount))
        }
    }
}

struct ConvertCurrencyUseCaseRequest {

    let convertion: CurrencyConvertionDTO

    struct CurrencyConvertionDTO {

        let fromCurrency: String

        let toCurrency: String

        let date: Date

        let fromCurrencyAmount: Double
    }
}

struct ConvertCurrencyUseCaseResponse {

    let convertionResult: CurrencyConvertionDTO

    struct CurrencyConvertionDTO {

        let fromCurrency: String

        let toCurrency: String

        let date: Date

        let fromCurrencyAmount: Double

        let toCurrencyAmount: Double
    }
}
