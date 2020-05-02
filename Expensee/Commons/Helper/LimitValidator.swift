//
//  LimitValidator.swift
//  Expensee
//
//  Created by Jun Meng on 1/5/20.
//  Copyright © 2020 Jun Meng. All rights reserved.
//

import Foundation

final class RangeValidator {

    private let lowerLimit: Double
    private let upperLimit: Double

    init(lowerLimit: Double = 0, upperLimit: Double = 10_000) {
        self.lowerLimit = lowerLimit
        self.upperLimit = upperLimit
    }

    func validate(newAmountInput: String?) -> (valid: Bool, errorMessage: Error?) {

        guard let input = newAmountInput else {
            return (false, LimitError.invalidEntry)
        }

        guard let newAmount = Double(input) else {
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
