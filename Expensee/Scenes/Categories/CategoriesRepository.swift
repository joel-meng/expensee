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
}

extension RepositoryProtocol {

    func perform(action: @escaping () -> Void) {
        context?.performChanges(block: action)
    }

    func save() throws {
        try context?.save()
    }
}

protocol CategoriesRepositoryProtocol: RepositoryProtocol {

    func save(_ category: CategoryDTO) -> Future<ExpenseCategory>

    func fetchAll() -> Future<[CategoryDTO]>
}

final class CategoriesRepository: CategoriesRepositoryProtocol {

    let context: NSManagedObjectContext?

    init(context: NSManagedObjectContext?) {
        self.context = context
    }

    func delete() {
        context?.performChanges {
            try! ExpenseCategory.delete(form: self.context!)
        }
    }

    func save(_ category: CategoryDTO) -> Future<ExpenseCategory> {
        let future = Future<ExpenseCategory>()

        guard let context = context else {
            future.reject(with: NSError())
            return future
        }

        perform {
            let inserted = try! ExpenseCategory.insert(category: category, into: context)
            future.resolve(with: inserted)
        }

        return future
    }

    func fetchAll() -> Future<[CategoryDTO]> {
        let future = Future<[CategoryDTO]>()

        guard let context = context else {
            future.reject(with: NSError())
            return future
        }

        do {
            let fetched = try ExpenseCategory.fetchAll(from: context)
            let categoriesDTO = fetched.map {
                CategoryDTO(name: $0.name, color: $0.color,
                            budget: $0.budget.map {
                                BudgetDTO(currency: $0.currency, limit: $0.limit)
                            })
            }
            future.resolve(with: categoriesDTO)
        } catch {
            future.reject(with: error)
        }

        return future
    }
}
