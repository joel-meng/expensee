//
//  AppDelegate.swift
//  Expensee
//
//  Created by Jun Meng on 29/4/20.
//  Copyright © 2020 Jun Meng. All rights reserved.
//

import UIKit
import CoreData

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {



        CoreDataStore.initialize() { [weak self] in
            self?.window = self?.createWindow()
            self?.window?.rootViewController = self?.createHomeViewController()
//            self?.window?.rootViewController = self?.createAddCategoryScene()
            self?.window?.makeKeyAndVisible()
        }
        return true
    }
    
    private func createWindow() -> UIWindow {
        let screenBounds = UIScreen.main.bounds
        let window = UIWindow(frame: screenBounds)
        return window
    }

    private func createHomeViewController() -> UIViewController {
        let factory = DependencyInjection()

        let categoryNavigationController = UINavigationController()
        let categoryViewController = factory.createCategoryScene(from: categoryNavigationController)
        categoryNavigationController.viewControllers = [categoryViewController]
        categoryNavigationController.tabBarItem = UITabBarItem(title: "Categories",
                                                               image: "👑".image(size: .init(width: 32, height: 32),
                                                                                 fontSize: 32),
                                                               tag: 1)

        let transactionNavigationController = UINavigationController()
        let transactionViewController = factory.createTransactionListScene(from: transactionNavigationController)
        transactionNavigationController.viewControllers = [transactionViewController]
        transactionNavigationController.tabBarItem = UITabBarItem(title: "Transactions",
                                                                  image: "💸".image(size: .init(width: 32, height: 32),
                                                                                    fontSize: 32),
                                                                  tag: 0)

        return createGlobalViewController(with: [transactionNavigationController, categoryNavigationController])
    }

    private func createGlobalViewController(with controllers: [UIViewController]) -> UITabBarController {
        let tabBarViewController = UITabBarController()
        tabBarViewController.setViewControllers(controllers, animated: false)
        return tabBarViewController
    }
}
