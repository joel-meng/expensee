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
}

final class AddCategoryInteractor: AddCategoryInteracting {

    private var colorsUseCase: CategoryColorUseCaseProtocol

    init(colorsUseCase: CategoryColorUseCaseProtocol) {
        self.colorsUseCase = colorsUseCase
    }

    func listColors(request: ListColorsRequest) -> ListColorsResponse {
        let response = colorsUseCase.listCategoryColors(request: ListCategoryUseCaseRequest())
        return ListColorsResponse(colors:
            response.colors.map {
                ListColorsResponse.CategoryColor(color: $0.color, uuid: $0.uuid)
            }
        )
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
