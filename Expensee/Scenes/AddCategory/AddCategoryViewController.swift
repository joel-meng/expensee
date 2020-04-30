//
//  AddCategoryViewController.swift
//  Expensee
//
//  Created by Jun Meng on 1/5/20.
//  Copyright © 2020 Jun Meng. All rights reserved.
//

import UIKit

class AddCategoryViewController: UIViewController {

    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var saveButton: UIButton!
    
    @IBOutlet weak var limitTextField: UITextField!
    @IBOutlet weak var currencySegmentControl: UISegmentedControl!
    var presenter: AddCategoryControlling!
    
    override func viewDidLoad() {
        super.viewDidLoad()

//        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        
        presenter.viewIsReady()
    }

    private let dataSource: SimpleTableDataSource<ColorCellModel, UITableViewCell> = {
        
        let dataSource = SimpleTableDataSource<ColorCellModel, UITableViewCell>()

        dataSource.binder = { (row: ColorCellModel, cell: UITableViewCell) in
            cell.textLabel?.text = row.color
            cell.accessoryType = row.isChecked ? .checkmark : .none
        }

        dataSource.cellProvider = { tableView, indexPath in
            let cell = tableView.dequeueReusableCell(withIdentifier: "Cell") ??
                UITableViewCell(style: .subtitle, reuseIdentifier: "Cell")
            return cell
        }

        dataSource.sorter = { $0.color < $1.color }

        return dataSource
    }()
    
    private lazy var provider: TableViewProvider<ColorCellModel, UITableViewCell> = { [weak dataSource] in
        let provider = TableViewProvider<ColorCellModel, UITableViewCell>(tableView: tableView)
        provider.dataSource = dataSource
        provider.dataSource?.tapAction = { selected in }

        return provider
    }()
}

final class ColorDataSource: SimpleTableDataSource<ColorCellModel, UITableViewCell> {

}


struct ColorCellModel {
    let color: String
    let isChecked: Bool
}

extension AddCategoryViewController: AddCategoryPresenting {
    
    func displayColors(colors: [(String, Bool)]) {
        provider.updateData(colors.map { ColorCellModel.init(color: $0.0, isChecked: $0.1) })
    }
    
    func setSaveButtonEnable(_ enabled: Bool) {
        saveButton.isEnabled = enabled
    }
}

protocol AddCategoryPresenting: class {
    
    func displayColors(colors: [(String, Bool)])
    
    func setSaveButtonEnable(_ enabled: Bool)
}

protocol AddCategoryControlling {
    
    func viewIsReady()
}

final class AddCategoryPresenter {
    
    private weak var view: AddCategoryPresenting?
    
    init(view: AddCategoryPresenting) {
        self.view = view
    }
}

extension AddCategoryPresenter: AddCategoryControlling {
    
    func viewIsReady() {
        view?.displayColors(colors: [("A", true), ("B", false), ("C", true)])
        view?.setSaveButtonEnable(false)
    }
    
    
}
