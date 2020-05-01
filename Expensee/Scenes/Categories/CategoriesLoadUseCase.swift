//
//  CategoriesUseCase.swift
//  Expensee
//
//  Created by Jun Meng on 29/4/20.
//  Copyright © 2020 Jun Meng. All rights reserved.
//

import Foundation

protocol CategoriesLoadUseCaseProtocol {

    func loadAllCategory() -> Future<[CategoryDTO]>
    
    func loadCategory(by id: UUID) -> Future<CategoryDTO?>
}

final class CategoriesLoadUseCase: CategoriesLoadUseCaseProtocol {

    var categoriesRepository: CategoriesRepositoryProtocol
    var budgetRepository: BudgetRepositoryProtocol

    init(categoriesRepository: CategoriesRepositoryProtocol,
         budgetRepository: BudgetRepositoryProtocol) {
        self.categoriesRepository = categoriesRepository
        self.budgetRepository = budgetRepository
    }

    func loadAllCategory() -> Future<[CategoryDTO]> {
        return categoriesRepository.fetchAll()
    }
    
    func loadCategory(by id: UUID) -> Future<CategoryDTO?> {
            // todo: remove budget repo
        return categoriesRepository.fetch(by: id)
    }
}
