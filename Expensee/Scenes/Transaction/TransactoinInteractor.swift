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

    func updateTransaction(with request: UpdateTransactionRequest) -> Future<UpdateTransactionResponse>
}

final class TransactionInteractor: TransactionInteracting {

    private let currencyConversionUseCase: CurrencyConvertingUseCaseProtocol

    private let saveTransactionUseCase: SaveTransactionUseCaseProtocol

    init(currencyConversionUseCase: CurrencyConvertingUseCaseProtocol,
         saveTransactionUseCase: SaveTransactionUseCaseProtocol) {
        self.currencyConversionUseCase = currencyConversionUseCase
        self.saveTransactionUseCase = saveTransactionUseCase
    }

    // MARK: - Transaction Saving

    func saveTransaction(with request: SaveTransactionRequest) -> Future<SaveTransactionResponse> {
        switch request.transaction.currency {
        case "USD":
            return convertUSDToNZD(fromCurrency: request.transaction.currency,
                                   date: request.transaction.date,
                                   amount: request.transaction.amount).flatMap { [unowned self] in

                let savingRequest = SaveTransactionUseCaseRequest(transaction:
                    SaveTransactionUseCaseRequest
                        .Transaction(amount: $0.convertionResult.toCurrencyAmount * request.transaction.amount,
                                     date: request.transaction.date,
                                     currency: $0.convertionResult.toCurrency,
                                     uid: UUID(),
                                     originalAmount: request.transaction.amount,
                                     originalCurrency: request.transaction.currency),
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

    private func convertUSDToNZD(fromCurrency: String, date: Date, amount: Double) -> Future<ConvertCurrencyUseCaseResponse> {
        let conversionRequest = ConvertCurrencyUseCaseRequest(convertion:
            ConvertCurrencyUseCaseRequest
                .CurrencyConvertionDTO(fromCurrency: fromCurrency,
                                       toCurrency: "NZD",
                                       date: date,
                                       fromCurrencyAmount: amount))
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

    // MARK: - Transaction Updating

    func updateTransaction(with request: UpdateTransactionRequest) -> Future<UpdateTransactionResponse> {
        switch request.transaction.currency {
        case "USD":
            return convertUSDToNZD(fromCurrency: request.transaction.currency,
                                   date: request.transaction.date,
                                   amount: request.transaction.amount).flatMap { [unowned self] in

                let savingRequest = UpdateTransactionUseCaseRequest(transaction:
                    UpdateTransactionUseCaseRequest
                        .Transaction(amount: $0.convertionResult.toCurrencyAmount * request.transaction.amount,
                                     date: request.transaction.date,
                                     currency: $0.convertionResult.toCurrency,
                                     uid: UUID(),
                                     originalAmount: request.transaction.amount,
                                     originalCurrency: request.transaction.currency),
                                                                  categoryId: request.categoryId)
                return self.updateTransactionInNZD(with: savingRequest)
            }

        case "NZD":
            let useCaseRequest = UpdateTransactionUseCaseRequest(transaction:
                       UpdateTransactionUseCaseRequest.Transaction(amount: request.transaction.amount,
                                                                   date: request.transaction.date,
                                                                    currency: request.transaction.currency,
                                                                    uid: UUID(),
                                                                    originalAmount: request.transaction.amount,
                                                                    originalCurrency: request.transaction.currency),
                                                                    categoryId: request.categoryId)
            return updateTransactionInNZD(with: useCaseRequest)
        default: fatalError("Not Supported")
        }
    }

    private func updateTransactionInNZD(with request: UpdateTransactionUseCaseRequest) -> Future<UpdateTransactionResponse> {
        return saveTransactionUseCase.updateTransaction(with: request).map {
            UpdateTransactionResponse(transaction:
                UpdateTransactionResponse
                    .Transaction(amount: $0.transaction.amount,
                                 date: $0.transaction.date,
                                 currency: $0.transaction.currency,
                                 category: UpdateTransactionResponse
                                    .Category(id: $0.category.uid,
                                              name: $0.category.name,
                                              color: $0.category.color,
                                              limit: $0.category.budget.map {
                                                UpdateTransactionResponse.Limit(amount: $0.limit,
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

struct UpdateTransactionRequest {

    let transaction: Transaction

    let categoryId: UUID

    struct Transaction {

        let amount: Double

        let date: Date

        let currency: String
    }
}

struct UpdateTransactionResponse {

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
