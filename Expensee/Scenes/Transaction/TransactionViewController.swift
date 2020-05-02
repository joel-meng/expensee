//
//  TransactionViewController.swift
//  Expensee
//
//  Created by Jun Meng on 2/5/20.
//  Copyright © 2020 Jun Meng. All rights reserved.
//

import UIKit

class TransactionViewController: UIViewController {

    @IBOutlet weak var transactionNameLabel: UITextField!
    @IBOutlet weak var currencySegmentControl: UISegmentedControl!
    @IBOutlet weak var dateButton: UIButton!
    @IBOutlet weak var categoryButton: UIButton!
    @IBOutlet weak var saveButton: UIButton!

    var presenter: TransactionControlling!

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        presenter.viewIsReady()
    }
}

extension TransactionViewController: TransactionPresenting {

}

protocol TransactionPresenting: class {

}

protocol TransactionControlling: class {

    func viewIsReady()
}

final class TransactionPresenter {

    private weak var view: TransactionPresenting?

    private var transaction: Transaction?

    init(view: TransactionPresenting, transaction: Transaction?) {
        self.transaction = transaction
        self.view = view
    }
}

extension TransactionPresenter: TransactionControlling {

    func viewIsReady() {

    }

}

extension TransactionPresenter {

    struct Transaction {

        let amount: Double

        let currency: String

        let category: Category
    }

    struct Category {

        let name: String

        let color: String

        let limit: Limit?
    }

    struct Limit {

        let amount: String

        let currency: String
    }
}
