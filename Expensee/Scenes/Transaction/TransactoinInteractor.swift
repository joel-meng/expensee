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

    private let saveTransactionUseCase: SaveTransactionUseCaseProtocol

    init(currencyConversionUseCase: CurrencyConvertingUseCaseProtocol,
         saveTransactionUseCase: SaveTransactionUseCaseProtocol) {
        self.currencyConversionUseCase = currencyConversionUseCase
        self.saveTransactionUseCase = saveTransactionUseCase
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
            ConvertCurrencyUseCaseRequest
                .CurrencyConvertionDTO(fromCurrency: request.transaction.currency,
                                       toCurrency: "NZD",
                                       date: request.transaction.date,
                                       fromCurrencyAmount: request.transaction.amount))

        return currencyConversionUseCase.convertCurrency(with:conversionRequest).flatMap { [self] x in
            let newRequest = SaveTransactionRequest(transaction:
                SaveTransactionRequest.Transaction(amount: x.convertionResult.toCurrencyAmount,
                                                   date: x.convertionResult.date,
                                                   currency: x.convertionResult.toCurrency,
                                                   category: request.transaction.category))
            return self.saveTransactionInNZD(with: newRequest)
        }
    }

    private func saveTransactionInNZD(with request: SaveTransactionRequest) -> Future<SaveTransactionResponse> {
        let userCaseRequest = SaveTransactionUseCaseRequest(transaction:
            TransactionDTO(amount: request.transaction.amount,
                           date: request.transaction.date,
                           currency: request.transaction.currency,
                           uid: UUID(),
                           category: CategoryDTO(name: request.transaction.category.name,
                                                 color: request.transaction.category.color,
                                                 budget: request.transaction.category.limit.map {
                                                    BudgetDTO(currency: $0.currency, limit: $0.amount)},
                                                 uid: request.transaction.category.id)))

        return saveTransactionUseCase.saveTransaction(with: userCaseRequest).map {
            SaveTransactionResponse(transaction:
                SaveTransactionResponse.Transaction(amount: $0.transaction.amount,
                                                    date: $0.transaction.date,
                                                    currency: $0.transaction.currency,
                                                    category:
                    SaveTransactionResponse.Category(id: $0.transaction.category.uid,
                                                     name: $0.transaction.category.name,
                                                     color: $0.transaction.category.color,
                                                     limit: $0.transaction.category.budget.map {
                                                        SaveTransactionResponse.Limit(amount: $0.limit, currency: $0.currency)})))
        }
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
