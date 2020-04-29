//
//  Rest.swift
//  GithubUsers
//
//  Created by Joel Meng on 10/26/19.
//  Copyright © 2019 Joel Meng. All rights reserved.
//

import Foundation

enum Rest {

	// MARK: - Load Codable Data

    @discardableResult
    static func load<T: Codable>(request: RestRequest,
                                 session: URLSessionProvider = URLSession.shared,
                                 dateDecodingStrategy: JSONDecoder.DateDecodingStrategy?,
                                 expectedResultType: T.Type,
                                 completion: @escaping (Result<T, Error>) -> Void) -> URLSessionDataTaskProtocol? {
        let decoder = JSONDecoder()
        if let dateDecodingStrategy = dateDecodingStrategy {
            decoder.dateDecodingStrategy = dateDecodingStrategy
        }
        return load(request: request, session: session, decoder:decoder, expectedResultType:expectedResultType, completion:completion)
    }

    @discardableResult
    static func load<T: Codable>(request: RestRequest,
								 session: URLSessionProvider = URLSession.shared,
								 decoder: JSONDecoder = JSONDecoder(),
								 expectedResultType: T.Type,
								 completion: @escaping (Result<T, Error>) -> Void) -> URLSessionDataTaskProtocol? {

		return load(request: request, session: session) { dataResult in
			switch dataResult {
			case .failure(let error):
				completion(Result.failure(error))
			case .success(let data):
				do {
					let decoded = try decoder.decode(T.self, from: data)
					completion(Result.success(decoded))
				} catch {
					completion(Result.failure(error))
				}
			}
		}
    }


	// MARK: - General Pure DataTask Loading


	static func load(request: RestRequest,
					 session: URLSessionProvider = URLSession.shared,
					 completion: @escaping (_ result: Result<Data, Error>) -> Void) -> URLSessionDataTaskProtocol? {

		guard let request = request.request() else {
			return nil
		}

		let task = session.dataTask(with: request) { data, response, error in

			if let error = error {
				completion(Result.failure(error))
				return
			}

			if let response = response as? HTTPURLResponse {
				if response.wasSuccessful == false {
					let error = NSError(domain: "ERROR.DOMAIN", code: response.statusCode, userInfo: nil)
					completion(Result.failure(error))
					return
				}
			}

			if let data = data {
				completion(Result.success(data))
				return
			}
		}
		task.resume()
		return task
	}
}
