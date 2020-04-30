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

    func save(_ category: CategoryDTO) -> Future<CategoryDTO>

    func fetchAll() -> Future<[CategoryDTO]>
}

final class CategoriesRepository: CategoriesRepositoryProtocol {

    private let store: CoreDataStore

    init(store: CoreDataStore) {
        self.store = store
    }

    func save(_ category: CategoryDTO) -> Future<CategoryDTO> {
        let future = Future<CategoryDTO>()

        guard let context = store.context else {
            future.reject(with: NSError())
            return future
        }

        context.performChanges {
            let inserted = try! ExpenseCategory.insert(category: category, into: context)
            future.resolve(with: CategoryDTO(name: inserted.name, color: inserted.color))
        }

        return future
    }

    func fetchAll() -> Future<[CategoryDTO]> {
        let future = Future<[CategoryDTO]>()

        guard let context = store.context else {
            future.reject(with: NSError())
            return future
        }

        do {
            let fetched = try ExpenseCategory.fetchAll(from: context)
            let categoriesDTO = fetched.map { CategoryDTO(name: $0.name, color: $0.color) }
            future.resolve(with: categoriesDTO)
        } catch {
            future.reject(with: error)
        }

        return future
    }
}
