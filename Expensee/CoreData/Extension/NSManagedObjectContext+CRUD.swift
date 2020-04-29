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

    func insertObject<A: NSManagedObject>() throws -> A where A: Managed {
        guard let saved = NSEntityDescription
            .insertNewObject(forEntityName: A.entityName, into: self) as? A
        else {
            throw CoreStoreError.savingError
        }
        return saved
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

    func performChanges(block: @escaping () -> ()) {
        perform {
            block()
            _ = self.saveOrRollback()
        }
    }
}

enum CoreStoreError: Error {
    case savingError
}
