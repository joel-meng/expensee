//
//  CategoriesRepository.swift
//  Expensee
//
//  Created by Jun Meng on 29/4/20.
//  Copyright © 2020 Jun Meng. All rights reserved.
//

import Foundation
import CoreData

protocol CategoriesRepositoryProtocol {

    func save(_ category: CategoryDTO) throws
}

final class CategoriesRepository: CategoriesRepositoryProtocol {

    private let store: CoreDataStore

    init(store: CoreDataStore) {
        self.store = store
    }

    func save(_ category: CategoryDTO) throws {

        guard let context = store.context else {
            throw NSError()
        }

        _ = try ExpenseCategory.insert(category: category, into: context)
    }
}
