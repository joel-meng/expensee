//
//  TransactionListOrganisingUseCase.swift
//  Expensee
//
//  Created by Jun Meng on 3/5/20.
//  Copyright © 2020 Jun Meng. All rights reserved.
//

import Foundation

protocol TransactionCategoryBudgetCaseProtocol {

    func transactionBudgetLimitCalculating(request: TransactionCategoryBudgetRequest) -> Future<TransactionCategoryBudgetResponse>
}

final class TransactionCategoryBudgetCase: TransactionCategoryBudgetCaseProtocol {

    private let currencyUseCase: CurrencyConvertingUseCaseProtocol

    private var usdToNZDQuote: Double?

    init(currencyUseCase: CurrencyConvertingUseCaseProtocol) {
        self.currencyUseCase = currencyUseCase
    }

    func transactionBudgetLimitCalculating(request: TransactionCategoryBudgetRequest) -> Future<TransactionCategoryBudgetResponse> {
        if let usdQuote = usdToNZDQuote {
            return calculateTransactionOverBudgets(withQuote: usdQuote, request: request)
        } else {
            return findUSDQuote(at: Date()).flatMap { [weak self]  (response) -> Future<TransactionCategoryBudgetResponse> in
                guard let self = self else {
                    let errorFuture = Future<TransactionCategoryBudgetResponse>()
                    defer { errorFuture.reject(with: NSError()) }
                    return errorFuture
                }
                let usdQuote = response.convertionResult.toCurrencyAmount
                self.usdToNZDQuote = usdQuote
                return self.calculateTransactionOverBudgets(withQuote: usdQuote, request: request)
            }
        }
    }

    private func calculateTransactionOverBudgets(withQuote quote: Double,
                                                 request: TransactionCategoryBudgetRequest)
        -> Future<TransactionCategoryBudgetResponse> {

        let future = Future<TransactionCategoryBudgetResponse>()
        request.categorizedTransactions.forEach { (category, transactions) in
            if let budgetCap = category.budget {
                let budgetLimitInNZD = budgetCap.currency == "USD" ? quote * budgetCap.limit : budgetCap.limit
                let transactionTotal = transactions.reduce(0) { $0 + $1.amount }
                let overBudget = budgetLimitInNZD < transactionTotal

                let calculatedTransactions = transactions.map { (tx) -> TransactionCategoryBudgetResponse.Transaction in
                    TransactionCategoryBudgetResponse.Transaction(id: tx.uid,
                                                                  amount: tx.amount,
                                                                  date: tx.date,
                                                                  currency: tx.currency,
                                                                  overBudget: overBudget,
                                                                  category:
                        TransactionCategoryBudgetResponse.Category(id: category.uid,
                                                                   name: category.name,
                                                                   color: category.color))
                }
                future.resolve(with: TransactionCategoryBudgetResponse(transactions: calculatedTransactions))
            }
        }

        return future
    }

    private func findUSDQuote(at now: Date) -> Future<ConvertCurrencyUseCaseResponse> {
        return currencyUseCase.convertCurrency(with:
            ConvertCurrencyUseCaseRequest(convertion:
                ConvertCurrencyUseCaseRequest
                    .CurrencyConvertionDTO(fromCurrency: "USD",
                                           toCurrency: "NZD",
                                           date: now,
                                           fromCurrencyAmount: 1)))
    }
}

struct TransactionCategoryBudgetRequest {

    let categorizedTransactions: [CategoryDTO: [TransactionDTO]]
}

struct TransactionCategoryBudgetResponse {

    let transactions: [Transaction]

    struct Transaction {

        let id: UUID

        let amount: Double

        let date: Date

        let currency: String

        let overBudget: Bool

        let category: Category
    }

    struct Category {

        let id: UUID

        let name: String

        let color: String
    }
}
