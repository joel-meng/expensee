//
//  CategoriesInteractor.swift
//  Expensee
//
//  Created by Jun Meng on 29/4/20.
//  Copyright © 2020 Jun Meng. All rights reserved.
//

import Foundation

protocol CategoriesInteracting {

    func loadCategories(request: CategoriesLoadRequest) -> Future<CategoriesLoadResponse>
    
    func loadCategory(request: CategoryLoadRequest) -> Future<CategoryLoadResponse>
}

final class CategoriesInteractor: CategoriesInteracting {
    
    private var categoriesUseCase: CategoriesLoadUseCaseProtocol

    init(categoriesUseCase: CategoriesLoadUseCaseProtocol) {
        self.categoriesUseCase = categoriesUseCase
    }

    func loadCategories(request: CategoriesLoadRequest) -> Future<CategoriesLoadResponse> {
        let future = categoriesUseCase.loadAllCategory()

        return future.map { (categories) -> CategoriesLoadResponse in
            CategoriesLoadResponse(categories: categories.map {
                CategoriesLoadResponse.Category(name: $0.name, color: $0.color, budget: $0.budget.map({
                    CategoriesLoadResponse.Budget(currency: $0.currency, limit: $0.limit)
                }), uid: $0.uid)
            })
        }
    }
    
    func loadCategory(request: CategoryLoadRequest) -> Future<CategoryLoadResponse> {
        categoriesUseCase.loadCategory(by: request.uid).map { (categoryDTO) -> CategoryLoadResponse in
            guard let category: CategoryDTO = categoryDTO else { return CategoryLoadResponse(categories: nil) }
            return CategoryLoadResponse(categories:
                CategoryLoadResponse.Category(uid: category.uid,
                                              name: category.name,
                                              color: category.color,
                                              budget: category.budget.map {
                                                CategoryLoadResponse.Budget(currency: $0.currency,
                                                                            limit: $0.limit)
                    }
                )
            )
        }
    }
}

struct CategoriesLoadRequest {}
struct CategoriesLoadResponse {

    let categories: [Category]

    struct Category {
        let name: String
        let color: String
        let budget: Budget?
        let uid: UUID
    }

    struct Budget {
        let currency: String
        let limit: Double
    }
}

struct CategoryLoadRequest {
    let uid: UUID
}
struct CategoryLoadResponse {

    let categories: Category?

    struct Category {
        let uid: UUID
        let name: String
        let color: String
        let budget: Budget?
    }

    struct Budget {
        let currency: String
        let limit: Double
    }
}
