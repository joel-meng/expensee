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

    private lazy var provider: TableViewProvider<CategoryCellModel> = { [weak dataSource] in
        let provider = TableViewProvider<CategoryCellModel>(tableView: tableView)
        provider.dataSource = dataSource
        provider.dataSource?.tapAction = { selected in
//             self.controller.didSelect(selected).onSuccess { model in
//                 self.navigateToDetails(from: model)
//             }
        }

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

final class CategoryDataSource: SimpleTableDataSource<CategoryCellModel, UITableViewCell> {

    override var cellProvider: ((UITableView, IndexPath) -> UITableViewCell) {
        set {}
        get { dataSource.cellProvider }
    }
    
    override var binder: ((CategoryCellModel, UITableViewCell) -> Void)? {
        set {}
        get {
            return { (model: CategoryCellModel, cell: UITableViewCell) in
                self.dataSource.binder?(model, cell as! CategoryTableViewCell)
            }
        }
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
        //    dataSource.mergingRules = GroupingStyle.byName.mergingStrategy()
        //    dataSource.filter = SuccessFilter.all.filter

        return dataSource
    }()
}
