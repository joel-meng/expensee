//
//  CategoriesInteractor.swift
//  Expensee
//
//  Created by Jun Meng on 29/4/20.
//  Copyright © 2020 Jun Meng. All rights reserved.
//

import Foundation

protocol CategoriesInteracting {

    func loadCategories() -> Future<CategoriesLoadResponse>

    func saveCategory(with reqeust: CategoriesSavingRequest) -> Future<CategoriesSavingRequest.Category>
}

final class CategoriesInteractor: CategoriesInteracting {

    private var categoriesSavingUseCase: CategoriesSaveUseCaseProtocol

    init(categoriesSavingUseCase: CategoriesSaveUseCaseProtocol) {
        self.categoriesSavingUseCase = categoriesSavingUseCase
    }

    func loadCategories() -> Future<CategoriesLoadResponse> {
        let future = categoriesSavingUseCase.loadAllCategory()

        return future.map { (categories) -> CategoriesLoadResponse in
            CategoriesLoadResponse(categories: categories.map {
                CategoriesLoadResponse.Category(name: $0.name, color: $0.color, budget: $0.budget.map({
                    CategoriesLoadResponse.Budget(currency: $0.currency, limit: $0.limit)
                }))
            })
        }
    }

    func saveCategory(with request: CategoriesSavingRequest) -> Future<CategoriesSavingRequest.Category> {
        categoriesSavingUseCase.saveCategory(with:
            CategoriesSaveUseCaseRequest(name: request.category.name,
                                         color: request.category.color,
                                         limit: request.category.budget?.limit,
                                         currency: request.category.budget?.currency)
        ).map {
            CategoriesSavingRequest.Category(name: $0.name, color: $0.color, budget: $0.budget.map {
                CategoriesSavingRequest.Budget(currency: $0.currency, limit: $0.limit)
            })
        }
    }
}

struct CategoriesSavingRequest {

    let category: Category

    struct Category {
        let name: String
        let color: String
        let budget: Budget?
    }

    struct Budget {
        let currency: String
        let limit: Double
    }
}

struct CategoriesLoadResponse {

    let categories: [Category]

    struct Category {
        let name: String
        let color: String
        let budget: Budget?
    }

    struct Budget {
        let currency: String
        let limit: Double
    }
}
