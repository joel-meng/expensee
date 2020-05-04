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

    func save(_ transaction: SavingTransactionModel, categoryId: UUID) -> Future<(TransactionDTO, CategoryDTO)>

    func fetchAll() -> Future<[TransactionDTO]>

    func fetch(by id: UUID) -> Future<(TransactionDTO, CategoryDTO)?>
}

final class TransactionRepository: TransactionRepositoryProtocol {

    let context: NSManagedObjectContext?

    init(context: NSManagedObjectContext?) {
        self.context = context
    }

    func save(_ transaction: SavingTransactionModel, categoryId: UUID) -> Future<(TransactionDTO, CategoryDTO)> {
        let future = Future<(TransactionDTO, CategoryDTO)>()

        guard let context = context else {
            future.reject(with: NSError())
            return future
        }

        do {
            let inserted = try ExpenseTransaction.insert(transactionModel: transaction,
                                                         categoryId: categoryId,
                                                         into: context)

            let transactionDTO = TransactionDTO(amount: inserted.amount,
                                                date: inserted.date,
                                                currency: inserted.currency,
                                                uid: inserted.uid,
                                                originalAmount: inserted.originalAmount,
                                                originalCurrency: inserted.originalCurrency)

            let categoryDTO = CategoryDTO(name: inserted.category.name,
                                          color: inserted.category.color,
                                          budget: inserted.category.budget.map {
                                            BudgetDTO(currency: $0.currency, limit: $0.limit)},
                                          uid: inserted.category.uid)

            try save()

            future.resolve(with: (transactionDTO, categoryDTO))
        } catch {
            future.reject(with: error)
        }

        return future
    }

    func fetchAll() -> Future<[TransactionDTO]> {
        fatalError()
    }

    func fetch(by id: UUID) -> Future<(TransactionDTO, CategoryDTO)?> {
        let future = Future<(TransactionDTO, CategoryDTO)?>()

        guard let context = context else {
            future.reject(with: NSError())
            return future
        }

        let fetched = ExpenseTransaction.find(by: id, in: context).map { tx -> (TransactionDTO, CategoryDTO) in
            let transaction = TransactionDTO(amount: tx.amount,
                           date: tx.date,
                           currency: tx.currency,
                           uid: tx.uid,
                           originalAmount: tx.originalAmount,
                           originalCurrency: tx.originalCurrency)

            let category = CategoryDTO(name: tx.category.name,
                        color: tx.category.color,
                        budget: tx.category.budget.map {
                            BudgetDTO(currency: $0.currency, limit: $0.limit)
            }, uid: tx.category.uid)
            return (transaction, category)
        }

        future.resolve(with: fetched)
        return future
    }
}

struct SavingTransactionModel {

    let amount: Double

    let currency: String

    let originalAmount: Double

    let originalCurrency: String

    let date: Date

    let uid: UUID
}
