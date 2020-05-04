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

    func updateCategory(request: UpdateCategoryUseCaseRequest) -> Future<UpdateCategoryUseCaseResponse>
}

final class AddCategoryUseCase: AddCategoryUseCaseProtocol {

    private let categoryRepositoy: CategoriesRepositoryProtocol

    init(categoryRepositoy: CategoriesRepositoryProtocol) {
        self.categoryRepositoy = categoryRepositoy
    }

    func addCategory(request: AddCategoryUseCaseRequest) -> Future<AddCategoryUseCaseResponse> {
        return categoryRepositoy.save(request.category).map (AddCategoryUseCaseResponse.init)
    }

    func updateCategory(request: UpdateCategoryUseCaseRequest) -> Future<UpdateCategoryUseCaseResponse> {
        return categoryRepositoy.update(by: request.category).map {
            UpdateCategoryUseCaseResponse(category: $0)
        }
    }
}

struct AddCategoryUseCaseRequest {
    
    let category: CategoryDTO
}

struct AddCategoryUseCaseResponse {

    let category: CategoryDTO
}

struct UpdateCategoryUseCaseRequest {

    let category: CategoryDTO
}

struct UpdateCategoryUseCaseResponse {

    let category: CategoryDTO
}
