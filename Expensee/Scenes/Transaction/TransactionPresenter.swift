//
//  TransactionPresenter.swift
//  Expensee
//
//  Created by Jun Meng on 3/5/20.
//  Copyright © 2020 Jun Meng. All rights reserved.
//

import Foundation

protocol TransactionControlling: class {

    func viewIsReady()

    func didInputTransactionAmount(_ amount: Double?)

    func didUpdateTransactionCurrency(_ currency: String?)

    func didSelectDate(_ date: Date)

    func didTapCategory()

    func didTapSave()
}

final class TransactionPresenter {

    private weak var view: TransactionPresenting?

    private var router: TransactionRouting

    private var interactor: TransactionInteracting

    private var flavor: SceneFlavor = .save

    private var transaction: Transaction {
        didSet { didUpdateTransaction(transaction) }
    }

    private var category: Category {
        didSet { didUpdateCategory(category) }
    }

    init(view: TransactionPresenting,
         interactor: TransactionInteracting,
         router: TransactionRouting,
         transaction: Transaction?,
         category: Category?) {
        self.transaction = transaction ?? Transaction(amount: nil, date: Date(), currency: "NZD", uid: nil)
        self.category = category ?? Category(id: nil, name: nil, color: nil)
        self.flavor = transaction != nil && category != nil ? .update : .save
        self.view = view
        self.interactor = interactor
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
        case .update: displayCurrentState()
        }
    }

    private func displayCurrentState() {
        view?.showState(amount: transaction.amount,
                        currency: transaction.currency,
                        date: transaction.date ?? Date(),
                        categoryName: category.name ?? "Select Category",
                        categoryColor: category.color ?? "#647687")
    }

    // MARK: - TransactionControlling

    func viewIsReady() {
        setupInitialState(flavor: flavor)
    }

    func didInputTransactionAmount(_ amount: Double?) {
        transaction = Transaction(amount: amount, date: transaction.date, currency: transaction.currency, uid: transaction.uid)
        view?.handleSaveReady(isDateValidForSaving())
    }

    func didUpdateTransactionCurrency(_ currency: String?) {
        transaction = Transaction(amount: transaction.amount, date: transaction.date,
                                  currency: currency ?? transaction.currency, uid: transaction.uid)
        view?.handleSaveReady(isDateValidForSaving())
    }

    func didSelectDate(_ date: Date) {
        transaction = Transaction(amount: transaction.amount, date: date, currency: transaction.currency, uid: transaction.uid)
        view?.handleSaveReady(isDateValidForSaving())
    }

    func didTapCategory() {
        router.routeToCategoryList { [weak self, category] (passBack) in
            guard let self = self else { return }
            self.category = passBack.category.map {
                TransactionPresenter.Category(id: $0.uid, name: $0.name, color: $0.color)
            } ?? category
            self.displayCurrentState()
            self.view?.handleSaveReady(self.isDateValidForSaving())
        }
    }

    func didTapSave() {
        guard let amount = transaction.amount, let date = transaction.date else { return }
        guard let categoryId = category.id else { return }
        let currency = transaction.currency ?? "NZD"

        switch flavor {
        case .save: saveTransaction(amount: amount, date: date, categoryId: categoryId, currency: currency)
        case .update:
            updateTransaction(amount: amount,
                              date: date,
                              categoryId: categoryId,
                              currency: currency,
                              transactionId: transaction.uid)
        }
    }

    private func updateTransaction(amount: Double, date: Date, categoryId: UUID, currency: String, transactionId: UUID?) {
        guard let transactionId = transactionId else {
            view?.displayError("Oops, something unexpected happened.")
            return
        }

        let result = interactor.updateTransaction(with:
            UpdateTransactionRequest(transaction:
                UpdateTransactionRequest.Transaction(amount: amount,
                                                     date: date,
                                                     currency: currency,
                                                     uid: transactionId),
                                     categoryId: categoryId))

        result.on(success: { [weak router] (response) in
            print(response)
            router?.routeBackToTransactionList()
        }, failure: { [weak view] error in
            view?.displayError("Oops, something went wrong.")
        })
    }

    private func saveTransaction(amount: Double, date: Date, categoryId: UUID, currency: String) {
        let result = interactor.saveTransaction(with:
            SaveTransactionRequest(transaction:
                SaveTransactionRequest.Transaction(amount: amount,
                                                   date: date,
                                                   currency: currency),
                                   categoryId: categoryId))
        result.on(success: { [weak router] (response) in
            router?.routeBackToTransactionList()
        }, failure: { [weak view] error in
            view?.displayError("Oops, something went wrong.")
        })
    }
}

extension TransactionPresenter {

    struct Transaction {

        let amount: Double?

        let date: Date?

        let currency: String?

        let uid: UUID?
    }

    struct Category {

        let id: UUID?

        let name: String?

        let color: String?
    }
}
