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
        title = "Category"

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

    private func segmentIndex(ofCurrency currency: String) -> Int {
        switch currency {
        case "USD": return 1
        case "NZD": return 0
        default: fatalError()
        }
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

        dataSource.rowSorter = { $0.color < $1.color }

        return dataSource
    }()
    
    private lazy var provider: TableViewProvider<ColorCellModel, UITableViewCell> = { [weak dataSource] in
        let provider = TableViewProvider<ColorCellModel, UITableViewCell>(tableView: tableView)
        provider.dataSource = dataSource
        provider.dataSource?.tapAction = { [weak self] selected in
            self?.presenter.didSelectCategoryColor(selected.color)
        }

        return provider
    }()
}

extension AddCategoryViewController: AddCategoryPresenting {
    
    func displayCategory(name: String, monthlyBudget: (Double, String)?) {
        nameTextField.text = name
        if let monthly = monthlyBudget {
            limitTextField.text = String(describing: monthly.0)
            currencySegmentControl.selectedSegmentIndex = segmentIndex(ofCurrency: monthly.1)
        }
    }

    func displayColors(colors: [ColorCellModel]) {
        provider.updateData(colors)
    }
    
    func setSaveButtonEnable(_ enabled: Bool) {
        saveButton.isEnabled = enabled
    }

    func displayError(_ message: String) {
        DispatchQueue.main.async { [weak self] in
            let alertController = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: "OK", style: .destructive, handler: nil))
            self?.present(alertController, animated: true, completion: nil)
        }
    }
}

struct ColorCellModel {
    let color: String
    let isChecked: Bool
}

struct CategoryModel {
    let category: Category?

    struct Category {
        let uid: UUID
        let name: String
        let color: String
        let budget: Budget?
    }

    struct Budget {
        let currency: String
        let limit: Double
    }
}
