//
//  RequestCreator'.swift
//  GithubUsers
//
//  Created by Joel Meng on 7/27/19.
//  Copyright © 2019 Joel Meng. All rights reserved.
//

import Foundation

func createGETRequest(path: String, parameter: [String: String]) -> RestRequest {
	let reader = Reader<String, RestRequest> { request(withPath: $0) }

	let requestReader = (reader >>= get)
	if parameter.isEmpty {
		return requestReader.apply(from: path)
	}
	return (requestReader >>= parameterize(parameter)).apply(from: path)
}

private func parameterize(_ params: [String: String]) -> (_ base: RestRequest) -> RestRequest {
	return { base in
		return RestRequestURLQueryDecorator(params: params, request: base)
	}
}

private func authorized(_ base: RestRequest) -> RestRequest {
	return RestRequestAuthorizationDecorator(baseRequest: base)
}

private func request(withPath path: String) -> RestRequest {
	return CurrencyConvertRequest(path: path)
}

private func get(_ base: RestRequest) -> RestRequest {
	return RestRequestMethodDecorator(method: .GET, baseRequest: base)
}
