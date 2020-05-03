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
        self.transaction = transaction ?? Transaction(amount: nil, date: Date(), currency: "NZD")
        self.category = category ?? Category(id: nil, name: nil, color: nil, limit: .init(amount: nil, currency: nil))
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
                TransactionPresenter.Category(id: $0.uid, name: $0.name, color: $0.color, limit: $0.budget.map {
                    TransactionPresenter.Limit(amount: $0.limit, currency: $0.currency)
                })
            } ?? category
            self.displayCurrentState()
            self.view?.handleSaveReady(self.isDateValidForSaving())
        }
    }

    func didTapSave() {
        saveTransaction()
    }

    private func saveTransaction() {
        guard let amount = transaction.amount, let date = transaction.date else { return }
        guard let categoryId = category.id else { return }

        let currency = transaction.currency ?? "NZD"
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
    }

    struct Category {

        let id: UUID?

        let name: String?

        let color: String?

        let limit: Limit?
    }

    struct Limit {

        let amount: Double?

        let currency: String?
    }
}
