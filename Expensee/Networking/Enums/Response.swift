//
//  Response.swift
//  GithubUsers
//
//  Created by Joel Meng on 10/26/19.
//  Copyright © 2019 Joel Meng. All rights reserved.
//

import Foundation

enum Response<T> {
    case success(T)
    case failure(Error)
}
