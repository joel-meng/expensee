//
//  RestRequestAuthorizationDecorator.swift
//  GithubUsers
//
//  Created by Joel Meng on 10/26/19.
//  Copyright © 2019 Joel Meng. All rights reserved.
//

import Foundation

struct RestRequestAuthorizationDecorator: RestRequestDecorator {

	private static let clientID: String = ""
	
	let baseRequest: RestRequest

	init(baseRequest: RestRequest) {
		self.baseRequest = baseRequest
	}

	func request() -> URLRequest? {
		guard var baseRequest = baseRequest.request() else { return nil }
		baseRequest.setValue(RestRequestAuthorizationDecorator.clientID,
							 forHTTPHeaderField: "Authorization")
		return baseRequest
	}
}
