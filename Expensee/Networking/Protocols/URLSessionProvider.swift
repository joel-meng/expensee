//
//  URLSessionProvider.swift
//  GithubUsers
//
//  Created by Joel Meng on 10/26/19.
//  Copyright © 2019 Joel Meng. All rights reserved.
//

import Foundation

protocol URLSessionProvider {
    func dataTask(with request: URLRequest,
				  completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTaskProtocol
}

extension URLSession: URLSessionProvider {
    
    public func dataTask(with request: URLRequest, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTaskProtocol {
        return (dataTask(with: request, completionHandler: completionHandler) as URLSessionDataTask)
    }
}
