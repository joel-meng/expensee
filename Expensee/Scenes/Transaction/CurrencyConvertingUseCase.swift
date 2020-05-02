//
//  CurrencyConvertingUseCase.swift
//  Expensee
//
//  Created by Jun Meng on 3/5/20.
//  Copyright © 2020 Jun Meng. All rights reserved.
//

import Foundation

protocol CurrencyConvertingUseCaseProtocol {

    func convertCurrency(with request: ConvertCurrencyRequest) -> ConvertCurrencyResposne
}

final class CurrencyConvertingUseCase: CurrencyConvertingUseCaseProtocol {

    func convertCurrency(with request: ConvertCurrencyRequest) -> ConvertCurrencyResposne {
        fatalError()
    }
}

struct ConvertCurrencyRequest {

    let convertion: [Convertion]

    struct Convertion {

        let fromCurrency: String

        let toCurrency: String

        let date: Date

        let amount: Double
    }
}

struct ConvertCurrencyResposne {

    let convertionResult: [ConvertionResult]

    struct ConvertionResult {

        let fromCurrency: String

        let toCurrency: String

        let date: Date

        let originalAmount: Double

        let resultAmount: Double
    }
}
