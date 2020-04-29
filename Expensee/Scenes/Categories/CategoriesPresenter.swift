//
//  CategoriesPresenter.swift
//  Expensee
//
//  Created by Jun Meng on 29/4/20.
//  Copyright © 2020 Jun Meng. All rights reserved.
//

import Foundation

protocol CategoriesPresenting {

}

protocol CategoriesControlling {

    func viewIsReady()

    func didTapAddCategory()
}

final class CategoriesPresenter {
    init() {

    }
}

extension CategoriesPresenter: CategoriesPresenting {}

extension CategoriesPresenter: CategoriesControlling {

    func viewIsReady() {

    }

    func didTapAddCategory() {

    }
}
