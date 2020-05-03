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

    private weak var view: TransactionListPresenting?

    private var router: TransactionListRouting

    init(view: TransactionListPresenting, router: TransactionListRouting) {
        self.view = view
        self.router = router
    }
}

// MARK: - TransactionListControlling

extension TransactionListPresenter: TransactionListControlling {

    // MARK: - TransactionListControlling

    func viewIsReady() {
        displayTransactions()
    }

    func didTapAdd() {
        router.routeToAddTransaction { [weak self] in
            self?.displayTransactions()
        }
    }

    func displayTransactions() {
        let tx: [TransactionCellModel] = [
//            TransactionCellModel(currency: "USD", amount: 123, date: Date(), categoryName: "Some", categoryColor: "#003322"),
//            TransactionCellModel(currency: "USD", amount: 123, date: Date(), categoryName: "Some", categoryColor: "#003322"),
//            TransactionCellModel(currency: "USD", amount: 123, date: Date(), categoryName: "Some", categoryColor: "#003322"),
//            TransactionCellModel(currency: "USD", amount: 123, date: Date(), categoryName: "Some", categoryColor: "#003322"),
        ]
        view?.display(transactions: tx)
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

//        view.showState(.loading)
//        DispatchQueue.main.asyncAfter(wallDeadline: .now() + 0.1) { [weak self] in
//            self?.presenter.viewIsReady()
//            self?.presenter.didTapAdd()
//        }


        CategoriesRepository(context: CoreDataStore.shared?.context).fetchAllWithTransactions().on(success: {// _ in
            $0.forEach {
                print($0)
            }
        }, failure: {
            print($0)
        })
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

extension TransactionListViewController: TransactionListPresenting {

    func display(transactions: [TransactionCellModel]) {
        let emptyMessage = "There's no transactions available yet, however, you can create one by clicking on the top right button.💡"
        view.showState(.displaying(transactions.isEmpty ? .empty(message: emptyMessage) : .data))
        provider.updateData(transactions)
    }
}
