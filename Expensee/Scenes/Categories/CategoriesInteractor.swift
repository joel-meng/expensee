//
//  CategoriesInteractor.swift
//  Expensee
//
//  Created by Jun Meng on 29/4/20.
//  Copyright © 2020 Jun Meng. All rights reserved.
//

import Foundation

protocol CategoriesCreating {

    func saveCategory(with reqeust: CategoriesSavingRequest) throws
}

final class CategoriesInteractor: CategoriesCreating {

    private var repository: CategoriesRepositoryProtocol

    init(repository: CategoriesRepositoryProtocol) {
        self.repository = repository
    }

    func saveCategory(with request: CategoriesSavingRequest) throws {
        try repository.save(CategoryDTO(name: request.name, color: request.color))
    }
}

struct CategoriesSavingRequest {

    let name: String

    let color: String
}
