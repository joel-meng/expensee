//
//  TransactionViewController.swift
//  Expensee
//
//  Created by Jun Meng on 2/5/20.
//  Copyright © 2020 Jun Meng. All rights reserved.
//

import UIKit

class TransactionViewController: UIViewController {

    private let MAX_TRANSACTION_AMOUNT: Double = 999_999_999_999_999
    private let MIN_TRANSACTION_AMOUNT: Double = 0

    // MARK: - Delegate

    private let transactionAmountTextfieldDelegate = CurrencyRangeTextFieldDelegation()

    // MARK: - UI

    @IBOutlet weak var transactionAmountTextField: UITextField!
    @IBOutlet weak var currencySegmentControl: UISegmentedControl!
    @IBOutlet weak var dateButton: UIButton!
    @IBOutlet weak var categoryButton: UIButton!
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var datePicker: UIDatePicker!

    // MARK: - VIPER

    var presenter: TransactionControlling!
    
    // MARK: - Formatter

    private var dateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.timeStyle = .short
        dateFormatter.dateStyle = .short
        return dateFormatter
    }()

    // MARK: - Lifecycles

    override func viewDidLoad() {
        super.viewDidLoad()

        setupTransactionAmountTextField(transactionAmountTextField)
        setupSegmentControl(currencySegmentControl)
        setupDateButton(dateButton)
        setupCategoryButton(categoryButton)
        setupDatePicker(datePicker)
        presenter.viewIsReady()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }

    // MARK: - UI Setup
    
    // MARK: - DatePicker
    
    private func setupDatePicker(_ datePicker: UIDatePicker) {
        datePicker.minuteInterval = 10
        datePicker.maximumDate = Date()
        datePicker.addTarget(self, action: #selector(didChangeDatePicker), for: .valueChanged)
    }
    
    @objc private func didChangeDatePicker(sender: UIDatePicker) {
        dateButton.setTitle(dateFormatter.string(from: sender.date), for: .normal)
        presenter.didSelectDate(sender.date)
    }
    
    // MARK: - Date Button
    private func setupDateButton(_ button: UIButton) {
        button.addTarget(self, action: #selector(didTapDateButton), for: .touchUpInside)
    }
    
    @objc private func didTapDateButton(sender: UIButton) {
        datePicker.isHidden = !datePicker.isHidden
    }
    
    // MARK: - Category Button
    
    private func setupCategoryButton(_ button: UIButton) {
        button.addTarget(self, action: #selector(didTapCategoryButton), for: .touchUpInside)
    }
    
    @objc private func didTapCategoryButton(sender: UIButton) {
        presenter.didTapCategory()
    }
    
    // MARK: - Amount TextField

    private func setupTransactionAmountTextField(_ textField: UITextField) {
        transactionAmountTextField.delegate = transactionAmountTextfieldDelegate
        transactionAmountTextfieldDelegate.rangeValidator = RangeValidator(lowerLimit: MIN_TRANSACTION_AMOUNT,
                                                                           upperLimit: MAX_TRANSACTION_AMOUNT)
        transactionAmountTextfieldDelegate.updateAction = { [weak presenter] _, amount in
            amount.do(ifLeft: { (amount) in
                presenter?.didInputTransactionAmount(amount?.doubleValue)
            }, ifRight: { error in
                // TODO: - handle error
            })
        }
    }

    // MARK: - Segment Control
    
    private func setupSegmentControl(_ segmentControl: UISegmentedControl) {
        segmentControl.addTarget(self, action: #selector(didValueChangeSegmentControl(_:)), for: .valueChanged)
    }

    @objc private func didValueChangeSegmentControl(_ sender: UISegmentedControl) {
        let selectedCurrency = currency(ofIndex: sender.selectedSegmentIndex)
        presenter.didUpdateTransactionCurrency(selectedCurrency)
    }

    private func segmentControlIndex(ofCurrency currency: String) -> Int {
        switch currency {
        case "NZD": return 0
        case "USD": return 1
        default: fatalError("Not supported")
        }
    }

    private func currency(ofIndex index: Int) -> String {
        switch index {
        case 0: return "NZD"
        case 1: return "USD"
        default: fatalError("Not supported")
        }
    }
}

// MARK: - TransactionPresenting

extension TransactionViewController: TransactionPresenting {

    func showIntialState(_ amount: String?, currency: String?, date: Date?, categoryName: String?, categoryColor: String?) {
        transactionAmountTextField.text = amount
        if let currency = currency {
            currencySegmentControl.selectedSegmentIndex = segmentControlIndex(ofCurrency: currency)
        }
        if let date = date {
            dateButton.setTitle(dateFormatter.string(from: date), for: .normal)
        }
        if let categoryName = categoryName {
            categoryButton.setTitle(categoryName, for: .normal)
        }
        if let categoryColor = categoryColor {
            categoryButton.backgroundColor = UIColor(categoryColor)
        }
    }
}

protocol TransactionPresenting: class {
    
    func showIntialState(_ amount: String?, currency: String?, date: Date?, categoryName: String?, categoryColor: String?)
}

protocol TransactionControlling: class {

    func viewIsReady()

    func didInputTransactionAmount(_ amount: Double?)

    func didUpdateTransactionCurrency(_ currency: String?)

    func didSelectDate(_ date: Date)

    func didTapCategory()
}

final class TransactionPresenter {

    private weak var view: TransactionPresenting?

    private var flavor: SceneFlavor = .save

    private var transaction: Transaction {
        didSet { didUpdateTransaction(transaction) }
    }

    private var category: Category {
        didSet { didUpdateTransaction(transaction) }
    }

    init(view: TransactionPresenting, transaction: Transaction?, category: Category?) {
        self.transaction = transaction ?? Transaction(amount: nil, date: nil, currency: nil)
        self.category = category ?? Category(name: nil, color: nil, limit: .init(amount: nil, currency: nil))
        self.view = view
    }

    // MARK: - Update

    private func didUpdateTransaction(_ transaction: Transaction?) {
        print(transaction)
    }

    private func didUpdateCategory(_ category: Category?) {
        print(category)
    }

    enum SceneFlavor {
        case update
        case save
    }
}

extension TransactionPresenter: TransactionControlling {

    func viewIsReady() {
        setupInitialState(flavor: flavor)
    }

    private func setupInitialState(flavor: SceneFlavor) {
        switch flavor {
        case .save: view?.showIntialState(nil, currency: nil, date: Date(), categoryName: "DFDS", categoryColor: "#336699")
            break
        case .update:
            break
        }
    }

    // MARK: - <#Comments#>

    func didInputTransactionAmount(_ amount: Double?) {
        transaction = Transaction(amount: amount ?? transaction.amount, date: transaction.date, currency: transaction.currency)
    }

    func didUpdateTransactionCurrency(_ currency: String?) {
        transaction = Transaction(amount: transaction.amount, date: transaction.date, currency: currency ?? transaction.currency)
    }

    func didSelectDate(_ date: Date) {
        transaction = Transaction(amount: transaction.amount, date: date, currency: transaction.currency)
    }

    func didTapCategory() {
        print("cate")
    }
}

extension TransactionPresenter {

    struct Transaction {

        let amount: Double?

        let date: Date?

        let currency: String?
    }

    struct Category {

        let name: String?

        let color: String?

        let limit: Limit?
    }

    struct Limit {

        let amount: String?

        let currency: String?
    }
}
