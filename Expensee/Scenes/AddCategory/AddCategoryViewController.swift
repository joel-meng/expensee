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
        provider.dataSource?.tapAction = { [weak self] selected in
            self?.presenter.didSelectCategoryColor(selected.id)
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
