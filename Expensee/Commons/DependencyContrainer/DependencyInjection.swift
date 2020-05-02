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
                                sceneModel: AddCategorySceneModel?,
                                completion: @escaping () -> Void) -> UIViewController

    func createTransactionScene(from navigation: UINavigationController) -> UIViewController
}

final class DependencyInjection: DependencyInjecting {

    func createCategoryScene(from navigation: UINavigationController) -> UIViewController {
        let router = CategoriesRouter(navigationController: navigation, factory: self)
        let categoryRepository = CategoriesRepository(context: CoreDataStore.shared?.context)
        let budgetRepository = BudgetRepository(context: CoreDataStore.shared?.context)
        let categoryUseCase = CategoriesLoadUseCase(categoriesRepository: categoryRepository,
                                                    budgetRepository: budgetRepository)
        let interactor = CategoriesInteractor(categoriesUseCase: categoryUseCase)
        let presenter = CategoriesPresenter(interactor: interactor, router: router)

        let categoriesViewController = CategoriesViewController(nibName: nil, bundle: nil)
        presenter.view = categoriesViewController
        categoriesViewController.presenter = presenter

        return categoriesViewController
    }

    func createAddCategoryScene(from navigation: UINavigationController,
                                sceneModel: AddCategorySceneModel? = nil,
                                completion: @escaping () -> Void) -> UIViewController {
        let category = sceneModel.map {
            AddCategoryPresenter.Category(id: $0.category?.uid, name: $0.category?.name, color: $0.category?.color)
        }
        let monthlyLimit = sceneModel.map {
            AddCategoryPresenter.MonthlyLimit(limit: $0.category?.budget?.limit, currency: $0.category?.budget?.currency)
        }

        let router = AddCategoriesRouter(navigationController: navigation, completion: completion)
        let categoryRepository = CategoriesRepository(context: CoreDataStore.shared?.context)

        let colorsUseCase = CategoryColorUseCase()
        let addCategoryUseCase = AddCategoryUseCase(categoryRepositoy: categoryRepository)

        let addCategoryInteractor = AddCategoryInteractor(colorsUseCase: colorsUseCase,
                                                          saveCategoryUseCase: addCategoryUseCase)

        let addCategoryViewController = AddCategoryViewController(nibName: nil, bundle: nil)
        let presenter = AddCategoryPresenter(view: addCategoryViewController,
                                             interactor: addCategoryInteractor,
                                             router: router, category: category,
                                             monthlyLimit: monthlyLimit)
        addCategoryViewController.presenter = presenter

        return addCategoryViewController
    }

    func createTransactionScene(from navigation: UINavigationController) -> UIViewController {
        let viewController = TransactionsViewController()
        let presenter = TransactionPresenter(view: viewController)
        viewController.presenter = presenter

        return viewController
    }
}
