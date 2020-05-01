//
//  CategoriesViewController.swift
//  Expensee
//
//  Created by Jun Meng on 29/4/20.
//  Copyright © 2020 Jun Meng. All rights reserved.
//

import UIKit
import CoreData

class CategoriesViewController: UIViewController {

    var presenter: CategoriesControlling!

    @IBOutlet weak var tableView: UITableView!

    private lazy var dataSource: SimpleTableDataSource<CategoryCellModel, CategoryTableViewCell> = {
        let dataSource = SimpleTableDataSource<CategoryCellModel, CategoryTableViewCell>()

        dataSource.binder = { (row: CategoryCellModel, cell: CategoryTableViewCell) in
            cell.nameLabel.text = row.name
            cell.colorLabel.backgroundColor = UIColor(row.color)
        }

        dataSource.cellProvider = { tableView, indexPath in
            let cell: CategoryTableViewCell = tableView.dequeueReusableCell(for: indexPath)
            return cell
        }

        dataSource.sorter = { $0.name < $1.name }

        return dataSource
    }()

    private lazy var provider: TableViewProvider<CategoryCellModel, CategoryTableViewCell> = { [weak dataSource] in
        let provider = TableViewProvider<CategoryCellModel, CategoryTableViewCell>(tableView: tableView)
        provider.dataSource = dataSource
        provider.dataSource?.tapAction = { [weak presenter] selected in
            presenter?.didSelectCategory(id: selected.id)
        }

        return provider
     }()


    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Categories"
        tableView.registerReuableCell(CategoryTableViewCell.self)

        createAddButton()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        presenter.viewIsReady()
    }

    private func createAddButton() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add,
                                                            target: self,
                                                            action: #selector(didTapAdd))
    }

    @objc private func didTapAdd() {
        presenter.didTapAddCategory()
    }
}

extension CategoriesViewController: CategoriesPresenting {

    func displayCategories(_ categories: [CategoryCellModel]) {
        provider.updateData(categories)
    }

    func displayInsertionError(_ errorMessage: String) {
        let alertController = UIAlertController(title: "Error", message: errorMessage, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .destructive, handler: nil))
        present(alertController, animated: true, completion: nil)
    }
}
