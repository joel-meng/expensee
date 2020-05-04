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

    func showError(_ error: String)
}

class TransactionListViewController: UIViewController {

    var presenter: TransactionListControlling!

    // MARK: - Lifecycles

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Transactions"
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

        let dayDateFormatter: DateFormatter = {
            let formatter = DateFormatter()
            formatter.dateStyle = .short
            formatter.timeStyle = .none
            return formatter
        }()

        dataSource.binder = { (row: TransactionCellModel, cell: TransactionTableViewCell) in
            cell.amountLabel.text = row.amount.description
            cell.categoryLabel.text = row.categoryName
            cell.categoryColorLabel.backgroundColor = UIColor(row.categoryColor)
            cell.datatimeLabel.text = row.date.description
            cell.overBudgetLabel.isHidden = !row.overBudget
        }

        dataSource.cellProvider = { tableView, indexPath in
            let cell: TransactionTableViewCell = tableView.dequeueReusableCell(for: indexPath)
            return cell
        }

        dataSource.rowSorter = { $0.timestamp > $1.timestamp }

        dataSource.sectionSorter = { $0.title < $1.title }

        dataSource.mergingRules = { (rows: [TransactionCellModel]) -> [Section<TransactionCellModel>] in
            Dictionary(grouping: rows) {
                dayDateFormatter.string(from: $0.timestamp)
            }.map { (key, rows) in
                Section<TransactionCellModel>(rows: rows, title: key)
            }
        }
        return dataSource
    }()

    private lazy var provider: TableViewProvider<TransactionCellModel, TransactionTableViewCell> = { [weak dataSource] in
        let provider = TableViewProvider<TransactionCellModel, TransactionTableViewCell>(tableView: tableView)
        provider.dataSource = dataSource
        provider.dataSource?.tapAction = { [weak presenter] selected in
            presenter?.didSelectTransaction(selected.transactionId)
        }

        return provider
     }()
}

// MARK: - TransactionsPresenting

extension TransactionListViewController: TransactionListPresenting {

    func showError(_ message: String) {
        DispatchQueue.main.async { [weak self] in
            let alertController = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: "OK", style: .destructive, handler: nil))
            self?.present(alertController, animated: true, completion: nil)
        }
    }

    func display(transactions: [TransactionCellModel]) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            let emptyMessage = "There's no transactions available yet, however, you can create one by clicking on the top right button.💡"
            self.view?.showState(.displaying(transactions.isEmpty ? .empty(message: emptyMessage) : .data))
            self.provider.updateData(transactions)
        }
    }
}
