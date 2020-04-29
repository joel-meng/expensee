//
//  UIView+DefaultNib.swift
//  Expensee
//
//  Created by Jun Meng on 29/4/20.
//  Copyright © 2020 Jun Meng. All rights reserved.
//

import UIKit

extension DescriptibleByType where Self: UIView {

    var defaultNib: UINib {
        return UINib(nibName: Self.typeDescription(), bundle: nil)
    }
}
