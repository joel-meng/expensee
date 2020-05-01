//
//  CategoriesPresenter.swift
//  Expensee
//
//  Created by Jun Meng on 29/4/20.
//  Copyright © 2020 Jun Meng. All rights reserved.
//

import Foundation

protocol CategoriesDisplaying: class {

    func displayInsertionError(_ errorMessage: String)

    func displayCategories(_ categories: [CategoryCellModel])
}

protocol CategoriesControlling {

    func viewIsReady()

    func didTapAddCategory()
}

final class CategoriesPresenter {

    private let interactor: CategoriesInteracting

    private let router: CategoriesRouting

    weak var view: CategoriesDisplaying?

    init(interactor: CategoriesInteracting, router: CategoriesRouting) {
        self.interactor = interactor
        self.router = router
    }
}

extension CategoriesPresenter: CategoriesControlling {

    func viewIsReady() {
        loadCategories()
    }

    private func loadCategories() {
        let future = interactor.loadCategories()
        future.on(success: { [weak view] (loadResonse) in
            view?.displayCategories(loadResonse.categories.map {
                CategoryCellModel(name: $0.name, color: $0.color, limit: $0.budget?.limit)
            })
        }, failure: {  [weak self] error in
            guard let self = self else { return }
            self.view?.displayInsertionError(self.translatingError(error))
        })
    }

    func didTapAddCategory() {
        let request = CategoriesSavingRequest(category: CategoriesSavingRequest.Category(name: "\(Date())",
            color: "#989343",
            budget: CategoriesSavingRequest.Budget(currency: "USD", limit: 222)))

        interactor.saveCategory(with: request).on(success: { [weak self] _ in
            self?.loadCategories()
        }, failure: { [weak self] error in
            guard let self = self else { return }
            self.view?.displayInsertionError(self.translatingError(error))
        })
    }

    private func translatingError(_ error: Error) -> String {
        "Error happend"
    }
}
