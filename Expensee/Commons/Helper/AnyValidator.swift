//
//  NonEmptyValidator.swift
//  Expensee
//
//  Created by Jun Meng on 1/5/20.
//  Copyright © 2020 Jun Meng. All rights reserved.
//

import Foundation

final class AnyValidator {

    func validate(newInput: String?) -> (valid: Bool, errorMessage: Error?) {
        return (true, nil)
    }
}
