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

    func findCategoryColors(request: FindCategoryUseCaseRequest) -> FindCategoryUseCaseResponse
}

final class CategoryColorUseCase: CategoryColorUseCaseProtocol {

    private let colors = [
        CategoryColor(color: "#ff71ce", uuid: UUID()),
        CategoryColor(color: "#01cdfe", uuid: UUID()),
        CategoryColor(color: "#05ffa1", uuid: UUID()),
        CategoryColor(color: "#b967ff", uuid: UUID()),
        CategoryColor(color: "#fffb96", uuid: UUID()),
        CategoryColor(color: "#fffeb3", uuid: UUID()),
        CategoryColor(color: "#666547", uuid: UUID()),
    ]

    func listCategoryColors(request: ListCategoryUseCaseRequest) -> ListCategoryUseCaseResponse {
        return ListCategoryUseCaseResponse(colors:
            colors.map {ListCategoryUseCaseResponse.CategoryColor(color: $0.color, uuid: $0.uuid) })
    }

    func findCategoryColors(request: FindCategoryUseCaseRequest) -> FindCategoryUseCaseResponse {
        let foundColor = colors.filter { $0.uuid == request.color }.first.map {
            FindCategoryUseCaseResponse.CategoryColor(color: $0.color, uuid: $0.uuid)
        }
        return FindCategoryUseCaseResponse(color: foundColor)
    }
}

struct CategoryColor {
    let color: String
    let uuid: UUID
}

struct ListCategoryUseCaseRequest {}
struct ListCategoryUseCaseResponse {
    let colors: [CategoryColor]

    struct CategoryColor {
        let color: String
        let uuid: UUID
    }
}

struct FindCategoryUseCaseRequest {
    let color: UUID
}

struct FindCategoryUseCaseResponse {
    let color: CategoryColor?

    struct CategoryColor {
        let color: String
        let uuid: UUID
    }
}
