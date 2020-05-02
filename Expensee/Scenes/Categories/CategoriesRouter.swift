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

    func routeToUpdateCategory(with sceneModel: AddCategorySceneModel, completion: @escaping () -> Void)

    func routeBack(with sceneModel:SelectCategorySceneModel)
}

final class CategoriesRouter: CategoriesRouting {

    private let navigationController: UINavigationController

    private let factory: DependencyInjecting

    private let completion: ((SelectCategorySceneModel) -> Void)?

    init(navigationController: UINavigationController,
         completion: ((SelectCategorySceneModel) -> Void)? = nil,
         factory: DependencyInjecting) {
        self.factory = factory
        self.navigationController = navigationController
        self.completion = completion
    }

    func routeToAddCategory(completion: @escaping () -> Void) {
        let nextViewController = factory.createAddCategoryScene(from: navigationController, sceneModel: nil, completion: completion)
        navigationController.show(nextViewController, sender: nil)
    }

    func routeToUpdateCategory(with sceneModel: AddCategorySceneModel, completion: @escaping () -> Void) {
        let nextViewController = factory.createAddCategoryScene(from: navigationController, sceneModel: sceneModel, completion: completion)
        navigationController.show(nextViewController, sender: nil)
    }

    func routeBack(with sceneModel: SelectCategorySceneModel) {
        completion?(sceneModel)
        navigationController.popViewController(animated: true)
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

struct SelectCategorySceneModel {

    let category: Category

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
