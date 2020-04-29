//
//	RestRequestURLQueryDecorator.swift
//  GithubUsers
//
//  Created by Joel Meng on 10/26/19.
//  Copyright © 2019 Joel Meng. All rights reserved.
//

import Foundation

struct RestRequestURLQueryDecorator: RestRequestDecorator {
    
    let baseRequest: RestRequest
    
    private let params: [String: Any]
    
    init(params: [String: Any], request: RestRequest) {
        self.baseRequest = request
        self.params = params
    }
    
    func request() -> URLRequest? {
        guard var baseRequest = baseRequest.request(), let url = baseRequest.url else { return nil }
        guard var components = URLComponents(url: url, resolvingAgainstBaseURL: true) else { return nil }
        components.percentEncodedQuery = urlQuery(params)?.map({ [$0.name, $0.value ?? ""].joined(separator: "=") }).joined(separator: "&")
        baseRequest.url = components.url
        return baseRequest
    }
}

fileprivate func urlQuery(_ parameters: [String: Any]) -> [URLQueryItem]? {
	
    guard parameters.count > 0 else { return nil }
    var components: [URLQueryItem] = []
    for key in parameters.keys.sorted(by: <) {
        guard let value = parameters[key] else { continue }
        switch value {
        case let value as String:
            if let escapedValue = value.addingPercentEncoding(withAllowedCharacters: CharacterSet.requestKit_URLQueryAllowedCharacterSet()) {
                components.append(URLQueryItem(name: key, value: escapedValue))
            }
        case let valueArray as [String]:
            for (index, item) in valueArray.enumerated() {
                if let escapedValue = item.addingPercentEncoding(withAllowedCharacters: CharacterSet.requestKit_URLQueryAllowedCharacterSet()) {
                    components.append(URLQueryItem(name: "\(key)[\(index)]", value: escapedValue))
                }
            }
        case let valueDict as [String: Any]:
            for nestedKey in valueDict.keys.sorted(by: <) {
                guard let value = valueDict[nestedKey] as? String else { continue }
                if let escapedValue = value.addingPercentEncoding(withAllowedCharacters: CharacterSet.requestKit_URLQueryAllowedCharacterSet()) {
                    components.append(URLQueryItem(name: "\(key)[\(nestedKey)]", value: escapedValue))
                }
            }
        default:
            print("Cannot encode object of type \(type(of: value))")
        }
    }
    return components
}

fileprivate extension CharacterSet {
    
    static func requestKit_URLQueryAllowedCharacterSet() -> CharacterSet {
        let generalDelimitersToEncode = ":#[]@" // does not include "?" or "/" due to RFC 3986 - Section 3.4
        let subDelimitersToEncode = "!$&'()*+,;="
        
        var allowedCharacterSet = CharacterSet.urlQueryAllowed
        allowedCharacterSet.remove(charactersIn: generalDelimitersToEncode + subDelimitersToEncode)
        return allowedCharacterSet
    }
}
