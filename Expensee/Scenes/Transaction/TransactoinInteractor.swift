//
//  TransactoinInteractor.swift
//  Expensee
//
//  Created by Jun Meng on 3/5/20.
//  Copyright © 2020 Jun Meng. All rights reserved.
//

import Foundation

protocol TransactionInteracting {

    func saveTransaction(with request: SaveTransactionRequest) -> SaveTransactionResponse
}

final class TransactionInteractor: TransactionInteracting {

    func saveTransaction(with request: SaveTransactionRequest) -> SaveTransactionResponse {
//        return SaveTransactionResponse(transaction: <#T##SaveTransactionResponse.Transaction#>)
        fatalError()
    }
}

struct SaveTransactionRequest {

    let transaction: Transaction

    struct Transaction {

    }
}

struct SaveTransactionResponse {

    let transaction: Transaction

    struct Transaction {

    }
}
