//
//  TransactionsViewController.swift
//  Expensee
//
//  Created by Jun Meng on 2/5/20.
//  Copyright © 2020 Jun Meng. All rights reserved.
//

import UIKit

protocol TransactionsPresenting: class {

    func display(transactions: [TransactionCellModel])
}

protocol TransactionsControlling: class {

    func viewIsReady()
}

final class TransactionPresenter {

    private weak var view: TransactionsPresenting?

    init(view: TransactionsPresenting) {
        self.view = view
    }
}

extension TransactionPresenter: TransactionsControlling {

    func viewIsReady() {

    }

    func displayTransactions() {
        let tx = [
            TransactionCellModel(currency: "USD", amount: 123, date: Date(), categoryName: "Some", categoryColor: "#003322"),
            TransactionCellModel(currency: "USD", amount: 123, date: Date(), categoryName: "Some", categoryColor: "#003322"),
            TransactionCellModel(currency: "USD", amount: 123, date: Date(), categoryName: "Some", categoryColor: "#003322"),
            TransactionCellModel(currency: "USD", amount: 123, date: Date(), categoryName: "Some", categoryColor: "#003322"),
        ]
        view?.display(transactions: tx)
    }
}

class TransactionsViewController: UIViewController {

    var presenter: TransactionsControlling!

    // MARK: - Lifecycles

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        presenter.viewIsReady()
    }

    // MARK: - TableViews

    @IBOutlet weak var tableView: UITableView!

    private lazy var dataSource: SimpleTableDataSource<TransactionCellModel, TransactionTableViewCell> = {
        let dataSource = SimpleTableDataSource<TransactionCellModel, TransactionTableViewCell>()

        dataSource.binder = { (row: TransactionCellModel, cell: TransactionTableViewCell) in
            cell.amountLabel.text = row.amount.description
            cell.categoryLabel.text = row.categoryName
            cell.datatimeLabel.text = row.date.description
        }

        dataSource.cellProvider = { tableView, indexPath in
            let cell: TransactionTableViewCell = tableView.dequeueReusableCell(for: indexPath)
            return cell
        }

        dataSource.sorter = { $0.date < $1.date }

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

extension TransactionsViewController: TransactionsPresenting {

    func display(transactions: [TransactionCellModel]) {
        provider.updateData(transactions)
    }


}
