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

    static func insert(category categoryDTO: CategoryDTO,
                       into context: NSManagedObjectContext) throws -> ExpenseCategory {
        let category: ExpenseCategory = try context.insertObject()
        category.name = categoryDTO.name
        category.color = categoryDTO.color
        return category
    }
}

extension ExpenseCategory: Managed {

    static var defaultSortDescriptors: [NSSortDescriptor] {
        return [NSSortDescriptor(key: #keyPath(name), ascending: true)]
    }
}
