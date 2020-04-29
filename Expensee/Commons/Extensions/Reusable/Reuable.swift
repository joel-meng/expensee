//
//  Reuable.swift
//  Expensee
//
//  Created by Jun Meng on 29/4/20.
//  Copyright © 2020 Jun Meng. All rights reserved.
//

import Foundation

protocol Reusable: DescriptibleByType {
    static var reuseId: String { get }
}

extension Reusable {
    static var reuseId: String { Self.typeDescription() }
}
