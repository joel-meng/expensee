//
//  RestRequestMethodDecorator.swift
//  GithubUsers
//
//  Created by Joel Meng on 10/26/19.
//  Copyright © 2019 Joel Meng. All rights reserved.
//

import Foundation

struct RestRequestMethodDecorator: RestRequestDecorator {
    
    let baseRequest: RestRequest
    private let method: HTTPMethod
    
    init(method: HTTPMethod, baseRequest: RestRequest) {
        self.method = method
        self.baseRequest = baseRequest
    }
    
    func request() -> URLRequest? {
        guard var baseRequest = baseRequest.request() else { return nil }
        baseRequest.httpMethod = method.rawValue
		return baseRequest
    }
}
