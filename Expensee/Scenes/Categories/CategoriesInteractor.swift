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
                CategoriesLoadResponse.Category(name: $0.name, color: $0.color)
            })
        }
    }

    func saveCategory(with request: CategoriesSavingRequest) -> Future<CategoriesSavingRequest.Category> {
        categoriesSavingUseCase.saveCategory(with:
            CategoriesSaveUseCaseRequest(name: request.category.name, color: request.category.color)
        ).map {
            CategoriesSavingRequest.Category(name: $0.name, color: $0.color)
        }
    }
}

struct CategoriesSavingRequest {

    let category: Category

    struct Category {
        let name: String
        let color: String
    }
}

struct CategoriesLoadResponse {

    let categories: [Category]

    struct Category {
        let name: String
        let color: String
    }
}
