//
//  AddCategoryUseCase.swift
//  Expensee
//
//  Created by Jun Meng on 1/5/20.
//  Copyright © 2020 Jun Meng. All rights reserved.
//

import Foundation

protocol CategoryColorUseCaseProtocol {

    func listCategoryColors(request: ListCategoryUseCaseRequest) -> ListCategoryUseCaseResponse
}

final class CategoryColorUseCase: CategoryColorUseCaseProtocol {

    private let colors = [
        ListCategoryUseCaseResponse.CategoryColor(color: "#ff71ce", uuid: UUID()),
        ListCategoryUseCaseResponse.CategoryColor(color: "#01cdfe", uuid: UUID()),
        ListCategoryUseCaseResponse.CategoryColor(color: "#05ffa1", uuid: UUID()),
        ListCategoryUseCaseResponse.CategoryColor(color: "#b967ff", uuid: UUID()),
        ListCategoryUseCaseResponse.CategoryColor(color: "#fffb96", uuid: UUID()),
        ListCategoryUseCaseResponse.CategoryColor(color: "#fffeb3", uuid: UUID()),
        ListCategoryUseCaseResponse.CategoryColor(color: "#666547", uuid: UUID()),
    ]

    func listCategoryColors(request: ListCategoryUseCaseRequest) -> ListCategoryUseCaseResponse {
        return ListCategoryUseCaseResponse(colors: colors)
    }
}

struct ListCategoryUseCaseRequest {}
struct ListCategoryUseCaseResponse {
    let colors: [CategoryColor]

    struct CategoryColor {
        let color: String
        let uuid: UUID
    }
}
