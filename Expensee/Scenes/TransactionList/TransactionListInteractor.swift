//
//  TransactionListInteractor.swift
//  Expensee
//
//  Created by Jun Meng on 3/5/20.
//  Copyright © 2020 Jun Meng. All rights reserved.
//

import Foundation

protocol TransactionListInteracting {

    func saveTransaction(with request: ListTransactionInteractionRequest) -> Future<ListTransactionInteractionResponse>
}

final class TransactionListInteractor: TransactionListInteracting {

    func saveTransaction(with request: ListTransactionInteractionRequest) -> Future<ListTransactionInteractionResponse> {
        fatalError()
    }
}

struct ListTransactionInteractionRequest {}

struct ListTransactionInteractionResponse {

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
