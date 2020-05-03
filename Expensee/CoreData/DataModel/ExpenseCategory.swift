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
    @NSManaged private(set) var uid: UUID
    @NSManaged private(set) var budget: ExpenseBudget?
    @NSManaged private(set) var transactions: Set<ExpenseTransaction>?

    static func insert(category categoryDTO: CategoryDTO,
                       into context: NSManagedObjectContext) -> ExpenseCategory {
        let category: ExpenseCategory = context.insertObject()
        category.name = categoryDTO.name
        category.color = categoryDTO.color
        category.uid = categoryDTO.uid

        if let budget = categoryDTO.budget {
            category.budget = ExpenseBudget.insert(budget: budget, into: context)
        }

        return category
    }

    static func fetchAll(from context: NSManagedObjectContext) throws -> [ExpenseCategory] {

        let fetchRequest = ExpenseCategory.fetchRequest()

        let fetched = try context.fetch(fetchRequest)

        guard let fetchedCategories = fetched as? [ExpenseCategory] else { return [] }

        return fetchedCategories
    }

    static func delete(from context: NSManagedObjectContext) throws {
        let fetchAll = ExpenseCategory.fetchRequest()
        let delete = NSBatchDeleteRequest(fetchRequest: fetchAll)
        try context.execute(delete)
    }

    static func find(by id: UUID, in context: NSManagedObjectContext) -> ExpenseCategory? {
        let predicate = NSPredicate(format:"%K == %@", #keyPath(uid), id as CVarArg)
        return findOrFetch(in: context, matching: predicate)
    }
}

extension ExpenseCategory: Managed {

    static var defaultSortDescriptors: [NSSortDescriptor] {
        return [NSSortDescriptor(key: #keyPath(name), ascending: true)]
    }
}
