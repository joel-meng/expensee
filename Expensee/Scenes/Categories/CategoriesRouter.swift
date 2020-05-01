//
//  CategoriesRouter.swift
//  Expensee
//
//  Created by Jun Meng on 1/5/20.
//  Copyright © 2020 Jun Meng. All rights reserved.
//

import Foundation
import UIKit

protocol CategoriesRouting: class {

    func routeToAddCategory(completion: @escaping () -> Void)
}

final class CategoriesRouter: CategoriesRouting {

    private var navigationController: UINavigationController

    private var factory: DependencyInjecting

    init(navigationController: UINavigationController, factory: DependencyInjecting) {
        self.factory = factory
        self.navigationController = navigationController
    }

    func routeToAddCategory(completion: @escaping () -> Void) {
        let nextViewController = factory.createAddCategoryScene(from: navigationController, completion: completion)
        navigationController.show(nextViewController, sender: nil)
    }
}
