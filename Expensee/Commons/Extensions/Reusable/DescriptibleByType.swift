//
//  SelfTypeDescriptible.swift
//  Expensee
//
//  Created by Jun Meng on 29/4/20.
//  Copyright © 2020 Jun Meng. All rights reserved.
//

import Foundation

protocol DescriptibleByType {
    static func typeDescription() -> String
}

extension DescriptibleByType {
    static func typeDescription() -> String {
        return String.name(of: type(of: self))
    }
}
