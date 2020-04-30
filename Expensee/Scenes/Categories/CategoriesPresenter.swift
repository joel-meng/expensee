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
}

protocol CategoriesControlling {

    func viewIsReady()

    func didTapAddCategory()
}

final class CategoriesPresenter {

    private let interactor: CategoriesCreating

    weak var view: CategoriesDisplaying?

    init(interactor: CategoriesCreating) {
        self.interactor = interactor
    }
}

extension CategoriesPresenter: CategoriesControlling {

    func viewIsReady() {

    }

    func didTapAddCategory() {
        let request = CategoriesSavingRequest(name: "\(Date())", color: "#989343")
        do {
            try interactor.saveCategory(with: request)
        } catch {
            view?.displayInsertionError(translatingError(error))
        }
    }

    private func translatingError(_ error: Error) -> String {
        "Error happend"
    }
}
