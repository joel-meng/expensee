//
//  TransactionRouter.swift
//  Expensee
//
//  Created by Jun Meng on 2/5/20.
//  Copyright © 2020 Jun Meng. All rights reserved.
//

import UIKit

protocol TransactionRouting: class {

    func routeToCategoryList(completion: @escaping (TransactionRouterSceneModel) -> Void)
}

final class TransactionRouter: TransactionRouting {

    private var navigationController: UINavigationController

    private var factory: DependencyInjecting

    init(navigationController: UINavigationController, factory: DependencyInjecting) {
        self.factory = factory
        self.navigationController = navigationController
    }

    func routeToCategoryList(completion: @escaping (TransactionRouterSceneModel) -> Void) {
        let nextViewController = factory.createCategoryListSceneForSelection(from: navigationController) {
            completion(TransactionRouterSceneModel(category:
                TransactionRouterSceneModel.Category(uid: $0.category.uid,
                                                     name: $0.category.name,
                                                     color: $0.category.color,
                                                     budget: $0.category.budget.map {
            TransactionRouterSceneModel.Budget(currency: $0.currency, limit: $0.limit)})))
        }
        navigationController.show(nextViewController, sender: nil)
    }
}

struct TransactionRouterSceneModel {

    let category: Category?

    struct Category {
        let uid: UUID
        let name: String
        let color: String
        let budget: Budget?
    }

    struct Budget {
        let currency: String
        let limit: Double
    }
}