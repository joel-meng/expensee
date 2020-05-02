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
        title = "Log Transaction"

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

    func showState(amount: Double?, currency: String?, date: Date?, categoryName: String?, categoryColor: String?) {
        transactionAmountTextField.text = amount.map(String.init(describing:))
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

    func handleSaveReady(_ enabled: Bool) {
        saveButton.isEnabled = enabled
    }
}

protocol TransactionPresenting: class {
    
    func showState(amount: Double?, currency: String?, date: Date?, categoryName: String?, categoryColor: String?)

    func handleSaveReady(_ enabled: Bool)
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

    private var router: TransactionRouting

    private var flavor: SceneFlavor = .save

    private var transaction: Transaction {
        didSet { didUpdateTransaction(transaction) }
    }

    private var category: Category {
        didSet { didUpdateCategory(category) }
    }

    init(view: TransactionPresenting, router: TransactionRouting, transaction: Transaction?, category: Category?) {
        self.transaction = transaction ?? Transaction(amount: nil, date: Date(), currency: "NZD")
        self.category = category ?? Category(name: nil, color: nil, limit: .init(amount: nil, currency: nil))
        self.view = view
        self.router = router
    }

    // MARK: - Update

    private func didUpdateTransaction(_ transaction: Transaction?) {
        print(transaction)
    }

    private func didUpdateCategory(_ category: Category?) {
        print(category)
    }

    private func isDateValidForSaving() -> Bool {
        return (transaction.amount != nil && category.name != nil && category.color != nil)
    }

    enum SceneFlavor {
        case update
        case save
    }
}

extension TransactionPresenter: TransactionControlling {

    // MARK: - State Handling
    private func setupInitialState(flavor: SceneFlavor) {
        switch flavor {
        case .save: displayCurrentState()
        case .update:
            break
        }
    }

    private func displayCurrentState() {
        view?.showState(amount: transaction.amount,
                        currency: transaction.currency,
                        date: transaction.date ?? Date(),
                        categoryName: category.name ?? "Select Category",
                        categoryColor: category.color ?? "#EEEEFF")
    }

    // MARK: - TransactionControlling

    func viewIsReady() {
        setupInitialState(flavor: flavor)
    }

    func didInputTransactionAmount(_ amount: Double?) {
        transaction = Transaction(amount: amount, date: transaction.date, currency: transaction.currency)
        view?.handleSaveReady(isDateValidForSaving())
    }

    func didUpdateTransactionCurrency(_ currency: String?) {
        transaction = Transaction(amount: transaction.amount, date: transaction.date, currency: currency ?? transaction.currency)
        view?.handleSaveReady(isDateValidForSaving())
    }

    func didSelectDate(_ date: Date) {
        transaction = Transaction(amount: transaction.amount, date: date, currency: transaction.currency)
        view?.handleSaveReady(isDateValidForSaving())
    }

    func didTapCategory() {
        router.routeToCategoryList { [weak self, category] (passBack) in
            guard let self = self else { return }
            self.category = passBack.category.map {
                TransactionPresenter.Category(name: $0.name, color: $0.color, limit: $0.budget.map {
                    TransactionPresenter.Limit(amount: $0.limit, currency: $0.currency)
                })
            } ?? category
            self.displayCurrentState()
            self.view?.handleSaveReady(self.isDateValidForSaving())
        }
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

        let amount: Double?

        let currency: String?
    }
}
