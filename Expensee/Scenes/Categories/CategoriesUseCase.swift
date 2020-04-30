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

    init(categoriesRepository: CategoriesRepositoryProtocol) {
        self.categoriesRepository = categoriesRepository
    }

    func saveCategory(with request: CategoriesSaveUseCaseRequest) -> Future<CategoryDTO> {
        return categoriesRepository.save(CategoryDTO(name: request.name, color: request.color))
    }

    func loadAllCategory() -> Future<[CategoryDTO]> {
        return categoriesRepository.fetchAll()
    }
}

struct CategoriesSaveUseCaseRequest {

    let name: String

    let color: String
}
