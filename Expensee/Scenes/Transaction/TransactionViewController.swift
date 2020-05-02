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

    private let transactionAmountTextfieldDelegate = CurrencyRangeTextFieldDelegation()
    @IBOutlet weak var transactionAmountTextField: UITextField!

    @IBOutlet weak var currencySegmentControl: UISegmentedControl!
    @IBOutlet weak var dateButton: UIButton!
    @IBOutlet weak var categoryButton: UIButton!
    @IBOutlet weak var saveButton: UIButton!

    var presenter: TransactionControlling!


    override func viewDidLoad() {
        super.viewDidLoad()

        setupTransactionAmountTextField(transactionAmountTextField)
        setupSegmentControl(currencySegmentControl)
    }

    // MARK: - UI Setup

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

    private func setupSegmentControl(_ segmentControl: UISegmentedControl) {
        segmentControl.addTarget(self, action: #selector(didValueChangeSegmentControl(_:)), for: .valueChanged)
    }

    @objc private func didValueChangeSegmentControl(_ sender: UISegmentedControl) {
        let selectedCurrency = currency(ofIndex: sender.selectedSegmentIndex)
        presenter.didUpdateTransactionCurrency(selectedCurrency)
    }

    private func currency(ofIndex index: Int) -> String {
        switch index {
        case 0: return "NZD"
        case 1: return "USD"
        default: fatalError("Not supported")
        }
    }

    // MARK: - Lifecycles

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        presenter.viewIsReady()
    }
}

extension TransactionViewController: TransactionPresenting {

}

protocol TransactionPresenting: class {

}

protocol TransactionControlling: class {

    func viewIsReady()

    func didInputTransactionAmount(_ amount: Double?)

    func didUpdateTransactionCurrency(_ currency: String?)

    func didTapDate()

    func didTapCategory()
}

final class TransactionPresenter {

    private weak var view: TransactionPresenting?

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
}

extension TransactionPresenter: TransactionControlling {

    func viewIsReady() {

    }

    func didInputTransactionAmount(_ amount: Double?) {
        transaction = Transaction(amount: amount ?? transaction.amount, date: transaction.date, currency: transaction.currency)
    }

    func didUpdateTransactionCurrency(_ currency: String?) {
        transaction = Transaction(amount: transaction.amount, date: transaction.date, currency: currency ?? transaction.currency)
    }

    func didTapDate() {

    }

    func didTapCategory() {

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
