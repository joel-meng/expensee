//
//  CurrencyConvertingUseCase.swift
//  Expensee
//
//  Created by Jun Meng on 3/5/20.
//  Copyright © 2020 Jun Meng. All rights reserved.
//

import Foundation

protocol CurrencyConvertingUseCaseProtocol {

    func convertCurrency(with request: ConvertCurrencyUseCaseRequest) -> Future<ConvertCurrencyUseCaseResposne>
}

final class CurrencyConvertingUseCase: CurrencyConvertingUseCaseProtocol {

    private let currencyConvertingService: CurrencyLayerServiceProtocol

    init(currencyService: CurrencyLayerServiceProtocol) {
        self.currencyConvertingService = currencyService
    }

    func convertCurrency(with request: ConvertCurrencyUseCaseRequest) -> Future<ConvertCurrencyUseCaseResposne> {
        let future = Future<ConvertCurrencyUseCaseResposne>()

        guard request.convertion.fromCurrency == "USD" && request.convertion.toCurrency == "NZD" else {
            future.reject(with: NSError())
            return future
        }

        return currencyConvertingService.historyUSDQuotes(convertionRequest: request.convertion).map {
            ConvertCurrencyUseCaseResposne(convertionResult: $0)
        }
    }
}

struct CurrencyConvertionDTO {

    let fromCurrency: String

    let toCurrency: String

    let date: Date

    let fromCurrencyAmount: Double

    let toCurrencyAmount: Double?
}

struct ConvertCurrencyUseCaseRequest {

    let convertion: CurrencyConvertionDTO
}

struct ConvertCurrencyUseCaseResposne {

    let convertionResult: CurrencyConvertionDTO
}
