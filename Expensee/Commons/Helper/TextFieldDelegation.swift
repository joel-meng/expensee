//
//  TextFieldDelegation.swift
//  Expensee
//
//  Created by Jun Meng on 1/5/20.
//  Copyright © 2020 Jun Meng. All rights reserved.
//

import UIKit

class TextFieldDelegation<T>: NSObject, UITextFieldDelegate {

    // MARK: - Public Methods

    var startEditingAction: ((UITextField) -> Void)?

    var endEditingAction: ((UITextField, Either<Bool, Error>) -> Void)?

    var updateAction: ((UITextField, Either<T, Error>) -> Void)?

    var convertingAction: ((String?) -> Either<T, Error>)?

    // MARK: - Methods

    func shouldTextField(_ textField: UITextField, allowNewText newText: String?) -> Bool {
        fatalError("Should be override in subclass")
    }

    func validate(_ text: String?) -> Either<Bool, Error> {
        fatalError("Should be override in subclass")
    }

    // MARK: - UITextFieldDelegate

    func textField(_ textField: UITextField,
                   shouldChangeCharactersIn shouldChangeCharactersInrange: NSRange,
                   replacementString string: String) -> Bool {
        guard let originalText = textField.text,
            let range = Range(shouldChangeCharactersInrange, in: originalText) else { return true }
        let newText = originalText.replacingCharacters(in: range, with: string)
        let newTextOrNil = newText.isEmpty ? nil : newText
        let shouldAllowChange = shouldTextField(textField, allowNewText: newTextOrNil)
        if shouldAllowChange, let converted = convertingAction?(newTextOrNil) {
            updateAction?(textField, converted)
        }
        return shouldAllowChange
    }

    func textFieldDidBeginEditing(_ textField: UITextField) {
        startEditingAction?(textField)
    }

    func textFieldDidEndEditing(_ textField: UITextField) {
        endEditingAction?(textField, validate(textField.text))
    }
}
