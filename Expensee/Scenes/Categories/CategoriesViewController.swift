//
//  CategoriesViewController.swift
//  Expensee
//
//  Created by Jun Meng on 29/4/20.
//  Copyright © 2020 Jun Meng. All rights reserved.
//

import UIKit

class CategoriesViewController: UIViewController {

    var controller: CategoriesControlling = CategoriesPresenter()

    @IBOutlet weak var tableView: UITableView!

    private lazy var dataSource: CategoryDataSource = CategoryDataSource()

    private lazy var provider: TableViewProvider<CategoryCellModel, CategoryTableViewCell> = { [weak dataSource] in
        let provider = TableViewProvider<CategoryCellModel, CategoryTableViewCell>(tableView: tableView)
        provider.dataSource = dataSource
        provider.dataSource?.tapAction = { selected in }

        return provider
     }()


    override func viewDidLoad() {
        super.viewDidLoad()

        provider.updateData(tempDataSource)
        tableView.registerReuableCell(CategoryTableViewCell.self)
    }

    private var tempDataSource: [CategoryCellModel] = [
        CategoryCellModel(name: "ABC", color: "#123123"),
        CategoryCellModel(name: "BCD", color: "#123123"),
        CategoryCellModel(name: "DEF", color: "#123123"),
        CategoryCellModel(name: "GDF", color: "#123123"),
        CategoryCellModel(name: "ERD", color: "#123123"),
    ]
}

final class CategoryDataSource: SimpleTableDataSource<CategoryCellModel, CategoryTableViewCell> {

    override var cellProvider: ((UITableView, IndexPath) -> CategoryTableViewCell) {
        set {}
        get { dataSource.cellProvider }
    }
    
    override var binder: ((CategoryCellModel, CategoryTableViewCell) -> Void)? {
        set {}
        get {
            return { (model: CategoryCellModel, cell: UITableViewCell) in
                self.dataSource.binder?(model, cell as! CategoryTableViewCell)
            }
        }
    }

    override var sorter: (CategoryCellModel, CategoryCellModel) -> Bool {
        set {}
        get { dataSource.sorter }
    }

    private let dataSource: SimpleTableDataSource<CategoryCellModel, CategoryTableViewCell> = {
        let dataSource = SimpleTableDataSource<CategoryCellModel, CategoryTableViewCell>()

        dataSource.binder = { (row: CategoryCellModel, cell: CategoryTableViewCell) in
            cell.nameLabel.text = row.name
            cell.colorLabel.text = row.color
        }

        dataSource.cellProvider = { tableView, indexPath in
            let cell: CategoryTableViewCell = tableView.dequeueReusableCell(for: indexPath)
            return cell
        }

        dataSource.sorter = { $0.name < $1.name }

        return dataSource
    }()
}
