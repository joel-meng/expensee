//
//  LaunchViewController.swift
//  SpaceXSpace
//
//  Created by Joel Meng on 12/4/19.
//  Copyright © 2019 Joel Meng. All rights reserved.
//


import UIKit

class LaunchViewController: UIViewController {

    var presenter: LaunchPreseting!

//    var future: Future<[LaunchCellModel]>?

//    private lazy var provider: TableViewProvider<LaunchCellModel> = {
//        let provider = TableViewProvider<LaunchCellModel>(tableView: self.tableView)
//        provider.dataSource = launchDataSource
//        provider.dataSource?.tapAction = { selected in
//            self.presenter.didSelect(selected).onSuccess { model in
//                self.navigateToDetails(from: model)
//            }
//        }
//
//        return provider
//    }()

    @IBOutlet private var tableView: UITableView!


    override func viewDidLoad() {
        super.viewDidLoad()
        view.makeStateful()

//        future = presenter.didLoadView()
//        view.showState(.loading)
//        future?.onSuccess { [unowned self] launchCellModels in
//            self.provider.updateData(launchCellModels)
//            DispatchQueue.main.async {
//                self.view.showState(.displaying(.data))
//            }
//        }
//        let filterButton = UIBarButtonItem(title: "🏁", style: .plain, target: self,
//                                           action: #selector(didToggleBarButton(sender:)))
//        navigationItem.rightBarButtonItem = filterButton
//
//        self.title = "SpaceX 🚀"
    }

    @objc
    func didToggleBarButton(sender: UIBarButtonItem) {
//        let filter = SuccessFilter(rawValue: sender.title!)!
//        provider.updateDataSourceFilter(filter.filter)
//
//        let otherSide = SuccessFilter.allCases.filter { $0 != filter }
//        sender.title = otherSide.first?.rawValue
    }

//    func navigateToDetails(from launch: LaunchSceneModel) {
//        let interactor = LaunchDetailsInteractor()
//        let presenter = LaunchDetailPresenter(interactor: interactor, sceneModel: launch)
//        let launchDetailsViewController = LaunchDetailsViewController(nibName: "LaunchDetailsViewController",
//                                                                      bundle: nil)
//        launchDetailsViewController.presenter = presenter
//        navigationController?.pushViewController(launchDetailsViewController, animated: true)
//    }
}
