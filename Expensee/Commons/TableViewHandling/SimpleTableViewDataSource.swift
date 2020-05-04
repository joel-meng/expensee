//
//  CategoriesTableRepresenting.swift
//  Expensee
//
//  Created by Jun Meng on 29/4/20.
//  Copyright © 2020 Jun Meng. All rights reserved.
//

import UIKit

class SimpleTableDataSource<Row, Cell>: NSObject, UITableViewDataSource, UITableViewDelegate where Cell: UITableViewCell {

    private var sections: [Section<Row>] = []

    var rows: [Row] = [] {
        didSet {
            sections = mergingRules(rows.filter(filter).sorted(by: rowSorter)).sorted(by: sectionSorter)
        }
    }

    var tapAction: ((Row) -> Void)?

    var filter: (Row) -> Bool = { _ in return true } {
        didSet {
            sections = mergingRules(rows.filter(filter).sorted(by: rowSorter)).sorted(by: sectionSorter)
        }
    }

    var rowSorter: (Row, Row) -> Bool = { _, _ in true }

    var sectionSorter: (Section<Row>, Section<Row>) -> Bool = { _, _ in true }

    var mergingRules: ([Row]) -> [Section<Row>] = { [Section<Row>(rows: $0, title: "")] } {
        didSet {
            sections = mergingRules(rows.filter(filter).sorted(by: rowSorter)).sorted(by: sectionSorter)
        }
    }

    var binder: ((Row, Cell) -> Void)?

    var cellProvider: ((UITableView, IndexPath) -> Cell) = { (tableView, indexPath) in
        return tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! Cell
    }

    // MARK: - UITableViewDataSource

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        sections[section].title
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        sections.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sections[section].countOfRows
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = cellProvider(tableView, indexPath)
        let row = sections[indexPath.section][indexPath.row]
        binder?(row, cell)
        return cell
    }

    // MARK: - UITableViewDelegate

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let selected = sections[indexPath.section][indexPath.row]
        tapAction?(selected)
    }
}
