//
//  DependencyInjection.swift
//  Expensee
//
//  Created by Jun Meng on 1/5/20.
//  Copyright © 2020 Jun Meng. All rights reserved.
//

import UIKit

protocol DependencyInjecting {

    func createCategoryListScene(from navigation: UINavigationController) -> UIViewController

    func createCategoryListSceneForSelection(from navigation: UINavigationController,
                                             completion: @escaping (SelectCategorySceneModel) -> Void) -> UIViewController

    func createAddCategoryScene(from navigation: UINavigationController,
                                sceneModel: AddCategorySceneModel?,
                                completion: @escaping () -> Void) -> UIViewController

    func createTransactionListScene(from navigation: UINavigationController) -> UIViewController

    func createTransactionScene(from navigation: UINavigationController,
                                sceneModel: TransactionSceneModel?,
                                completion: @escaping () -> Void) -> UIViewController
}

final class DependencyInjection: DependencyInjecting {

    // MARK: - Category List Scene

    func createCategoryListScene(from navigation: UINavigationController) -> UIViewController {
        let router = CategoriesRouter(navigationController: navigation, factory: self)
        let categoryRepository = CategoriesRepository(context: CoreDataStore.shared?.context)
        let categoryUseCase = CategoriesLoadUseCase(categoriesRepository: categoryRepository)
        let interactor = CategoriesInteractor(categoriesUseCase: categoryUseCase)
        let presenter = CategoriesPresenter(interactor: interactor, router: router, flavor: .display)

        let categoriesViewController = CategoriesViewController(nibName: nil, bundle: nil)
        presenter.view = categoriesViewController
        categoriesViewController.presenter = presenter

        return categoriesViewController
    }

    func createCategoryListSceneForSelection(from navigation: UINavigationController,
                                             completion: @escaping (SelectCategorySceneModel) -> Void) -> UIViewController {
        let router = CategoriesRouter(navigationController: navigation, completion: completion, factory: self)
        let categoryRepository = CategoriesRepository(context: CoreDataStore.shared?.context)
        let categoryUseCase = CategoriesLoadUseCase(categoriesRepository: categoryRepository)
        let interactor = CategoriesInteractor(categoriesUseCase: categoryUseCase)
        let presenter = CategoriesPresenter(interactor: interactor, router: router, flavor: .selection)

        let categoriesViewController = CategoriesViewController(nibName: nil, bundle: nil)
        presenter.view = categoriesViewController
        categoriesViewController.presenter = presenter

        return categoriesViewController
    }

    // MARK: - Category Add Scene

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

    func createTransactionListScene(from navigation: UINavigationController) -> UIViewController {
        let router = TransactionListRouter(navigationController: navigation, factory: self)
        let categoryRepository = CategoriesRepository(context: CoreDataStore.shared?.context)
        let transactionRepository = TransactionRepository(context: CoreDataStore.shared?.context)
        let useCase = CategoriesLoadUseCase(categoriesRepository: categoryRepository)
        let currencyConvertingUseCase = CurrencyConvertingUseCase(currencyService: CurrencyLayerService())
        let transactionBudgetingUsecase = TransactionCategoryBudgetCase(currencyUseCase: currencyConvertingUseCase)
        let loadTransactionUseCase = TransactionLoadUseCase(transactionRepository: transactionRepository)
        let interactor = TransactionListInteractor(categoryLoadUseCase: useCase,
                                                   transactionBudgetingUsecase: transactionBudgetingUsecase,
                                                   transactionLoadUseCase: loadTransactionUseCase)
        let viewController = TransactionListViewController()
        let presenter = TransactionListPresenter(view: viewController, interactor: interactor, router: router)
        viewController.presenter = presenter

        return viewController
    }

    func createTransactionScene(from navigation: UINavigationController,
                                sceneModel: TransactionSceneModel?,
                                completion: @escaping () -> Void) -> UIViewController {

        let transaction = sceneModel.map {
            TransactionPresenter.Transaction(amount: $0.transaction.originalAmount,
                                             date: $0.transaction.date,
                                             currency: $0.transaction.originalCurrency,
                                             uid: $0.transaction.id)
        }

        let category = sceneModel.map {
            TransactionPresenter.Category(id: $0.transaction.category.id,
                                          name: $0.transaction.category.name,
                                          color: $0.transaction.category.color)
        }

        let router = TransactionRouter(navigationController: navigation, factory: self, routeBackToTransactionListCompletion: completion)
        let currencyConvertingUseCase = CurrencyConvertingUseCase(currencyService: CurrencyLayerService())
        let saveTransactionUseCase = SaveTransactionUseCase(transactionRepository:
            TransactionRepository(context: CoreDataStore.shared?.context))
        let interactor = TransactionInteractor(currencyConversionUseCase: currencyConvertingUseCase,
                                               saveTransactionUseCase: saveTransactionUseCase)
        let viewController = TransactionViewController()
        let presenter = TransactionPresenter(view: viewController,
                                             interactor: interactor,
                                             router: router,
                                             transaction: transaction,
                                             category: category)
        viewController.presenter = presenter

        return viewController
    }
}
