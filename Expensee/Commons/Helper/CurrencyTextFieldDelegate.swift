//
//  CurrencyTextFieldDelegate.swift
//  Expensee
//
//  Created by Jun Meng on 1/5/20.
//  Copyright © 2020 Jun Meng. All rights reserved.
//

import UIKit

final class CurrencyRangeTextFieldDelegation: TextFieldDelegation<NSNumber?> {

    var rangeValidator = RangeValidator()

    var decimalValidator = DecimalValidator()

    var currencyCode: String? {
        didSet {
            formatter.currencyCode = currencyCode
        }
    }

    override init() {
        super.init()
        setConvertingAction()
    }

    // MARK: - Private

    private func setConvertingAction() {
        convertingAction = { [weak formatter] text in
            guard let text = text else { return .left(nil) }
            if let converted = formatter?.number(from: text) {
                return .left(converted)
            }
            return .right(CurrencyTextFieldError.unableToConvertToTargetType)
        }
    }

    private lazy var formatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = currencyCode
        formatter.currencySymbol = ""
        formatter.internationalCurrencySymbol = ""
        return formatter
    }()

    // MARK: - Private methods

    override func shouldTextField(_ textField: UITextField, allowNewText newText: String?) -> Bool {
        if newText == nil { return true }
        return validate(newText).left == true
    }

    override func validate(_ text: String?) -> Either<Bool, Error> {
        let (validDecimal, error) = decimalValidator.validate(newInput: text)
        if let error = error { return .right(error) }

        let (validRange, message) = rangeValidator.validate(newAmountInput: text)
        if let message = message {
            return .right(message)
        }
        return .left(validRange && validDecimal)
    }
}

enum CurrencyTextFieldError: Error {
    case unableToConvertToTargetType
}
