//
//  StringExtension+TypeName.swift
//  
//
//  Created by Joel Meng on 7/8/19.
//

import Foundation

extension String {
    
    /// Will return the type name in `String`
    /// - Parameter Type: A Type
    static func name<T>(of type: T.Type) -> String {
        return String(String(describing: T.self).split(separator: ".").first!)
    }
}
