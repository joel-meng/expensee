//
//  File.swift
//  
//
//  Created by Joel Meng on 7/8/19.
//

import UIKit

extension UINib {
    
    /// Load item corresponding UITableViewCell's nib with nib name `Item`'s type. For example,
    /// for item of type City, would load cell nib with name `CityTableViewCell`.
    /// - Parameter Type: Item's type, for example, `City`
    /// - Parameter bundle: Bundle
    static func `default`<T>(from itemType: T.Type, bundle: Bundle? = nil) -> UINib {
        let defaultNibName = String.name(of: itemType) + "TableViewCell"
        return UINib(nibName: defaultNibName, bundle: bundle)
    }
}

extension UINib {

    static func fromReuable<T: Reusable>(reusable: T.Type, bundle: Bundle? = nil) -> UINib {
        return UINib(nibName: T.reuseId, bundle: bundle)
    }
}

extension Bundle {
    
    var mainBundle: Bundle {
        return Bundle.main
    }
    
    /// Load item's corresponding table view cell's nib.
    /// - Parameter Type: Item type, e.g. `City`
    func loadTableCellNib<T>(for itemType: T.Type) -> UINib {
        let defaultNibName = String.name(of: itemType) + "TableViewCell"
        return UINib(nibName: defaultNibName, bundle: self)
    }
}
