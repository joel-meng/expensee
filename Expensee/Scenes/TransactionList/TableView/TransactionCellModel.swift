//
//  TransactionCellModel.swift
//  Expensee
//
//  Created by Jun Meng on 2/5/20.
//  Copyright © 2020 Jun Meng. All rights reserved.
//

import Foundation

struct TransactionCellModel {

    let currency: String

    let amount: String

    let date: String

    let categoryName: String

    let categoryColor: String

    let overBudget: Bool

    let timestamp: Date

    let transactionId: UUID
}
