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
    
    static var shared: CoreDataStore?
    
    static func initialize(completion: @escaping () -> Void) {
        shared = CoreDataStore(completion)
    }

    private init(_ completion: @escaping () -> Void) {
        createContainer { (container) in
            self.container = container
            completion()
        }
    }

    var context: NSManagedObjectContext? {
        return container?.viewContext
    }
}
