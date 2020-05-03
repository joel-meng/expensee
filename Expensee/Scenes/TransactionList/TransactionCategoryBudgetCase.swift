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
            let future = Future<TransactionCategoryBudgetResponse>()
            let response = calculateTransactionOverBudgets(withQuote: usdQuote, request: request)
            future.resolve(with: response)
            return future
        } else {
            return findUSDQuote(at: Date()).map { [unowned self]  (response) -> TransactionCategoryBudgetResponse in
                let usdQuote = response.convertionResult.toCurrencyAmount
                self.usdToNZDQuote = usdQuote
                return self.calculateTransactionOverBudgets(withQuote: usdQuote, request: request)
            }
        }
    }

    private func calculateTransactionOverBudgets(withQuote quote: Double,
                                                 request: TransactionCategoryBudgetRequest)
        -> TransactionCategoryBudgetResponse {

        let transactions = request.categorizedTransactions.flatMap { (category, transactions) -> [TransactionCategoryBudgetResponse.Transaction] in
            if let budgetCap = category.budget {
                let budgetLimitInNZD = budgetCap.currency == "USD" ? quote * budgetCap.limit : budgetCap.limit
                let transactionTotal = transactions.reduce(0) { $0 + $1.amount }
                let overBudget = budgetLimitInNZD < transactionTotal

                return mapTransactionDTOList(transactions, category: category, overBudget: overBudget)
            } else {
                return mapTransactionDTOList(transactions, category: category, overBudget: false)
            }
        }
        return TransactionCategoryBudgetResponse(transactions: transactions)
    }

    private func mapTransactionDTOList(_ transactions: [TransactionDTO],
                                       category: CategoryDTO,
                                       overBudget: Bool) -> [TransactionCategoryBudgetResponse.Transaction] {
        return transactions.map { (tx) -> TransactionCategoryBudgetResponse.Transaction in
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
