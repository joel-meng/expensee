//
//  SimpleTableViewProvider.swift
//  Expensee
//
//  Created by Jun Meng on 29/4/20.
//  Copyright © 2020 Jun Meng. All rights reserved.
//

import UIKit

final class TableViewProvider<Row, C: UITableViewCell> {

    weak var tableView: UITableView?

    var dataSource: SimpleTableDataSource<Row, C>? {
        didSet {
            DispatchQueue.main.async {
                self.tableView?.dataSource = self.dataSource
                self.tableView?.delegate = self.dataSource
                self.tableView?.reloadData()
            }
        }
    }

    init(tableView: UITableView) {
        self.tableView = tableView
    }

    func updateDataSourceMergingRule(_ rule: @escaping ([Row]) -> [Section<Row>]) {
        dataSource?.mergingRules = rule
        refreshTableView()
    }

    func updateDataSourceFilter(_ filter: @escaping (Row) -> Bool) {
        dataSource?.filter = filter
        refreshTableView()
    }

    func updateData(_ data: [Row]) {
        dataSource?.rows = data
        refreshTableView()
    }

    private func refreshTableView() {
        DispatchQueue.main.async { [weak self] in
            self?.tableView?.reloadData()
        }
    }
}

func mergeRows<Row, Key: Hashable>(grouping: @escaping (Row) -> Key,
                                   rowSorting: @escaping (Row, Row) -> Bool,
                                   sectionSorting: @escaping (Section<Row>, Section<Row>) -> Bool) -> ([Row]) -> [Section<Row>] {
    return { data in
        Dictionary(grouping: data, by: grouping).map { (arg) -> Section<Row> in
           return Section(rows: arg.value.sorted(by: rowSorting), title: "\(arg.key)")
       }.sorted(by: sectionSorting)
    }
}
