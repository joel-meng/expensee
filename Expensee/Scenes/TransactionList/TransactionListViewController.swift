//
//  TransactionsViewController.swift
//  Expensee
//
//  Created by Jun Meng on 2/5/20.
//  Copyright © 2020 Jun Meng. All rights reserved.
//

import UIKit

protocol TransactionListPresenting: class {

    func display(transactions: [TransactionCellModel])
}

protocol TransactionListControlling: class {

    func viewIsReady()

    func didTapAdd()
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

    func loadTransactions() {
        interactor.loadTransactions(with: ListTransactionInteractionRequest())
            .on(success: { [weak view, currencyFormatter, dateFormatter] (response) in
                let transactionCellModels = response.transactions.map { tx -> TransactionCellModel in
                    currencyFormatter.currencyCode = tx.currency
                    let amount = currencyFormatter.string(from: NSNumber(value: tx.amount)) ?? "?"
                    return TransactionCellModel(currency: tx.currency,
                                                amount: amount,
                                                date: dateFormatter.string(from: tx.date),
                                                categoryName: tx.category.name,
                                                categoryColor: tx.category.color,
                                                overBudget: tx.overBudget)
                }
                view?.display(transactions: transactionCellModels)
            }, failure: { error in
                print(error)
            })
    }
}

class TransactionListViewController: UIViewController {

    var presenter: TransactionListControlling!

    // MARK: - Lifecycles

    override func viewDidLoad() {
        super.viewDidLoad()
        view.makeStateful()
        
        tableView.registerReuableCell(TransactionTableViewCell.self)
        createBarButton()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        presenter.viewIsReady()
    }

    // MARK: - Navigation Bar Item

    private func createBarButton() {
        let addButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(didTapAdd))
        navigationItem.rightBarButtonItem = addButton
    }

    @objc private func didTapAdd() {
        presenter.didTapAdd()
    }

    // MARK: - TableViews

    @IBOutlet weak var tableView: UITableView!

    private lazy var dataSource: SimpleTableDataSource<TransactionCellModel, TransactionTableViewCell> = {
        let dataSource = SimpleTableDataSource<TransactionCellModel, TransactionTableViewCell>()

        dataSource.binder = { (row: TransactionCellModel, cell: TransactionTableViewCell) in
            cell.amountLabel.text = row.amount.description
            cell.categoryLabel.text = row.categoryName
            cell.categoryLabel.backgroundColor = UIColor(row.categoryColor)
            cell.datatimeLabel.text = row.date.description
            cell.overBudgetLabel.isHidden = !row.overBudget
        }

        dataSource.cellProvider = { tableView, indexPath in
            let cell: TransactionTableViewCell = tableView.dequeueReusableCell(for: indexPath)
            return cell
        }

        dataSource.sorter = { $0.date > $1.date }

        return dataSource
    }()

    private lazy var provider: TableViewProvider<TransactionCellModel, TransactionTableViewCell> = { [weak dataSource] in
        let provider = TableViewProvider<TransactionCellModel, TransactionTableViewCell>(tableView: tableView)
        provider.dataSource = dataSource
        provider.dataSource?.tapAction = { [weak presenter] selected in }

        return provider
     }()
}

// MARK: - TransactionsPresenting

extension TransactionListViewController: TransactionListPresenting {

    func display(transactions: [TransactionCellModel]) {
//        print(transactions)
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            let emptyMessage = "There's no transactions available yet, however, you can create one by clicking on the top right button.💡"
            self.view?.showState(.displaying(transactions.isEmpty ? .empty(message: emptyMessage) : .data))
            self.provider.updateData(transactions)
        }
    }
}
