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

    func updateCategory(request: UpdateCategoryRequest) -> Future<UpdateCategoryResponse>
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
                ListColorsResponse.CategoryColor(color: $0.color)
            }
        )
    }

    func saveCategory(request: SaveCategoryRequest) -> Future<SaveCategoryResponse> {
        var budget: BudgetDTO? = nil
        if let monthlyBudget = request.category.monthlyLimit {
            budget = BudgetDTO(currency: monthlyBudget.limitCurrency, limit: monthlyBudget.limitAmount)
        }

        let category = CategoryDTO(name: request.category.name, color: request.category.color, budget: budget, uid: UUID())
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

    func updateCategory(request: UpdateCategoryRequest) -> Future<UpdateCategoryResponse> {
        let categoryDTO = CategoryDTO(name: request.category.name,
                                      color: request.category.color,
                                      budget: request.category.monthlyLimit.map {
                                        BudgetDTO(currency: $0.limitCurrency, limit: $0.limitAmount)
                                      },
                                      uid: request.category.id)
        let updateFuture = saveCategoryUseCase.updateCategory(request: UpdateCategoryUseCaseRequest(category: categoryDTO))
        return updateFuture.map {
            UpdateCategoryResponse(category:
                UpdateCategoryResponse.Category(id: $0.category.uid,
                                                name: $0.category.name,
                                                color: $0.category.color,
                                                monthlyLimit: $0.category.budget.map {
                                                    UpdateCategoryResponse.MontlyLimit(limitAmount: $0.limit,
                                                                                       limitCurrency: $0.currency)
                                                }))
        }
    }
}

struct ListColorsRequest {}

struct ListColorsResponse {
    let colors: [CategoryColor]

    struct CategoryColor {
        let color: String
    }
}

struct SaveCategoryRequest {

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

struct UpdateCategoryRequest {

    let category: Category

    struct Category {

        let id: UUID

        let name: String

        let color: String

        let monthlyLimit: MontlyLimit?
    }

    struct MontlyLimit {

        let limitAmount: Double

        let limitCurrency: String
    }
}

struct UpdateCategoryResponse {
    let category: Category

    struct Category {

        let id: UUID

        let name: String

        let color: String

        let monthlyLimit: MontlyLimit?
    }

    struct MontlyLimit {

        let limitAmount: Double

        let limitCurrency: String
    }
}
