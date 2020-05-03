//
//  CategoriesPresenter.swift
//  Expensee
//
//  Created by Jun Meng on 29/4/20.
//  Copyright © 2020 Jun Meng. All rights reserved.
//

import Foundation

protocol CategoriesPresenting: class {

    func displayInsertionError(_ errorMessage: String)

    func displayCategories(_ categories: [CategoryCellModel])
}

protocol CategoriesControlling: class {

    func viewIsReady()

    func didTapAddCategory()
    
    func didSelectCategory(id: UUID)
}

final class CategoriesPresenter {

    private let interactor: CategoriesInteracting

    private let router: CategoriesRouting

    weak var view: CategoriesPresenting?

    private let flavor: SceneFlavor

    init(interactor: CategoriesInteracting, router: CategoriesRouting, flavor: SceneFlavor) {
        self.interactor = interactor
        self.router = router
        self.flavor = flavor
    }

    enum SceneFlavor {
        case display
        case selection
    }
}

extension CategoriesPresenter: CategoriesControlling {
    
    func viewIsReady() {
        loadCategories()
    }

    private func loadCategories() {
        let future = interactor.loadCategories(request: CategoriesLoadRequest())
        future.on(success: { [weak view] (loadResonse) in
            view?.displayCategories(loadResonse.categories.map {
                CategoryCellModel(name: $0.name, color: $0.color, limit: $0.budget?.limit, id: $0.uid)
            })
        }, failure: {  [weak self] error in
            guard let self = self else { return }
            self.view?.displayInsertionError(self.translatingError(error))
        })
    }

    func didTapAddCategory() {
//        let context = CoreDataStore.shared?.context
//        try! ExpenseCategory.delete(from: context!)
        router.routeToAddCategory { [weak self] in
            self?.loadCategories()
        }
    }

    func didSelectCategory(id: UUID) {
        interactor.loadCategory(request: CategoryLoadRequest(uid: id)).on(success: { [weak self, flavor] (response) in
            guard let category = response.categories else {
                // TODO: - Error throw
                return
            }
            switch flavor {
            case .display: self?.routeToAddCategory(with: category)
            case .selection: self?.routeBack(with: category)
            }
        }, failure: { error in
            
        })
    }
    
    private func routeBack(with category: CategoryLoadResponse.Category) {
        let sceneModel = SelectCategorySceneModel(category:
            SelectCategorySceneModel.Category(uid: category.uid,
                                              name: category.name,
                                              color: category.color,
                                              budget: category.budget.map({
                                                SelectCategorySceneModel.Budget(currency: $0.currency, limit: $0.limit)})))
        router.routeBack(with: sceneModel)
    }

    private func routeToAddCategory(with category: CategoryLoadResponse.Category) {
        let sceneModel = AddCategorySceneModel(category:
            AddCategorySceneModel
                .Category(uid: category.uid,
                          name: category.name,
                          color: category.color,
                          budget: category.budget.map {
                               AddCategorySceneModel.Budget(currency: $0.currency, limit: $0.limit)}))

        router.routeToUpdateCategory(with:sceneModel) {
            self.loadCategories()
        }
    }

    private func translatingError(_ error: Error) -> String {
        "Error happend"
    }
}
