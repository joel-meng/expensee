//
//  UITableView+Reuable.swift
//  Expensee
//
//  Created by Jun Meng on 29/4/20.
//  Copyright © 2020 Jun Meng. All rights reserved.
//

import UIKit

extension UITableView {

    func registerReuableCell<T>(_ cellType: T.Type) where T: Reusable {
        register(UINib.fromReuable(reusable: cellType),
                 forCellReuseIdentifier: T.reuseId)
    }
}
