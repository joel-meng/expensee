//
//  TableSection.swift
//  Expensee
//
//  Created by Jun Meng on 29/4/20.
//  Copyright © 2020 Jun Meng. All rights reserved.
//

import Foundation

struct Section<Row> {

    var title: String
    var rows: [Row]

    init(rows: [Row], title: String = "") {
        self.rows = rows
        self.title = title
    }

    var countOfRows: Int { rows.count }

    subscript(index: Int) -> Row {
        return rows[index]
    }
}
