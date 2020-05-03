//
//  HistoryUSDQuoteRequestBuilder.swift
//  Expensee
//
//  Created by Jun Meng on 3/5/20.
//  Copyright © 2020 Jun Meng. All rights reserved.
//

import Foundation

enum Endpoint: String {
    case historical
}

@_functionBuilder
struct CurrencyConvertRequestBuilder {

    static func buildBlock(_ segments: (String, String)...) -> RestRequest {
        let request = createGETRequest(path: Endpoint.historical.rawValue,
                                       parameter: Dictionary(uniqueKeysWithValues: segments))

        return request
    }
}

func historyUSDQuoteRequest(@CurrencyConvertRequestBuilder _ content: () -> RestRequest) -> RestRequest {
    return content()
}
