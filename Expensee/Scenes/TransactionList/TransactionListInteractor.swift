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

    init(categoryLoadUseCase: CategoriesLoadUseCaseProtocol) {
        self.categoryLoadUseCase = categoryLoadUseCase
    }

    func loadTransactions(with request: ListTransactionInteractionRequest)
        -> Future<ListTransactionInteractionResponse> {
//
//        categoryLoadUseCase.loadAllCategory().map {
//            $0.map {
//                ListTransactionInteractionResponse
//                    .Transaction(amount: <#T##Double#>, date: <#T##Date#>, currency: <#T##String#>, category: <#T##ListTransactionInteractionResponse.Category#>)
//            }
//
//        }
            fatalError()
    }
}

struct ListTransactionInteractionRequest {}

struct ListTransactionInteractionResponse {

    let transactions: [Transaction]

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
