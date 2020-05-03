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
        return categoryLoadUseCase.loadAllCategoryWithTransactions().flatMap { [unowned self] response in
            self.transactionsBudgetize(response)
        }.map { (response) -> ListTransactionInteractionResponse in
            let transactions = response.transactions.map {
                return ListTransactionInteractionResponse.Transaction(id: $0.id,
                                                               amount: $0.amount,
                                                               date: $0.date,
                                                               currency: $0.currency,
                                                               overBudget: $0.overBudget,
                                                               category:
                    ListTransactionInteractionResponse.Category(id: $0.category.id,
                                                                name: $0.category.name,
                                                                color: $0.category.color)
                ) }
            return ListTransactionInteractionResponse(transactions: transactions)
        }
    }

    func transactionsBudgetize(_ transactions: [CategoryDTO: [TransactionDTO]])
        -> Future<TransactionCategoryBudgetResponse> {
        transactions.forEach { (key, value) in
            print(key, value)
        }
        return transactionBudgetingUsecase.transactionBudgetLimitCalculating(request:
            TransactionCategoryBudgetRequest(categorizedTransactions: transactions))
    }
}

struct ListTransactionInteractionRequest {}

struct ListTransactionInteractionResponse {

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
