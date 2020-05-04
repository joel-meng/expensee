//
//  ExpenseTransaction.swift
//  Expensee
//
//  Created by Jun Meng on 3/5/20.
//  Copyright © 2020 Jun Meng. All rights reserved.
//

import Foundation
import CoreData

class ExpenseTransaction: NSManagedObject {

    @NSManaged private(set) var amount: Double
    @NSManaged private(set) var currency: String
    @NSManaged private(set) var originalAmount: Double
    @NSManaged private(set) var originalCurrency: String
    @NSManaged private(set) var date: Date
    @NSManaged private(set) var uid: UUID
    @NSManaged private(set) var category: ExpenseCategory

    static func insert(transactionModel: SavingTransactionModel,
                       categoryId: UUID,
                       into context: NSManagedObjectContext) throws -> ExpenseTransaction {
        guard let category = ExpenseCategory.find(by: categoryId, in: context) else {
            throw NSError()
        }

        let transaction: ExpenseTransaction = context.insertObject()
        transaction.amount = transactionModel.amount
        transaction.currency = transactionModel.currency
        transaction.date = transactionModel.date
        transaction.uid = transactionModel.uid
        transaction.originalAmount = transactionModel.originalAmount
        transaction.originalCurrency = transactionModel.originalCurrency
        transaction.category = category

        return transaction
    }

    static func delete(from context: NSManagedObjectContext) throws {
        let fetchAll = ExpenseTransaction.fetchRequest()
        let delete = NSBatchDeleteRequest(fetchRequest: fetchAll)
        try context.execute(delete)
    }

    static func find(by id: UUID, in context: NSManagedObjectContext) -> ExpenseTransaction? {
        let predicate = NSPredicate(format:"%K == %@", #keyPath(uid), id as CVarArg)
        return findOrFetch(in: context, matching: predicate)
    }
}

extension ExpenseTransaction: Managed {

    static var defaultSortDescriptors: [NSSortDescriptor] {
        return [NSSortDescriptor(key: #keyPath(date), ascending: true)]
    }
}
