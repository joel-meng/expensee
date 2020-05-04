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
    
    func loadAllCategoryWithTransactions() -> Future<[CategoryDTO: [TransactionDTO]]>

    func loadCategory(by id: UUID) -> Future<CategoryDTO?>
}

final class CategoriesLoadUseCase: CategoriesLoadUseCaseProtocol {

    var categoriesRepository: CategoriesRepositoryProtocol

    init(categoriesRepository: CategoriesRepositoryProtocol) {
        self.categoriesRepository = categoriesRepository
    }

    func loadAllCategory() -> Future<[CategoryDTO]> {
        return categoriesRepository.fetchAll()
    }
    
    func loadCategory(by id: UUID) -> Future<CategoryDTO?> {
        return categoriesRepository.fetch(by: id)
    }

    func loadAllCategoryWithTransactions() -> Future<[CategoryDTO : [TransactionDTO]]> {
        return categoriesRepository.fetchAllWithTransactions()
    }
}
