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

        let navigationViewController = UINavigationController()
        let viewController = factory.createCategoryScene(from: navigationViewController)
        navigationViewController.viewControllers = [viewController]


        let tabBarViewController = UITabBarController()
        tabBarViewController.setViewControllers([navigationViewController], animated: false)
        navigationViewController.tabBarItem = UITabBarItem(title: "Categories",
                                                           image: "👑".image(size: .init(width: 32, height: 32),
                                                                               fontSize: 32), tag: 1)
        return tabBarViewController
    }
    
    private func createAddCategoryScene() -> UIViewController {
        let categoryRepository = CategoriesRepository(context: CoreDataStore.shared?.context)
        let colorsUseCase = CategoryColorUseCase()
        let addCategoryUseCase = AddCategoryUseCase(categoryRepositoy: categoryRepository)
        let addCategoryInteractor = AddCategoryInteractor(colorsUseCase: colorsUseCase,
                                                          saveCategoryUseCase: addCategoryUseCase)
        let addCategoryViewController = AddCategoryViewController(nibName: nil, bundle: nil)
        let presenter = AddCategoryPresenter(view: addCategoryViewController, interactor: addCategoryInteractor)
        addCategoryViewController.presenter = presenter
        
        let navigationViewController = UINavigationController(rootViewController: addCategoryViewController)
        let tabBarViewController = UITabBarController()
        tabBarViewController.setViewControllers([navigationViewController], animated: false)
        navigationViewController.tabBarItem = UITabBarItem.init(title: "Categories",
                                                                image: "👑".image(size: .init(width: 32, height: 32), fontSize: 32), tag: 1)
        return tabBarViewController
    }
    

    // MARK: - Core Data stack

    lazy var persistentContainer: NSPersistentContainer = {
        /*
         The persistent container for the application. This implementation
         creates and returns a container, having loaded the store for the
         application to it. This property is optional since there are legitimate
         error conditions that could cause the creation of the store to fail.
        */
        let container = NSPersistentContainer(name: "Expensee")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                 
                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()

    // MARK: - Core Data Saving support

    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }

}

