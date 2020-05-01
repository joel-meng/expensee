//
//  AddCategoryUseCase.swift
//  Expensee
//
//  Created by Jun Meng on 1/5/20.
//  Copyright © 2020 Jun Meng. All rights reserved.
//

import Foundation

protocol AddCategoryUseCaseProtocol {

    func addCategory(request: AddCategoryUseCaseRequest) -> Future<AddCategoryUseCaseResponse>
}

final class AddCategoryUseCase: AddCategoryUseCaseProtocol {

    private let categoryRepositoy: CategoriesRepository

    init(categoryRepositoy: CategoriesRepository) {
        self.categoryRepositoy = categoryRepositoy
    }

    func addCategory(request: AddCategoryUseCaseRequest) -> Future<AddCategoryUseCaseResponse> {
        return categoryRepositoy.save(request.category).map (AddCategoryUseCaseResponse.init)
    }
}

struct AddCategoryUseCaseRequest {

    let category: CategoryDTO
}

struct AddCategoryUseCaseResponse {

    let category: CategoryDTO
}
