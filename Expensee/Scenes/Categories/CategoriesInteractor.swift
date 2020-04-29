//
//  CategoriesInteractor.swift
//  Expensee
//
//  Created by Jun Meng on 29/4/20.
//  Copyright © 2020 Jun Meng. All rights reserved.
//

import Foundation

protocol CategoriesBusinessLogic {

    func saveCategory(with reqeust: CategoriesBusinessLogicRequest)
}

final class CategoriesInteractor: CategoriesBusinessLogic {

    func saveCategory(with reqeust: CategoriesBusinessLogicRequest) {

    }
}

struct CategoriesBusinessLogicRequest {

    let name: String

    let color: String
}
