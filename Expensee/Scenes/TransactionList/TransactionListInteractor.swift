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

    func fetchTransaction(with request: FetchTransactionInteractionRequest) -> Future<FetchTransactionInteractionResponse>
}

final class TransactionListInteractor: TransactionListInteracting {

    private let categoryLoadUseCase: CategoriesLoadUseCaseProtocol

    private let transactionBudgetingUsecase: TransactionCategoryBudgetCaseProtocol

    private let transactionLoadUseCase: TransactionLoadUseCaseProtocol

    private var categories: [Category] = []

    init(categoryLoadUseCase: CategoriesLoadUseCaseProtocol,
         transactionBudgetingUsecase: TransactionCategoryBudgetCaseProtocol,
         transactionLoadUseCase: TransactionLoadUseCaseProtocol) {
        self.categoryLoadUseCase = categoryLoadUseCase
        self.transactionBudgetingUsecase = transactionBudgetingUsecase
        self.transactionLoadUseCase = transactionLoadUseCase
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
                                                               originalAmount: $0.originalAmount,
                                                               originalCurrency: $0.originalCurrency,
                                                               category:
                    ListTransactionInteractionResponse.Category(id: $0.category.id,
                                                                name: $0.category.name,
                                                                color: $0.category.color)
                ) }
            return ListTransactionInteractionResponse(transactions: transactions)
        }
    }

    private func transactionsBudgetize(_ transactions: [CategoryDTO: [TransactionDTO]])
        -> Future<TransactionCategoryBudgetResponse> {
        return transactionBudgetingUsecase.transactionBudgetLimitCalculating(request:
            TransactionCategoryBudgetRequest(categorizedTransactions: transactions))
    }

    func fetchTransaction(with request: FetchTransactionInteractionRequest) -> Future<FetchTransactionInteractionResponse> {
        return transactionLoadUseCase.fetchTransaction(with:
            TransactionLoadUseCaseRequest(transactionId: request.transactionId)).map {
                guard let result = $0.result else { return FetchTransactionInteractionResponse(transaction: nil) }
                return FetchTransactionInteractionResponse(transaction:
                    FetchTransactionInteractionResponse
                        .Transaction(id: result.transaction.uid,
                                     amount: result.transaction.amount,
                                     date: result.transaction.date,
                                     currency: result.transaction.currency,
                                     originalAmount: result.transaction.originalAmount,
                                     originalCurrency: result.transaction.originalCurrency,
                                     category: FetchTransactionInteractionResponse.Category(id: result.category.uid,
                                                                                            name: result.category.name,
                                                                                            color: result.category.color)))}
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

        let originalAmount: Double

        let originalCurrency: String

        let category: Category
    }

    struct Category {

        let id: UUID

        let name: String

        let color: String
    }
}

struct FetchTransactionInteractionRequest {
    let transactionId: UUID
}

struct FetchTransactionInteractionResponse {

    let transaction: Transaction?

    struct Transaction {

        let id: UUID

        let amount: Double

        let date: Date

        let currency: String

        let originalAmount: Double

        let originalCurrency: String

        let category: Category
    }

    struct Category {

        let id: UUID

        let name: String

        let color: String
    }
}
