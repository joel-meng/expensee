//
//  CategoriesRepository.swift
//  Expensee
//
//  Created by Jun Meng on 29/4/20.
//  Copyright © 2020 Jun Meng. All rights reserved.
//

import Foundation
import CoreData

protocol RepositoryProtocol {

    var context: NSManagedObjectContext? { get }

    func perform(action: @escaping () -> Void)

    var workerContext: NSManagedObjectContext { get }

    func save(worker context: NSManagedObjectContext) throws
}

extension RepositoryProtocol {

    func perform(action: @escaping () -> Void) {
        context?.performChanges(block: action)
    }

    func save(worker workerContext: NSManagedObjectContext) throws {
        try workerContext.save()
        try context?.save()
    }

    var workerContext: NSManagedObjectContext {
        let workerContext = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        workerContext.parent = context
        return workerContext
    }
}

protocol CategoriesRepositoryProtocol: RepositoryProtocol {

    func save(_ category: CategoryDTO) -> Future<CategoryDTO>

    func fetchAll() -> Future<[CategoryDTO]>

    func fetchAllWithTransactions() -> Future<[CategoryDTO: [TransactionDTO]]>

    func fetch(by id: UUID) -> Future<CategoryDTO?>

    func update(by categoryDTO: CategoryDTO) -> Future<CategoryDTO>
}

final class CategoriesRepository: CategoriesRepositoryProtocol {

    let context: NSManagedObjectContext?

    init(context: NSManagedObjectContext?) {
        self.context = context
    }

    func save(_ category: CategoryDTO) -> Future<CategoryDTO> {
        let future = Future<CategoryDTO>()

        let context = workerContext

        let inserted = ExpenseCategory.insert(category: category, into: context)
        let categoryDTO = CategoryDTO(name: inserted.name, color: inserted.color, budget: inserted.budget.map {
            BudgetDTO(currency: $0.currency, limit: $0.limit)
        }, uid: category.uid)

        do {
            try save(worker: context)
            future.resolve(with: categoryDTO)
        } catch {
            future.reject(with: error)
        }

        return future
    }

    func fetchAll() -> Future<[CategoryDTO]> {
        let future = Future<[CategoryDTO]>()

        let context = workerContext

        do {
            let fetched = try ExpenseCategory.fetchAll(from: context)
            let categoriesDTO = fetched.map {
                CategoryDTO(name: $0.name, color: $0.color,
                            budget: $0.budget.map {
                                BudgetDTO(currency: $0.currency, limit: $0.limit)
                }, uid: $0.uid)
            }
            future.resolve(with: categoriesDTO)
        } catch {
            future.reject(with: error)
        }

        return future
    }

    func fetchAllWithTransactions() -> Future<[CategoryDTO: [TransactionDTO]]> {
        let future = Future<[CategoryDTO: [TransactionDTO]]>()

        let context = workerContext

        do {
            let fetched = try ExpenseCategory.fetchAll(from: context)
            let result = fetched.map { category -> (CategoryDTO, [TransactionDTO]) in
                let categoryDTO = CategoryDTO(name: category.name,
                                           color: category.color,
                                           budget: category.budget.map { BudgetDTO(currency: $0.currency, limit: $0.limit) },
                                           uid: category.uid)

                let transactionsDTO = category.transactions?.map {
                    TransactionDTO(amount: $0.amount,
                                   date: $0.date,
                                   currency: $0.currency,
                                   uid: $0.uid,
                                   originalAmount: $0.originalAmount,
                                   originalCurrency: $0.originalCurrency)
                } ?? []

                return (categoryDTO, transactionsDTO)
            }

            try save(worker: context)
            future.resolve(with: Dictionary(uniqueKeysWithValues: result))
        } catch  {
            future.reject(with: error)
        }
        return future
    }

    func fetch(by id: UUID) -> Future<CategoryDTO?> {
        let future = Future<CategoryDTO?>()

        let context = workerContext

        let fetched = ExpenseCategory.find(by: id, in: context).map {
            CategoryDTO(name: $0.name, color: $0.color, budget: $0.budget.map {
                BudgetDTO(currency: $0.currency, limit: $0.limit)
            }, uid: $0.uid)
        }

        do {
            try save(worker: context)
            future.resolve(with: fetched)
        } catch  {
            future.reject(with: error)
        }

        return future
    }

    func update(by categoryDTO: CategoryDTO) -> Future<CategoryDTO> {
        let future = Future<CategoryDTO>()
        let context = workerContext

        let found = ExpenseCategory.find(by: categoryDTO.uid, in: context)

        found?.setValue(categoryDTO.color, forKey: "color")
        found?.setValue(categoryDTO.name, forKey: "name")

        if let currency = categoryDTO.budget?.currency, let limit = categoryDTO.budget?.limit {
            if found?.budget == nil {
                let newBudget = ExpenseBudget.insert(budget: BudgetDTO(currency: currency, limit: limit), into: context)
                found?.setValue(newBudget, forKey: "budget")
            }
            found?.budget?.setValue(currency, forKey: "currency")
            found?.budget?.setValue(limit, forKey: "limit")
        }

        if categoryDTO.budget == nil && found?.budget != nil {
            found?.setValue(nil, forKey: "budget")
        }


        do {
            try save(worker: context)
            future.resolve(with: categoryDTO)
        } catch  {
            future.reject(with: error)
        }

        return future
    }
}
