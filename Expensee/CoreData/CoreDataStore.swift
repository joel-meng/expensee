//
//  CoreDataRepository.swift
//  Expensee
//
//  Created by Jun Meng on 29/4/20.
//  Copyright © 2020 Jun Meng. All rights reserved.
//

import Foundation
import CoreData

final class CoreDataStore {
    
    private var container: NSPersistentContainer?
    
    static let shared = CoreDataStore()
    
    private init() {
        createContainer { (container) in
            self.container = container
        }
    }

    var context: NSManagedObjectContext? {
        return container?.viewContext
    }
}
