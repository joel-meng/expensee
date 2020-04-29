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
        register(UINib.fromReuable(reusable: cellType), forCellReuseIdentifier: T.reuseId)
    }

    func dequeueReusableCell<C: UITableViewCell>(for indexPath: IndexPath, cellType: C.Type = C.self) -> C where C: Reusable {
        guard let cell = dequeueReusableCell(withIdentifier: cellType.reuseId, for: indexPath) as? C else {
            fatalError("Failed to dequeue a cell with identifier \(cellType.reuseId) with type \(cellType.self). ")
        }
        return cell
    }
}
