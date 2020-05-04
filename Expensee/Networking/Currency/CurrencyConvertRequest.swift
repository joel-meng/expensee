//
//  GithubRequest.swift
//  GithubUsers
//
//  Created by Joel Meng on 10/26/19.
//  Copyright © 2019 Joel Meng. All rights reserved.
//

import Foundation

struct CurrencyConvertRequest: RestRequest {
    
    private static let baseURL = "http://apilayer.net/api/"
    
    private let path: String
    
    init(path: String) {
        self.path = path
    }
    
    func request() -> URLRequest? {
        guard let url = URL(string: CurrencyConvertRequest.baseURL) else { return nil }
        guard let pathURL = URL(string: path, relativeTo: url) else { return nil }
        return URLRequest(url: pathURL)
    }
}
