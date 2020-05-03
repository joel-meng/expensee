//
//  TransactionListInteractor.swift
//  Expensee
//
//  Created by Jun Meng on 3/5/20.
//  Copyright © 2020 Jun Meng. All rights reserved.
//

import Foundation

protocol TransactionListInteracting {

    func loadTransactions(with request: ListTransactionInteractionRequest)
        -> Future<ListTransactionInteractionResponse>
}

final class TransactionListInteractor: TransactionListInteracting {

    private let categoryLoadUseCase: CategoriesLoadUseCaseProtocol

    private let transactionBudgetingUsecase: TransactionCategoryBudgetCaseProtocol

    private var categories: [Category] = []

    init(categoryLoadUseCase: CategoriesLoadUseCaseProtocol,
         transactionBudgetingUsecase: TransactionCategoryBudgetCaseProtocol) {
        self.categoryLoadUseCase = categoryLoadUseCase
        self.transactionBudgetingUsecase = transactionBudgetingUsecase
    }

    func loadTransactions(with request: ListTransactionInteractionRequest)
        -> Future<ListTransactionInteractionResponse> {
        let future = Future<ListTransactionInteractionResponse>()

        categoryLoadUseCase.loadAllCategoryWithTransactions().on(success: { [weak self] (category) in
            let mappedCategory = category.map { (category, transactions) in
                Category(id: category.uid, name: category.name, color: category.color, limit: category.budget.map {
                    Limit(amount: $0.limit, currency: $0.currency)
                }, transactions: transactions.map {
                    Transaction(amount: $0.amount, date: $0.date, currency: $0.currency)
                })
            }
            self?.categories = mappedCategory
            future.resolve(with: ListTransactionInteractionResponse(categories: mappedCategory))
        }, failure: { error in
            future.reject(with: error)
        })
        return future
    }
}

struct Transaction {

    let amount: Double

    let date: Date

    let currency: String
}

struct Category {

    let id: UUID

    let name: String

    let color: String

    let limit: Limit?

    let transactions: [Transaction]
}

struct Limit {

    let amount: Double

    let currency: String
}

struct ListTransactionInteractionRequest {}

struct ListTransactionInteractionResponse {

    let categories: [Category]
}
