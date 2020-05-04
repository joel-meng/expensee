//
//  TransactionListRouter.swift
//  Expensee
//
//  Created by Jun Meng on 2/5/20.
//  Copyright © 2020 Jun Meng. All rights reserved.
//

import UIKit

protocol TransactionListRouting: class {

    func routeToAddTransaction(completion: @escaping () -> Void)

    func routeToUpdateTransaction(completion: @escaping () -> Void)

    func routeToUpdateTransaction(with sceneModel: TransactionSceneModel, completion: @escaping () -> Void)
}

final class TransactionListRouter: TransactionListRouting {

    private var navigationController: UINavigationController

    private var factory: DependencyInjecting

    init(navigationController: UINavigationController, factory: DependencyInjecting) {
        self.factory = factory
        self.navigationController = navigationController
    }

    func routeToAddTransaction(completion: @escaping () -> Void) {
        let nextViewController = factory.createTransactionScene(from: navigationController,
                                                                sceneModel: nil,
                                                                completion: completion)
        DispatchQueue.main.async { [weak self] in
            self?.navigationController.show(nextViewController, sender: nil)
        }
    }

    func routeToUpdateTransaction(completion: @escaping () -> Void) {
        let nextViewController = factory.createTransactionScene(from: navigationController,
                                                                sceneModel: nil,
                                                                completion: completion)
        DispatchQueue.main.async { [weak self] in
            self?.navigationController.show(nextViewController, sender: nil)
        }
    }

    func routeToUpdateTransaction(with sceneModel: TransactionSceneModel, completion: @escaping () -> Void) {
        let nextViewController = factory.createTransactionScene(from: navigationController,
                                                                sceneModel: sceneModel,
                                                                completion: completion )
        DispatchQueue.main.async { [weak self] in
            self?.navigationController.show(nextViewController, sender: nil)
        }
    }
}
