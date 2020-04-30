//
//  BudgetRepository.swift
//  Expensee
//
//  Created by Jun Meng on 30/4/20.
//  Copyright © 2020 Jun Meng. All rights reserved.
//

import Foundation
import CoreData

protocol BudgetRepositoryProtocol {

    func save(_ budget: BudgetDTO) -> Future<ExpenseBudget>
}

final class BudgetRepository: BudgetRepositoryProtocol {

    private let context: NSManagedObjectContext?

    init(context: NSManagedObjectContext?) {
        self.context = context
    }

    func save(_ budget: BudgetDTO) -> Future<ExpenseBudget> {
        let future = Future<ExpenseBudget>()
        guard let context = context else {
            future.reject(with: NSError())
            return future
        }

        do {
            let inserted = try ExpenseBudget.insert(budget: budget, into: context)
            future.resolve(with: inserted)
        } catch {
            future.reject(with: error)
        }

        return future
    }
}
