//
//  SaveTransactionUserCase.swift
//  Expensee
//
//  Created by Jun Meng on 3/5/20.
//  Copyright © 2020 Jun Meng. All rights reserved.
//

import Foundation

protocol SaveTransactionUseCaseProtocol {

    func saveTransaction(with request: SaveTransactionUseCaseRequest) -> Future<SaveTransactionUseCaseResponse>
}

final class SaveTransactionUseCase: SaveTransactionUseCaseProtocol {

    private let transactionRepository: TransactionRepositoryProtocol

    init(transactionRepository: TransactionRepositoryProtocol) {
        self.transactionRepository = transactionRepository
    }

    func saveTransaction(with request: SaveTransactionUseCaseRequest) -> Future<SaveTransactionUseCaseResponse> {
        return transactionRepository.save(SavingTransactionModel(amount: request.transaction.amount,
                                                                 date: request.transaction.date,
                                                                 currency: request.transaction.currency,
                                                                 uid: request.transaction.uid),
                                          categoryId: request.categoryId).map(SaveTransactionUseCaseResponse.init)
    }
}

struct SaveTransactionUseCaseRequest {

    let transaction: Transaction

    let categoryId: UUID

    struct Transaction {

        let amount: Double

        let date: Date

        let currency: String

        let uid: UUID
    }
}

struct SaveTransactionUseCaseResponse {

    let transaction: TransactionDTO
}
