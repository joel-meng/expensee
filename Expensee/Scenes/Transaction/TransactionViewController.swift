//
//  TransactionViewController.swift
//  Expensee
//
//  Created by Jun Meng on 2/5/20.
//  Copyright © 2020 Jun Meng. All rights reserved.
//

import UIKit

protocol TransactionPresenting: class {

    func showState(amount: Double?, currency: String?, date: String?, categoryName: String?, categoryColor: String?)

    func handleSaveReady(_ enabled: Bool)

    func updateDateButton(with text: String)

    func displayError(_ message: String)
}

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
    @IBOutlet weak var datePicker: UIDatePicker!

    // MARK: - VIPER

    var presenter: TransactionControlling!

    // MARK: - Lifecycles

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Log Transaction"

        setupTransactionAmountTextField(transactionAmountTextField)
        setupSegmentControl(currencySegmentControl)
        setupDateButton(dateButton)
        setupCategoryButton(categoryButton)
        setupDatePicker(datePicker)
        setupSaveButton()
        presenter.viewIsReady()
    }
    
    @objc private func didTapSave() {
        presenter.didTapSave()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }

    // MARK: - UI Setup
    
    // MARK: - DatePicker
    
    private func setupSaveButton() {
        let saveButton = UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(didTapSave))
        navigationItem.rightBarButtonItem = saveButton
    }

    private func setupDatePicker(_ datePicker: UIDatePicker) {
        datePicker.minuteInterval = 10
        datePicker.maximumDate = Date()
        datePicker.addTarget(self, action: #selector(didChangeDatePicker), for: .valueChanged)
    }
    
    @objc private func didChangeDatePicker(sender: UIDatePicker) {
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

    func updateDateButton(with text: String) {
        DispatchQueue.main.async { [weak self] in
            self?.dateButton.setTitle(text, for: .normal)
        }
    }


    func showState(amount: Double?, currency: String?, date: String?, categoryName: String?, categoryColor: String?) {
        DispatchQueue.main.async { [weak self] in
            self?.transactionAmountTextField.text = amount.map(String.init(describing:))
            if let currency = currency, let index = self?.segmentControlIndex(ofCurrency: currency) {
                self?.currencySegmentControl.selectedSegmentIndex = index
            }
            if let date = date {
                self?.dateButton.setTitle(date, for: .normal)
            }
            if let categoryName = categoryName {
                self?.categoryButton.setTitle(categoryName, for: .normal)
            }
            if let categoryColor = categoryColor {
                self?.categoryButton.backgroundColor = UIColor(categoryColor)
                self?.categoryButton.setTitleColor(UIColor.contrast(hex: categoryColor,
                                                                    lightColor: .white,
                                                                    darkColor: .darkGray),
                                             for: .normal)
            }
        }
    }

    func handleSaveReady(_ enabled: Bool) {
        DispatchQueue.main.async { [weak self] in
            self?.navigationItem.rightBarButtonItem?.isEnabled = enabled
        }
    }

    func displayError(_ message: String) {
        DispatchQueue.main.async { [weak self] in
            let alertController = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: "OK", style: .destructive, handler: nil))
            self?.present(alertController, animated: true, completion: nil)
        }
    }
}
