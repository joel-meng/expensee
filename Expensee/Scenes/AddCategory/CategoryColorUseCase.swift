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
        CategoryColor(color: "#ff71ce"),
        CategoryColor(color: "#01cdfe"),
        CategoryColor(color: "#05ffa1"),
        CategoryColor(color: "#b967ff"),
        CategoryColor(color: "#fffb96"),
        CategoryColor(color: "#fffeb3"),
        CategoryColor(color: "#666547"),
    ]

    func listCategoryColors(request: ListCategoryUseCaseRequest) -> ListCategoryUseCaseResponse {
        return ListCategoryUseCaseResponse(colors:
            colors.map {ListCategoryUseCaseResponse.CategoryColor(color: $0.color) })
    }

    func findCategoryColors(request: FindCategoryUseCaseRequest) -> FindCategoryUseCaseResponse {
        let foundColor = colors.filter { $0.color == request.color }.first.map {
            FindCategoryUseCaseResponse.CategoryColor(color: $0.color)
        }
        return FindCategoryUseCaseResponse(color: foundColor)
    }
}

struct CategoryColor {
    let color: String
}

struct ListCategoryUseCaseRequest {}
struct ListCategoryUseCaseResponse {
    let colors: [CategoryColor]

    struct CategoryColor {
        let color: String
    }
}

struct FindCategoryUseCaseRequest {
    let color: String
}

struct FindCategoryUseCaseResponse {
    let color: CategoryColor?

    struct CategoryColor {
        let color: String
    }
}
