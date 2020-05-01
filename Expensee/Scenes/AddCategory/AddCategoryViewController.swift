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
            presenter?.didSelectMonthlyLimitCurrency(currency(ofSegment: currencySegmentControl))
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
                presenter?.didSelectMonthlyLimit(amount?.floatValue)
            }, ifRight: { error in
                print("\(error)")
            })
        }

        nameTextField.delegate = anyTextFieldDelegate
        anyTextFieldDelegate.updateAction = { [weak presenter] _, result in
            result.do(ifLeft: { (name) in
                presenter?.didSelectCategoryName(name)
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
            cell.backgroundColor = UIColor(row.color)
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
            self.presenter.didSelectCategoryColor(selected.id)
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

    func didSelectMonthlyLimit(_ limit: Float?)

    func didSelectMonthlyLimitCurrency(_ currency: String?)

    func didSelectCategoryName(_ name: String?)

    func didSelectCategoryColor(_ color: UUID?)
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
        let color: UUID?
    }
}

extension AddCategoryPresenter: AddCategoryControlling {
    
    private func colorsCellModels(withSelection selection: UUID?) -> [ColorCellModel] {
        let categoriesColor = interactor.listColors(request: ListColorsRequest())
        return categoriesColor.colors.map {
            ColorCellModel(color: $0.color, isChecked: selection != nil ? selection == $0.uuid : false, id: $0.uuid)
        }
    }

    func viewIsReady() {
        view?.displayColors(colors: colorsCellModels(withSelection: nil))
        view?.setSaveButtonEnable(false)
    }
    
    func didSelectMonthlyLimit(_ limit: Float?) {
        self.monthlyLimit = MonthlyLimit(limit: limit, currency: monthlyLimit?.currency)
    }
    
    func didSelectMonthlyLimitCurrency(_ currency: String?) {
        self.monthlyLimit = MonthlyLimit(limit: monthlyLimit?.limit, currency: currency)
    }

    func didSelectCategoryName(_ name: String?) {
        category = Category(name: name, color: category?.color)
    }

    func didSelectCategoryColor(_ color: UUID?) {
        category = Category(name: category?.name, color: color)
        let cellModel = colorsCellModels(withSelection: color)
        view?.displayColors(colors: cellModel)
    }
}
