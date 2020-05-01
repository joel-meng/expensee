//
//  NSManagedObjectContext+CRUD.swift
//  Expensee
//
//  Created by Jun Meng on 30/4/20.
//  Copyright © 2020 Jun Meng. All rights reserved.
//

import Foundation
import CoreData

extension NSManagedObjectContext {

    func insertObject<A: NSManagedObject>() -> A where A: Managed {
        guard let obj = NSEntityDescription.insertNewObject(forEntityName: A.entityName, into: self) as? A else { fatalError("Wrong object type") }
        return obj
    }

    func saveOrRollback() -> Bool {
        do {
            try save()
            return true
        } catch {
            rollback()
            return false
        }
    }

    func performChanges(block: @escaping () -> Void)  {
        performAndWait {
            block()
            _ = self.saveOrRollback()
        }
    }
}

enum CoreStoreError: Error {
    case savingError
}
