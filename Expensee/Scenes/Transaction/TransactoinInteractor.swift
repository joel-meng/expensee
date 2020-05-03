//
//  TransactoinInteractor.swift
//  Expensee
//
//  Created by Jun Meng on 3/5/20.
//  Copyright © 2020 Jun Meng. All rights reserved.
//

import Foundation

protocol TransactionInteracting {

    func saveTransaction(with request: SaveTransactionRequest) -> Future<SaveTransactionResponse>
}

final class TransactionInteractor: TransactionInteracting {

    private let currencyConversionUseCase: CurrencyConvertingUseCaseProtocol

    init(currencyConversionUseCase: CurrencyConvertingUseCaseProtocol) {
        self.currencyConversionUseCase = currencyConversionUseCase
    }

    func saveTransaction(with request: SaveTransactionRequest) -> Future<SaveTransactionResponse> {

        switch request.transaction.currency {
        case "USD": return saveTransactionInUSD(with: request)
        case "NZD": return saveTransactionInNZD(with: request)
        default: fatalError("Not Supported")
        }
    }

    private func saveTransactionInUSD(with request: SaveTransactionRequest) -> Future<SaveTransactionResponse> {
        let conversionRequest = ConvertCurrencyUseCaseRequest(convertion:
            CurrencyConvertionDTO(fromCurrency: request.transaction.currency,
                                  toCurrency: "NZD",
                                  date: request.transaction.date,
                                  fromCurrencyAmount: request.transaction.amount,
                                  toCurrencyAmount: nil))
        return currencyConversionUseCase.convertCurrency(with:conversionRequest).map { x in
            print(x)
            return SaveTransactionResponse(transaction: SaveTransactionResponse.Transaction())
        }
    }

    private func saveTransactionInNZD(with request: SaveTransactionRequest) -> Future<SaveTransactionResponse> {
        fatalError()
    }
}

struct SaveTransactionRequest {

    let transaction: Transaction

    struct Transaction {

        let amount: Double

        let date: Date

        let currency: String

        let category: Category
    }

    struct Category {

        let id: UUID

        let name: String

        let color: String

        let limit: Limit?
    }

    struct Limit {

        let amount: Double

        let currency: String
    }
}

struct SaveTransactionResponse {

    let transaction: Transaction

    struct Transaction {

    }
}
