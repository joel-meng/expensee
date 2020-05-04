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
        DispatchQueue.main.async { [weak self] in
            self?.completion()
            self?.navigationController.popViewController(animated: true)
        }
    }
}

struct AddCategorySceneModel {
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
