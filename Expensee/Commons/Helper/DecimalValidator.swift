//
//  DecimalValidator.swift
//  Expensee
//
//  Created by Jun Meng on 1/5/20.
//  Copyright © 2020 Jun Meng. All rights reserved.
//

import Foundation

class DecimalValidator {

    func validate(newInput: String?) -> (valid: Bool, errorMessage: Error?) {

        guard let text = newInput else {
            return (false, LimitError.invalidEntry)
        }

        let isNumeric = text.isEmpty || (Double(text) != nil)
        let numberOfDots = text.components(separatedBy: ".").count - 1

        let numberOfDecimalDigits: Int
        if let dotIndex = text.firstIndex(of: ".") {
            numberOfDecimalDigits = text.distance(from: dotIndex, to: text.endIndex) - 1
        } else {
            numberOfDecimalDigits = 0
        }

        let isValid = isNumeric && numberOfDots <= 1 && numberOfDecimalDigits <= 2
        return (isValid, nil)
    }
}

enum DecimalValidationError: Error {
    case invalidEntry
}
