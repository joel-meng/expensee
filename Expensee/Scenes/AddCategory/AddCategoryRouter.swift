//
//  AddCategoryRouter.swift
//  Expensee
//
//  Created by Jun Meng on 1/5/20.
//  Copyright © 2020 Jun Meng. All rights reserved.
//

import Foundation
import UIKit

protocol AddCategoriesRouting: class {

    func routeBackAndRefresh()
}

final class AddCategoriesRouter: AddCategoriesRouting {

    private let navigationController: UINavigationController

    private let completion: () -> Void

    init(navigationController: UINavigationController, completion: @escaping () -> Void) {
        self.navigationController = navigationController
        self.completion = completion
    }

    func routeBackAndRefresh() {
        completion()
        navigationController.popViewController(animated: true)
    }
}
