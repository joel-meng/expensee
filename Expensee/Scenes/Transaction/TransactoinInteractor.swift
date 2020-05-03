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
        case "USD":
            return convertUSDToNZD(with: request).flatMap { [unowned self] in
                let savingRequest = SaveTransactionUseCaseRequest(transaction:
                    SaveTransactionUseCaseRequest
                        .Transaction(amount: $0.convertionResult.toCurrencyAmount,
                                     date: $0.convertionResult.date,
                                     currency: $0.convertionResult.toCurrency,
                                     uid: UUID(),
                                     originalAmount: $0.convertionResult.fromCurrencyAmount,
                                     originalCurrency: $0.convertionResult.fromCurrency),
                                                                  categoryId: request.categoryId)
                return self.saveTransactionInNZD(with: savingRequest)
            }

        case "NZD":
            let useCaseRequest = SaveTransactionUseCaseRequest(transaction:
                       SaveTransactionUseCaseRequest.Transaction(amount: request.transaction.amount,
                                                                 date: request.transaction.date,
                                                                 currency: request.transaction.currency,
                                                                 uid: UUID(),
                                                                 originalAmount: request.transaction.amount,
                                                                 originalCurrency: request.transaction.currency),
                                                                categoryId: request.categoryId)
            return saveTransactionInNZD(with: useCaseRequest)
        default: fatalError("Not Supported")
        }
    }

    private func convertUSDToNZD(with request: SaveTransactionRequest) -> Future<ConvertCurrencyUseCaseResponse> {
        let conversionRequest = ConvertCurrencyUseCaseRequest(convertion:
            ConvertCurrencyUseCaseRequest
                .CurrencyConvertionDTO(fromCurrency: request.transaction.currency,
                                       toCurrency: "NZD",
                                       date: request.transaction.date,
                                       fromCurrencyAmount: request.transaction.amount))
        return currencyConversionUseCase.convertCurrency(with: conversionRequest)
    }

    private func saveTransactionInNZD(with request: SaveTransactionUseCaseRequest) -> Future<SaveTransactionResponse> {

        return saveTransactionUseCase.saveTransaction(with: request).map {
            SaveTransactionResponse(transaction:
                SaveTransactionResponse
                    .Transaction(amount: $0.transaction.amount,
                                 date: $0.transaction.date,
                                 currency: $0.transaction.currency,
                                 category:
                        SaveTransactionResponse
                            .Category(id: $0.category.uid,
                                      name: $0.category.name,
                                      color: $0.category.color,
                                      limit: $0.category.budget.map {
                                        SaveTransactionResponse
                                            .Limit(amount: $0.limit,
                                                   currency: $0.currency)})))
        }
    }
}

struct SaveTransactionRequest {

    let transaction: Transaction

    let categoryId: UUID

    struct Transaction {

        let amount: Double

        let date: Date

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
