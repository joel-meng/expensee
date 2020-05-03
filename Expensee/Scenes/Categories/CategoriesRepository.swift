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

    func save(_ category: CategoryDTO) -> Future<CategoryDTO>

    func fetchAll() -> Future<[CategoryDTO]>

    func fetch(by id: UUID) -> Future<CategoryDTO?>
}

final class CategoriesRepository: CategoriesRepositoryProtocol {

    let context: NSManagedObjectContext?

    init(context: NSManagedObjectContext?) {
        self.context = context
    }

    func save(_ category: CategoryDTO) -> Future<CategoryDTO> {
        let future = Future<CategoryDTO>()

        guard let context = context else {
            future.reject(with: NSError())
            return future
        }

        perform {
            let inserted = ExpenseCategory.insert(category: category, into: context)
            let categoryDTO = CategoryDTO(name: inserted.name, color: inserted.color, budget: inserted.budget.map {
                BudgetDTO(currency: $0.currency, limit: $0.limit)
            }, uid: category.uid)
            future.resolve(with: categoryDTO)
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
                }, uid: $0.uid)
            }
            future.resolve(with: categoriesDTO)
        } catch {
            future.reject(with: error)
        }

        return future
    }

    func fetch(by id: UUID) -> Future<CategoryDTO?> {
        let future = Future<CategoryDTO?>()

        guard let context = context else {
            future.reject(with: NSError())
            return future
        }

        let fetched = ExpenseCategory.find(by: id, in: context).map {
            CategoryDTO(name: $0.name, color: $0.color, budget: $0.budget.map {
                BudgetDTO(currency: $0.currency, limit: $0.limit)
            }, uid: $0.uid)
        }

        future.resolve(with: fetched)
        return future
    }

    func update(by categoryDTO: CategoryDTO) -> Future<CategoryDTO> {
        let future = Future<CategoryDTO>()
        guard let context = context else {
            future.reject(with: NSError())
            return future
        }

        let found = ExpenseCategory.find(by: categoryDTO.uid, in: context)

        perform {
            found?.setValue(categoryDTO.color, forKey: "color")
            found?.setValue(categoryDTO.name, forKey: "name")
            found?.budget?.setValue(categoryDTO.budget?.currency, forKey: "currency")
            found?.budget?.setValue(categoryDTO.budget?.limit, forKey: "limit")
            future.resolve(with: categoryDTO)
        }

        return future
    }
}
