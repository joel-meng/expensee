//
//  CategoriesUseCase.swift
//  Expensee
//
//  Created by Jun Meng on 29/4/20.
//  Copyright © 2020 Jun Meng. All rights reserved.
//

import Foundation

protocol CategoriesSaveUseCaseProtocol {

    func loadAllCategory() -> Future<[CategoryDTO]>

    func saveCategory(with request: CategoriesSaveUseCaseRequest) -> Future<CategoryDTO>
}

final class CategoriesSaveUseCase: CategoriesSaveUseCaseProtocol {

    var categoriesRepository: CategoriesRepositoryProtocol
    var budgetRepository: BudgetRepositoryProtocol

    init(categoriesRepository: CategoriesRepositoryProtocol,
         budgetRepository: BudgetRepositoryProtocol) {
        self.categoriesRepository = categoriesRepository
        self.budgetRepository = budgetRepository
    }

    func deleteAll() {
        (categoriesRepository as! CategoriesRepository).delete()
    }

    func saveCategory(with request: CategoriesSaveUseCaseRequest) -> Future<CategoryDTO> {
        var budgetDTO: BudgetDTO? = nil
        if let limit = request.limit, let currency = request.currency {
            budgetDTO = BudgetDTO(currency: currency, limit: limit)
        }

        let category = categoriesRepository.save(CategoryDTO(name: request.name,
                                                             color: request.color,
                                                             budget: budgetDTO))
        return category.map { CategoryDTO(name: $0.name, color: $0.color, budget: $0.budget.map {
            BudgetDTO(currency: $0.currency, limit: $0.limit)
        })}
    }

    func loadAllCategory() -> Future<[CategoryDTO]> {
        return categoriesRepository.fetchAll()
    }
}

struct CategoriesSaveUseCaseRequest {

    let name: String

    let color: String

    let limit: Double?

    let currency: String?
}
