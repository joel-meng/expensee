//
//  TransactionRepository.swift
//  Expensee
//
//  Created by Jun Meng on 3/5/20.
//  Copyright © 2020 Jun Meng. All rights reserved.
//

import Foundation
import CoreData

protocol TransactionRepositoryProtocol: RepositoryProtocol {

    func save(_ transaction: TransactionDTO) -> Future<TransactionDTO>

    func fetchAll() -> Future<[TransactionDTO]>

    func fetch(by id: UUID) -> Future<TransactionDTO?>
}

final class TransactionRepository: TransactionRepositoryProtocol {

    let context: NSManagedObjectContext?

    init(context: NSManagedObjectContext?) {
        self.context = context
    }

    func save(_ transaction: TransactionDTO) -> Future<TransactionDTO> {
        let future = Future<TransactionDTO>()

        guard let context = context else {
            future.reject(with: NSError())
            return future
        }

        perform {
            let inserted = ExpenseTransaction.insert(category: transaction, into: context)
            let transactionDTO = TransactionDTO(amount: inserted.amount,
                                                date: inserted.date,
                                                currency: inserted.currency,
                                                uid: inserted.uid,
                                                category: inserted.category.map {
                                                    CategoryDTO(name: $0.name,
                                                                color: $0.color,
                                                                budget: $0.budget.map {
                                                        BudgetDTO(currency: $0.currency, limit: $0.limit)
                                                    }, uid: $0.uid)
                                                }!)
            future.resolve(with: transactionDTO)
        }
        return future
    }

    func fetchAll() -> Future<[TransactionDTO]> {
        fatalError()
    }

    func fetch(by id: UUID) -> Future<TransactionDTO?> {
        fatalError()
    }
}
