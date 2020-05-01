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
    @IBOutlet weak var currencySegmentControl: UISegmentedControl! {
        didSet {
            presenter?.setMonthlyLimitCurrency(currency(ofSegment: currencySegmentControl))
        }
    }

    var presenter: AddCategoryControlling!
    
    private lazy var amountTextFieldDelegate = CurrencyRangeTextFieldDelegation()

    private lazy var anyTextFieldDelegate = AnyTextFieldDelegation()

    override func viewDidLoad() {
        super.viewDidLoad()

        limitTextField.delegate = amountTextFieldDelegate
        amountTextFieldDelegate.updateAction = { [weak presenter] _, result in
            result.do(ifLeft: { (amount) in
                presenter?.setMonthlyLimit(amount?.floatValue)
            }, ifRight: { error in
                print("\(error)")
            })
        }

        nameTextField.delegate = anyTextFieldDelegate
        anyTextFieldDelegate.updateAction = { [weak presenter] _, result in
            result.do(ifLeft: { (name) in
                presenter?.setCategoryName(name)
            }, ifRight: { error in
                print("\(error)")
            })
        }
        
        presenter.viewIsReady()
    }

    private func currency(ofSegment segmentControl: UISegmentedControl) -> String {
        if segmentControl.selectedSegmentIndex == 0 { return "NZD" }
        return "USD"
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
        provider.dataSource?.tapAction = { selected in
        }

        return provider
    }()
}

struct ColorCellModel {
    let color: String
    let isChecked: Bool
    let id: UUID
}

extension AddCategoryViewController: AddCategoryPresenting {
    
    func displayColors(colors: [ColorCellModel]) {
        provider.updateData(colors)
    }
    
    func setSaveButtonEnable(_ enabled: Bool) {
        saveButton.isEnabled = enabled
    }
}

protocol AddCategoryPresenting: class {
    
    func displayColors(colors: [ColorCellModel])
    
    func setSaveButtonEnable(_ enabled: Bool)
}

protocol AddCategoryControlling: class {
    
    func viewIsReady()

    func setMonthlyLimit(_ limit: Float?)

    func setMonthlyLimitCurrency(_ currency: String?)

    func setCategoryName(_ name: String?)

    func setCategoryColor(_ color: String?)
}

final class AddCategoryPresenter {
    
    private weak var view: AddCategoryPresenting?
    private var interactor: AddCategoryInteracting
    
    private var monthlyLimit: MonthlyLimit? {
        didSet { update() }
    }

    private var category: Category? {
        didSet { update() }
    }

    init(view: AddCategoryPresenting, interactor: AddCategoryInteracting) {
        self.view = view
        self.interactor = interactor
    }

    private func update() {
        print(category)
        print(monthlyLimit)
    }

    struct MonthlyLimit {
        let limit: Float?
        let currency: String?
    }

    struct Category {
        let name: String?
        let color: String?
    }
}

extension AddCategoryPresenter: AddCategoryControlling {
    
    func viewIsReady() {
        let categoriesColor = interactor.listColors(request: ListColorsRequest())
        let cells = categoriesColor.colors.map {
            ColorCellModel(color: $0.color, isChecked: false, id: $0.uuid)
        }
        view?.displayColors(colors: cells)
        view?.setSaveButtonEnable(false)
    }
    
    func setMonthlyLimit(_ limit: Float?) {
        self.monthlyLimit = MonthlyLimit(limit: limit, currency: monthlyLimit?.currency)
    }
    
    func setMonthlyLimitCurrency(_ currency: String?) {
        self.monthlyLimit = MonthlyLimit(limit: monthlyLimit?.limit, currency: currency)
    }

    func setCategoryName(_ name: String?) {
        category = Category(name: name, color: category?.color)
    }

    func setCategoryColor(_ color: String?) {
        category = Category(name: category?.name, color: color)
    }
}
