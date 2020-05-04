//
//  TransactionTableViewCell.swift
//  Expensee
//
//  Created by Jun Meng on 2/5/20.
//  Copyright © 2020 Jun Meng. All rights reserved.
//

import UIKit

class TransactionTableViewCell: UITableViewCell, Reusable {

    @IBOutlet weak var datatimeLabel: UILabel!
    @IBOutlet weak var amountLabel: UILabel!
    @IBOutlet weak var categoryLabel: UILabel!
    @IBOutlet weak var overBudgetLabel: UILabel!
}
