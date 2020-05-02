//
//  TransactionDTO.swift
//  Expensee
//
//  Created by Jun Meng on 3/5/20.
//  Copyright © 2020 Jun Meng. All rights reserved.
//

import Foundation

struct TransactionDTO {

    let amount: Double

    let date: Date

    let currency: String

    let uid: UUID

    let category: CategoryDTO
}
