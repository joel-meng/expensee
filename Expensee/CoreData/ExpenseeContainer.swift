//
//  ExpenseeContainer.swift
//  Expensee
//
//  Created by Jun Meng on 29/4/20.
//  Copyright © 2020 Jun Meng. All rights reserved.
//

import Foundation
import CoreData

func createContainer(completion: @escaping (NSPersistentContainer) -> ()) {
    let container = NSPersistentContainer(name: "Expensee")
    container.loadPersistentStores { _, error in
        guard error == nil else { fatalError("Failed to load store: \(error!)") }
        DispatchQueue.main.async { completion(container) }
    }
}
