//
//  NameTextFieldDelegate.swift
//  Expensee
//
//  Created by Jun Meng on 1/5/20.
//  Copyright © 2020 Jun Meng. All rights reserved.
//

import UIKit

final class AnyTextFieldDelegation: TextFieldDelegation<String?> {

    private var validator = AnyValidator()

    override init() {
        super.init()
        convertingAction = { text in
            return .left(text)
        }
    }

    // MARK: - Private methods

    override func shouldTextField(_ textField: UITextField, allowNewText newText: String?) -> Bool {
        if newText == nil { return true }
        return validate(newText).left == true
    }

    override func validate(_ text: String?) -> Either<Bool, Error> {
        let (valid, error) = validator.validate(newInput: text)
        if let error = error { return .right(error) }
        return .left(valid)
    }
}
