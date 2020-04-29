//
//  RestRequest.swift
//  GithubUsers
//
//  Created by Joel Meng on 10/26/19.
//  Copyright © 2019 Joel Meng. All rights reserved.
//

import Foundation

protocol RestRequest {
    func request() -> URLRequest?
}

protocol RestRequestDecorator: RestRequest {
    var baseRequest: RestRequest { get }
}
