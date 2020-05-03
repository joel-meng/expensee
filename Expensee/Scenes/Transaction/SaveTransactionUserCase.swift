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
        return transactionRepository.save(request.transaction).map(SaveTransactionUseCaseResponse.init)
    }
}

struct SaveTransactionUseCaseRequest {

    let transaction: TransactionDTO
}

struct SaveTransactionUseCaseResponse {

    let transaction: TransactionDTO
}
