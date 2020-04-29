//
//  CategoriesUseCase.swift
//  Expensee
//
//  Created by Jun Meng on 29/4/20.
//  Copyright © 2020 Jun Meng. All rights reserved.
//

import Foundation

protocol CategoriesSaveUseCaseProtocol {

    func saveCategory(with request: CategoriesSaveUseCaseRequest)
}

final class CategoriesSaveUseCase: CategoriesSaveUseCaseProtocol {

    func saveCategory(with request: CategoriesSaveUseCaseRequest) {

    }
}

struct CategoriesSaveUseCaseRequest {

    let name: String

    let color: String
}

struct CategoryDTO {

    let name: String

    let color: String
}
