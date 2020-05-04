//
//  TransactionListPresenter.swift
//  Expensee
//
//  Created by Jun Meng on 4/5/20.
//  Copyright © 2020 Jun Meng. All rights reserved.
//

import Foundation

protocol TransactionListControlling: class {

    func viewIsReady()

    func didTapAdd()

    func didSelectTransaction(_ id: UUID)
}

final class TransactionListPresenter {

    private let dateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .short
        dateFormatter.timeStyle = .short
        return dateFormatter
    }()

    private let currencyFormatter: NumberFormatter = {
        let currencyFormatter = NumberFormatter()
        currencyFormatter.numberStyle = .currency
        return currencyFormatter
    }()

    private weak var view: TransactionListPresenting?

    private let router: TransactionListRouting

    private let interactor: TransactionListInteracting

    init(view: TransactionListPresenting, interactor: TransactionListInteracting, router: TransactionListRouting) {
        self.view = view
        self.router = router
        self.interactor = interactor
    }
}

// MARK: - TransactionListControlling

extension TransactionListPresenter: TransactionListControlling {

    // MARK: - TransactionListControlling

    func viewIsReady() {
        loadTransactions()
    }

    func didTapAdd() {
        router.routeToAddTransaction { [weak self] in
            self?.loadTransactions()
        }
    }

    private func loadTransactions() {
        interactor.loadTransactions(with: ListTransactionInteractionRequest())
            .on(success: { [weak view, currencyFormatter, dateFormatter] (response) in
                let transactionCellModels = response.transactions.map { tx -> TransactionCellModel in
                    currencyFormatter.currencyCode = tx.originalCurrency
                    let amount = currencyFormatter.string(from: NSNumber(value: tx.originalAmount)) ?? "?"
                    return TransactionCellModel(currency: tx.originalCurrency,
                                                amount: amount,
                                                date: dateFormatter.string(from: tx.date),
                                                categoryName: tx.category.name,
                                                categoryColor: tx.category.color,
                                                overBudget: tx.overBudget,
                                                timestamp: tx.date,
                                                transactionId: tx.id)
                }
                view?.display(transactions: transactionCellModels)
            }, failure: { error in
                print(error)
            })
    }

    func didSelectTransaction(_ id: UUID) {

        interactor.fetchTransaction(with: FetchTransactionInteractionRequest(transactionId: id))
            .on(success: { [weak router, weak self] (response) in

            guard let tx = response.transaction, let category = response.transaction?.category else { return }
            let sceneModel = TransactionSceneModel(transaction:
                TransactionSceneModel.Transaction(id: tx.id,
                                                  amount: tx.amount,
                                                  date: tx.date,
                                                  currency: tx.currency,
                                                  originalAmount: tx.originalAmount,
                                                  originalCurrency: tx.originalCurrency,
                                                  category: TransactionSceneModel.Category(id: category.id,
                                                                                           name: category.name,
                                                                                           color: category.color)))
            router?.routeToUpdateTransaction(with: sceneModel) {
                self?.loadTransactions()
            }
        }, failure: { error in
            self.view?.showError("Oops, something went wrong.")
        })
    }
}
