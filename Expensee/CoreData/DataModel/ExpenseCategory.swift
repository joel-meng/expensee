//
//  ExpenseCategory.swift
//  Expensee
//
//  Created by Jun Meng on 29/4/20.
//  Copyright © 2020 Jun Meng. All rights reserved.
//

import Foundation
import CoreData

class ExpenseCategory: NSManagedObject {

    @NSManaged private(set) var name: String
    @NSManaged private(set) var color: String
    @NSManaged private(set) var budget: ExpenseBudget?

    static func insert(category categoryDTO: CategoryDTO,
                       into context: NSManagedObjectContext) throws -> ExpenseCategory {
        let category: ExpenseCategory = try context.insertObject()
        category.name = categoryDTO.name
        category.color = categoryDTO.color

        if let budget = categoryDTO.budget {
            category.budget = try ExpenseBudget.insert(budget: budget, into: context)
        }
        return category
    }

    static func fetchAll(from context: NSManagedObjectContext) throws -> [ExpenseCategory] {

        let fetchRequest = ExpenseCategory.fetchRequest()

        let fetched = try context.fetch(fetchRequest)

        guard let fetchedCategories = fetched as? [ExpenseCategory] else { return [] }

        return fetchedCategories
    }
}

extension ExpenseCategory: Managed {

    static var defaultSortDescriptors: [NSSortDescriptor] {
        return [NSSortDescriptor(key: #keyPath(name), ascending: true)]
    }
}
