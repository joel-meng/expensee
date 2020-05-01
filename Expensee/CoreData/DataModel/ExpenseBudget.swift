//
//  ExpenseBudget.swift
//  Expensee
//
//  Created by Jun Meng on 30/4/20.
//  Copyright © 2020 Jun Meng. All rights reserved.
//

import Foundation
import CoreData

class ExpenseBudget: NSManagedObject {

    @NSManaged private(set) var limit: Double
    @NSManaged private(set) var currency: String
    @NSManaged private(set) var category: ExpenseCategory

    static func insert(budget budgetDTO: BudgetDTO,
                       into context: NSManagedObjectContext) -> ExpenseBudget {
        let budget: ExpenseBudget = context.insertObject()
        budget.limit = budgetDTO.limit
        budget.currency = budgetDTO.currency
        return budget
    }

    static func fetchAll(from context: NSManagedObjectContext) throws -> [ExpenseBudget] {

        let fetchRequest = ExpenseBudget.fetchRequest()

        let fetched = try context.fetch(fetchRequest)

        guard let fetchedBudget = fetched as? [ExpenseBudget] else { return [] }

        return fetchedBudget
    }
}

extension ExpenseBudget: Managed {

    static var defaultSortDescriptors: [NSSortDescriptor] {
        return [NSSortDescriptor(key: #keyPath(limit), ascending: true)]
    }
}
