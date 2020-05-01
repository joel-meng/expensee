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
    
    private lazy var amountTextFieldDelegate = CurrencyRangeTextFieldDelegation()

    private lazy var anyTextFieldDelegate = AnyTextFieldDelegation()

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Create Category"

        limitTextField.delegate = amountTextFieldDelegate
        amountTextFieldDelegate.updateAction = { [weak presenter] _, result in
            result.do(ifLeft: { (amount) in
                presenter?.didSelectMonthlyLimit(amount?.doubleValue)
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
        
        currencySegmentControl.addTarget(self, action: #selector(updateCurrencySelection(sender:)), for: .valueChanged)
        updateCurrencySelection(sender: currencySegmentControl)
        saveButton.addTarget(self, action: #selector(saveButtonTapped(sender:)), for: .touchUpInside)
        presenter.viewIsReady()
    }

    @objc
    private func saveButtonTapped(sender: UIButton) {
        presenter.didTapSave()
    }

    @objc
    private func updateCurrencySelection(sender: UISegmentedControl) {
        presenter.didSelectMonthlyLimitCurrency(currency(ofSegment: sender))
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

    func didSelectMonthlyLimit(_ limit: Double?)

    func didSelectMonthlyLimitCurrency(_ currency: String?)

    func didSelectCategoryName(_ name: String?)

    func didSelectCategoryColor(_ color: UUID?)

    func didTapSave()
}

final class AddCategoryPresenter {
    
    private weak var view: AddCategoryPresenting?

    private let interactor: AddCategoryInteracting

    private let router: AddCategoriesRouting
    
    private var monthlyLimit: MonthlyLimit? {
        didSet { update(category: category, limit: monthlyLimit) }
    }

    private var category: Category? {
        didSet { update(category: category, limit: monthlyLimit) }
    }

    init(view: AddCategoryPresenting, interactor: AddCategoryInteracting, router: AddCategoriesRouting) {
        self.view = view
        self.interactor = interactor
        self.router = router
    }

    private func update(category: Category?, limit: MonthlyLimit?) {
        view?.setSaveButtonEnable(isValid(category: category, limit: limit))
    }

    private func isValid(category: Category?, limit: MonthlyLimit?) -> Bool {
        guard category?.name != nil else { return false }
        if limit?.limit != nil, limit?.currency != nil {
            return true
        } else {
            return true
        }
    }

    struct MonthlyLimit {
        let limit: Double?
        let currency: String?
    }

    struct Category {
        let name: String?
        let color: UUID?
    }
}

extension AddCategoryPresenter: AddCategoryControlling {
    
    func viewIsReady() {
        view?.displayColors(colors: colorsCellModels(withSelection: nil))
        view?.setSaveButtonEnable(false)
    }
    
    func didSelectMonthlyLimit(_ limit: Double?) {
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

    func didTapSave() {
        guard let name = category?.name, let color = category?.color else {
            // TODO: - display error
            return
        }

        let monthlyLimit = self.monthlyLimit.flatMap { monthlyLimit -> SaveCategoryRequest.MontlyLimit? in
            guard let limit = monthlyLimit.limit, let currency = monthlyLimit.currency else { return nil }
            return SaveCategoryRequest.MontlyLimit(limitAmount: limit, limitCurrency: currency)
        }

        let category = SaveCategoryRequest.Category(name: name, color: color, monthlyLimit: monthlyLimit)
        let savedFuture = interactor.saveCategory(request: SaveCategoryRequest(category: category))
        savedFuture.on(success: { [weak router] (response) in
            router?.routeBackAndRefresh()
        }, failure: { error in
            print(error)
        })
    }

    // MARK: - Color Cells

    private func colorsCellModels(withSelection selection: UUID?) -> [ColorCellModel] {
        let categoriesColor = interactor.listColors(request: ListColorsRequest())
        return categoriesColor.colors.map {
            ColorCellModel(color: $0.color, isChecked: selection != nil ? selection == $0.uuid : false, id: $0.uuid)
        }
    }
}
