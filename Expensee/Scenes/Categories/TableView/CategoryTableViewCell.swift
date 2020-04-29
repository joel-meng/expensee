//
//  CategoryTableViewCell.swift
//  Expensee
//
//  Created by Jun Meng on 29/4/20.
//  Copyright © 2020 Jun Meng. All rights reserved.
//

import UIKit

class CategoryTableViewCell: UITableViewCell, Reusable {

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var colorLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        colorLabel.layer.cornerRadius = 4
    }
}
