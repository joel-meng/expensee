//
//  AddCategoryInteractor.swift
//  Expensee
//
//  Created by Jun Meng on 1/5/20.
//  Copyright © 2020 Jun Meng. All rights reserved.
//

import Foundation

protocol AddCategoryInteracting {

    func listColors(request: ListColorsRequest) -> ListColorsResponse

    func saveCategory(request: SaveCategoryRequest) -> Future<SaveCategoryResponse>
}

final class AddCategoryInteractor: AddCategoryInteracting {

    private var colorsUseCase: CategoryColorUseCaseProtocol

    private var saveCategoryUseCase: AddCategoryUseCaseProtocol

    init(colorsUseCase: CategoryColorUseCaseProtocol,
         saveCategoryUseCase: AddCategoryUseCaseProtocol) {
        self.colorsUseCase = colorsUseCase
        self.saveCategoryUseCase = saveCategoryUseCase
    }

    func listColors(request: ListColorsRequest) -> ListColorsResponse {
        let response = colorsUseCase.listCategoryColors(request: ListCategoryUseCaseRequest())
        return ListColorsResponse(colors:
            response.colors.map {
                ListColorsResponse.CategoryColor(color: $0.color, uuid: $0.uuid)
            }
        )
    }

    func saveCategory(request: SaveCategoryRequest) -> Future<SaveCategoryResponse> {
        let future = Future<SaveCategoryResponse>()

        guard let colorUUID = request.category.color,
            let foundColor = colorsUseCase.findCategoryColors(request:
                FindCategoryUseCaseRequest(color: colorUUID)).color else {
            future.reject(with: NSError())
            return future
        }

        var budget: BudgetDTO? = nil
        if let monthlyBudget = request.category.monthlyLimit {
            budget = BudgetDTO(currency: monthlyBudget.limitCurrency, limit: monthlyBudget.limitAmount)
        }

        let category = CategoryDTO(name: request.category.name, color: foundColor.color, budget: budget)
        let request = AddCategoryUseCaseRequest(category: category)
        let savedCategoryFuture = saveCategoryUseCase.addCategory(request: request)

        return savedCategoryFuture.map {
            SaveCategoryResponse(category:
                SaveCategoryResponse.Category(name: $0.category.name,
                                              color: $0.category.color,
                                              monthlyLimit: $0.category.budget.map {
                                                SaveCategoryResponse.MontlyLimit(limitAmount: $0.limit,
                                                                                 limitCurrency: $0.currency)
                                                }
                )
            )
        }
    }
}

struct ListColorsRequest {}

struct ListColorsResponse {
    let colors: [CategoryColor]

    struct CategoryColor {
        let color: String
        let uuid: UUID
    }
}

struct SaveCategoryRequest {

    let category: Category

    struct Category {

        let name: String

        let color: UUID?

        let monthlyLimit: MontlyLimit?
    }

    struct MontlyLimit {

        let limitAmount: Double

        let limitCurrency: String
    }
}

struct SaveCategoryResponse {
    let category: Category

    struct Category {

        let name: String

        let color: String

        let monthlyLimit: MontlyLimit?
    }

    struct MontlyLimit {

        let limitAmount: Double

        let limitCurrency: String
    }
}
