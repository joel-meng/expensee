//
//  URLSessionDataTaskProtocol.swift
//  GithubUsers
//
//  Created by Joel Meng on 10/26/19.
//  Copyright © 2019 Joel Meng. All rights reserved.
//

import Foundation

public protocol URLSessionDataTaskProtocol {
    func resume()
	func cancel()
}

extension URLSessionDataTask: URLSessionDataTaskProtocol { }
