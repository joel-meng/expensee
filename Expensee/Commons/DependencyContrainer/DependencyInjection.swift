//
//  DependencyInjection.swift
//  Expensee
//
//  Created by Jun Meng on 1/5/20.
//  Copyright © 2020 Jun Meng. All rights reserved.
//

import UIKit

protocol DependencyInjecting {

    func createCategoryScene(from navigation: UINavigationController) -> UIViewController

    func createAddCategoryScene(from navigation: UINavigationController,
                                completion: @escaping () -> Void) -> UIViewController
}

final class DependencyInjection: DependencyInjecting {

    func createCategoryScene(from navigation: UINavigationController) -> UIViewController {
        let router = CategoriesRouter(navigationController: navigation, factory: self)
        let categoryRepository = CategoriesRepository(context: CoreDataStore.shared?.context)
        let budgetRepository = BudgetRepository(context: CoreDataStore.shared?.context)
        let categoryUseCase = CategoriesSaveUseCase(categoriesRepository: categoryRepository,
                                                    budgetRepository: budgetRepository)
        let interactor = CategoriesInteractor(categoriesSavingUseCase: categoryUseCase)
        let presenter = CategoriesPresenter(interactor: interactor, router: router)

        let categoriesViewController = CategoriesViewController(nibName: nil, bundle: nil)
        presenter.view = categoriesViewController
        categoriesViewController.presenter = presenter

        return categoriesViewController
    }

    func createAddCategoryScene(from navigation: UINavigationController,
                                completion: @escaping () -> Void) -> UIViewController {
        let router = AddCategoriesRouter(navigationController: navigation, completion: completion)
        let categoryRepository = CategoriesRepository(context: CoreDataStore.shared?.context)

        let colorsUseCase = CategoryColorUseCase()
        let addCategoryUseCase = AddCategoryUseCase(categoryRepositoy: categoryRepository)

        let addCategoryInteractor = AddCategoryInteractor(colorsUseCase: colorsUseCase,
                                                          saveCategoryUseCase: addCategoryUseCase)

        let addCategoryViewController = AddCategoryViewController(nibName: nil, bundle: nil)
        let presenter = AddCategoryPresenter(view: addCategoryViewController,
                                             interactor: addCategoryInteractor,
                                             router: router)
        addCategoryViewController.presenter = presenter

        return addCategoryViewController
    }
}
