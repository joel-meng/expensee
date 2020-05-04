//
//  LoadTransactionUseCase.swift
//  Expensee
//
//  Created by Jun Meng on 4/5/20.
//  Copyright © 2020 Jun Meng. All rights reserved.
//

import Foundation

protocol TransactionLoadUseCaseProtocol {

    func fetchTransaction(with request: TransactionLoadUseCaseRequest) -> Future<TransactionLoadUseCaseResponse>
}

final class TransactionLoadUseCase: TransactionLoadUseCaseProtocol {

    private let transactionRepository: TransactionRepositoryProtocol

    init(transactionRepository: TransactionRepositoryProtocol) {
        self.transactionRepository = transactionRepository
    }

    func fetchTransaction(with request: TransactionLoadUseCaseRequest) -> Future<TransactionLoadUseCaseResponse> {
        return transactionRepository.fetch(by: request.transactionId).map {
            let loadResult = $0.map {
                TransactionLoadUseCaseResponse.LoadResult(transaction: $0.0, category: $0.1)
            }
            return TransactionLoadUseCaseResponse(result: loadResult)
        }
    }
}

struct TransactionLoadUseCaseRequest {

    let transactionId: UUID
}

struct TransactionLoadUseCaseResponse {

    let result: LoadResult?

    struct LoadResult {

        let transaction: TransactionDTO

        let category: CategoryDTO
    }
}
