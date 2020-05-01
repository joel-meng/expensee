//
//  LimitValidator.swift
//  Expensee
//
//  Created by Jun Meng on 1/5/20.
//  Copyright © 2020 Jun Meng. All rights reserved.
//

import Foundation

class RangeValidator {

    private let lowerLimit: Float
    private let upperLimit: Float

    init(lowerLimit: Float = 0, upperLimit: Float = 10_000) {
        self.lowerLimit = lowerLimit
        self.upperLimit = upperLimit
    }

    func validate(newAmountInput: String?) -> (valid: Bool, errorMessage: Error?) {

        guard let input = newAmountInput else {
            return (false, LimitError.invalidEntry)
        }

        guard let newAmount = Float(input) else {
            return (false, LimitError.invalidEntry)
        }

        if newAmount < lowerLimit || newAmount > upperLimit {
            return (false, LimitError.outOfRange)
        }

        return (true, nil)
    }
}

enum LimitError: Error {
    case invalidEntry
    case outOfRange
}
